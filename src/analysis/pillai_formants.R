library(tidyverse)

# FYI gold dir requires locale flag when reading in DF
# cs-russ-phones3 model: A07 can't handle /M/

# Test set
#formant_file_dir <- "/Users/eahn/work/align_cs/data/case_study/gold_analysis/"
#formant_file_dir <- "/Users/eahn/work/align_cs/data/case_study/russmfa-all-urum-phones/"
#formant_file_dir <- "/Users/eahn/work/align_cs/data/case_study/cs-urum-phones3/"
#formant_file_dir <- "/Users/eahn/work/align_cs/data/case_study/engmfa-all-urum-phones-orig/"
formant_file_dir <- "/Users/eahn/work/align_cs/data/case_study/all-urum-phones3/"
print_file <- paste0(formant_file_dir, "r_output_nodur.txt")


# MALE speakers only
# load results from each lang and add as column
test_formant_files_male <- list.files(formant_file_dir, pattern = "*_m_formants.csv")
test_formant_files_female <- list.files(formant_file_dir, pattern = "*_f_formants.csv")

test_formants_m <- data.frame()
for (i in 1:length(test_formant_files_male)) {
  d2 <- read_delim(paste0(formant_file_dir, test_formant_files_male[i]), 
                  delim = ",", escape_double = FALSE, 
                  #locale = readr::locale(encoding = "UTF-16BE"),
                  col_names = TRUE, trim_ws = TRUE)
  d2$lang <- str_split(test_formant_files_male[i], "_")[[1]][1]
  test_formants_m <- rbind(test_formants_m, d2)
}

test_formants_f <- data.frame()
for (i in 1:length(test_formant_files_female)) {
  d3 <- read_delim(paste0(formant_file_dir, test_formant_files_female[i]), 
                   delim = ",", escape_double = FALSE, 
                   #locale = readr::locale(encoding = "UTF-16BE"),
                   col_names = TRUE, trim_ws = TRUE)
  d3$lang <- str_split(test_formant_files_female[i], "_")[[1]][1]
  test_formants_f <- rbind(test_formants_f, d3)
}

# get spkr_id into new column, recast f1/f2 as numerics
test_formants_m$spkr_id <- str_sub(test_formants_m$utt_id, -3)
test_formants_m$f1_mid <- as.double(test_formants_m$f1_mid)
test_formants_m$f2_mid <- as.double(test_formants_m$f2_mid)
test_formants_f$spkr_id <- str_sub(test_formants_f$utt_id, -3)
test_formants_f$f1_mid <- as.double(test_formants_f$f1_mid)
test_formants_f$f2_mid <- as.double(test_formants_f$f2_mid)

# renove NA values
no_na_test_formants_m <- test_formants_m %>% drop_na(f1_mid,f2_mid)
no_na_test_formants_f <- test_formants_f %>% drop_na(f1_mid,f2_mid)


# FUNCTIONS
# stanley & sneller (2023): return threshold for merged vs unmerged pillai score
pillai_threshold <- function(n) {
  # half the total sample size
  m <- n/2 
  # Equation 1
  exp(1)/m
}

# return pillai score of MANOVA
pillai <- function(...) {
  summary(manova(...))$stats[1, "Pillai"]
}

# return p value of MANOVA
manova_p <- function(...) {
  summary(manova(...))$stats[1, "Pr(>F)"]
}

# not sure what ungroup() does. commenting it out gives same result table
# I define 'merged' to be if Lang and CS vowel F1/F2 are overlapped.
# prints pillai scores and p values for F1/F2
print_table <- function(working_df) {
  pillais <- working_df %>%
    group_by(spkr_id, vowel) %>%
    summarize(n = n(),
              threshold = pillai_threshold(n),
              pillai = pillai(cbind(f1_mid, f2_mid) ~ lang),
              p = manova_p(cbind(f1_mid, f2_mid) ~ lang),
              merged = pillai < threshold) %>%
    ungroup() %>%
    print()
}

# prints pillai scores and p values for F1/F2/duration
print_table_dur <- function(working_df) {
  pillais <- working_df %>%
    group_by(spkr_id, vowel) %>%
    summarize(n = n(),
              threshold = pillai_threshold(n),
              pillai = pillai(cbind(f1_mid, f2_mid, dur) ~ lang),
              p = manova_p(cbind(f1_mid, f2_mid, dur) ~ lang),
              merged = pillai < threshold) %>%
    ungroup() %>%
    print()
}

sink(print_file)

# MALE SPEAKERS (results per each of the 2 spkrs who use both Urum & CS)
print("MALE SPEAKERS")

a03_formants <- subset(no_na_test_formants_m, spkr_id == "A03")
#a03_formants %>%
#  summarize(mean_f1 = mean(f1_mid), mean_f2 = mean(f2_mid))
a01_formants <- subset(no_na_test_formants_m, spkr_id == "A01")
#a01_formants %>%
#  summarize(mean_f1 = mean(f1_mid), mean_f2 = mean(f2_mid))

print_table(a03_formants)
#print_table_dur(a03_formants)

print_table(a01_formants)
#print_table_dur(a01_formants)

# FEMALE SPEAKERS
print("FEMALE SPEAKERS")

# only A02 and B08 have enough data per vowel per lang to do full pillai comparison
f_spkrs_both <- c("A02", "B08")

for (f_spkr in f_spkrs_both) {
  print_table(subset(no_na_test_formants_f, spkr_id == f_spkr))
  #print_table_dur(subset(no_na_test_formants_f, spkr_id == f_spkr))
}

# filter out certain vowels for 3 female speakers:
# B16: /u,y/ only have 1x per category, not enough to perform pillai
b16_fewer_vowels <- subset(no_na_test_formants_f, spkr_id == "B16")
b16_fewer_vowels <- subset(b16_fewer_vowels, vowel != "u" & vowel != "y")
print_table(b16_fewer_vowels)
#print_table_dur(b16_fewer_vowels)

# B11: /u/ missing from CS
b11_fewer_vowels <- subset(no_na_test_formants_f, spkr_id == "B11")
b11_fewer_vowels <- subset(b11_fewer_vowels, vowel != "u")
print_table(b11_fewer_vowels)
#print_table_dur(b11_fewer_vowels)

# A07: /u, o/ missing from Urum
a07_fewer_vowels <- subset(no_na_test_formants_f, spkr_id == "A07")
a07_fewer_vowels <- subset(a07_fewer_vowels, vowel != "u" & vowel != "o")
#a07_fewer_vowels <- subset(a07_fewer_vowels, vowel != "u" & vowel != "o" & vowel != "M")
print_table(a07_fewer_vowels)
#print_table_dur(a07_fewer_vowels)

sink()
