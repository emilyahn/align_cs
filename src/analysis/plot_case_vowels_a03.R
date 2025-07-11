library(phonR,tidyverse,dplyr) #,stringr

# load in speaker A03's formants

get_formant_df <- function(formant_file_dir) {
  test_formant_files_male <- list.files(formant_file_dir, pattern = "*_m_formants.csv")
  test_formants_m <- data.frame()
  d2 <- data.frame()
  for (i in 1:length(test_formant_files_male)) {
    if (grepl("gold", formant_file_dir)) {
      d2 <- read_delim(paste0(formant_file_dir, test_formant_files_male[i]), 
                       delim = ",", escape_double = FALSE, 
                       locale = readr::locale(encoding = "UTF-16BE"),
                       col_names = TRUE, trim_ws = TRUE)
    } else {
      d2 <- read_delim(paste0(formant_file_dir, test_formant_files_male[i]), 
                       delim = ",", escape_double = FALSE, 
                       #locale = readr::locale(encoding = "UTF-16BE"),
                       col_names = TRUE, trim_ws = TRUE)
      }
    d2$lang <- str_split(test_formant_files_male[i], "_")[[1]][1]
    test_formants_m <- rbind(test_formants_m, d2)
  }
  test_formants_m$spkr_id <- str_sub(test_formants_m$utt_id, -3)
  test_formants_m$f1_mid <- as.double(test_formants_m$f1_mid)
  test_formants_m$f2_mid <- as.double(test_formants_m$f2_mid)
  no_na_test_formants_m <- test_formants_m %>% drop_na(f1_mid,f2_mid)
  a03_formants_raw <- subset(no_na_test_formants_m, spkr_id == "A03")
  
  a03_formants <- a03_formants_raw %>%
    mutate(across('vowel', str_replace, 'M', 'ɯ')) %>% 
    mutate(across('vowel', str_replace, '9', 'œ')) %>% 
    mutate(across('vowel', str_replace, '\\{', 'æ'))
  return(a03_formants)
}


# plot vowel ellipse
# NOTE: I had to download the Charis SIL font first.

# gold:
gold_a03_df <- get_formant_df("/Users/eahn/work/align_cs/data/case_study/gold_analysis/")
gold_a03_df_i <- subset(gold_a03_df, vowel == "i" | vowel == "o" | vowel == "a")


# best system (russ-mfa-all):
russmfaall_a03_df <- get_formant_df("/Users/eahn/work/align_cs/data/case_study/russmfa-all-urum-phones/")
russmfaall_a03_df_i <- subset(russmfaall_a03_df, vowel == "i" | vowel == "o" | vowel == "a")


# worst system (cs-urum, 47min model):
cs47_a03_df <- get_formant_df("/Users/eahn/work/align_cs/data/case_study/cs-urum-phones3/")
#cs47_a03_df_i <- subset(cs47_a03_df, vowel == "i" | vowel == "o" | vowel == 'ɯ' | vowel == 'æ' )
cs47_a03_df_i <- subset(cs47_a03_df, vowel == "i" | vowel == "o" | vowel == 'a')

#par(mar = c(4.1, 5, 5, 2))

#with(gold_a03_df, plotVowels(f1_mid,
#with(gold_a03_df_i, plotVowels(f1_mid,
#with(russmfaall_a03_df, plotVowels(f1_mid,
#with(russmfaall_a03_df_i, plotVowels(f1_mid,
#with(cs47_a03_df, plotVowels(f1_mid,
with(cs47_a03_df_i, plotVowels(f1_mid,
           f2_mid,
           vowel,
           group = lang,
           plot.tokens = FALSE, 
           legend.kwd = "bottomleft", 
           plot.means = TRUE, 
           pch.means = vowel,
           cex.means = 2,
           pretty = TRUE,
           ellipse.fill = TRUE,
           ellipse.line = TRUE,
           fill.opacity = 0.1,
           var.col.by= lang,
           var.sty.by= lang,
           xlim = c(2500, 500),
           ylim = c(800, 0),
           cex.lab = 1.1,
           cex.axis = 1.1,
           legend.args = list(cex=1.5)
           #family = "Charis SIL"
           ))

# toggle titles
title(main = "Gold", line = 3, adj = 0.4, cex.main = 1.7)
title(main = "Best model (Russ MFA all)", line = 3, adj = 0.3, cex.main = 1.7)
title(main = "Worst model (CS 47m)", line = 3, adj = 0.3, cex.main = 1.7)
