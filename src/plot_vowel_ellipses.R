require(tidyverse)
require(ggthemes)
require(ggforce)
library(stringr)
library(Cairo)

lang <- 'urum'
# lang <- 'cs'
# m_f <- 'm'
m_f <- 'f'
lang_title <- str_to_title(paste(lang, m_f, sep="-"))

outfile <- str_glue("/Users/eahn/work/align_cs/data/gold_analysis/{lang}_{m_f}_vowels.pdf")

# filename <- paste0(lang, "_avg_formants_narrow_filter.tsv")
# filename <- paste0("/Users/eahn/work/outliers/data/cv8/formants/", filename)
# chuvash <- read_delim(filename, delim = "\t", escape_double = FALSE, trim_ws = TRUE)
chuvash <- read_delim(str_glue("/Users/eahn/work/align_cs/data/gold_analysis/{lang}_{m_f}_formants_spkravg.tsv"), delim = "\t", escape_double = FALSE, trim_ws = TRUE)

# chuvash_orig <- chuvash
chuvash <- subset(chuvash, V_count_spkr > 5)

vowel_stats <- chuvash %>% group_by(vowel) %>% summarise(grandmeanf1 = mean(mean_f1), sdf1 = sd(mean_f1), grandmeanf2 = mean(mean_f2), sdf2 = sd(mean_f2))

chuvash <- left_join(chuvash, vowel_stats, by = "vowel")

ggplot(chuvash) + geom_point(aes(x = mean_f2, y = mean_f1, color = vowel), alpha= 0.5, size = 4) +
  geom_ellipse(aes(x0 = grandmeanf2, y0 = grandmeanf1, a = sdf2, b = sdf1, angle = 0)) +
  geom_label(aes(x = grandmeanf2, y = grandmeanf1, label = vowel), size = 12) +
  scale_x_reverse(limits = c(2700, 800), position = "top") + scale_y_reverse(limits = c(850, 250), position = "right") +
  xlab("mean F2 (Hz)") + ylab("mean F1 (Hz)") +
  annotate("text", label = lang_title, x = 2550, y = 850, size = 9) +
  scale_color_viridis_d(end = 0.9) +
  theme_few(24) +
  guides(color = "none", label = "none")
ggsave(outfile, plot = last_plot(), dpi = 300, units = "in", height = 10, width = 10, device=cairo_pdf)

