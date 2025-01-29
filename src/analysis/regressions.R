require(readr)
require(sjPlot)
require(lme4)
require(lmerTest)

# load stats per utt
test_file_stats <- read_tsv("../../out/results/test_file_stats.tsv")
test_file_stats$text <- NULL

# load results from each model
testfiles_urum <- list.files("../../out/results/test-analysis/", pattern = "*.tsv")

test_urum <- data.frame()
for (i in 1:length(testfiles_urum)) {
  d <- read_delim(paste0("../../out/results/test-analysis/", testfiles_urum[i]), 
                  delim = "\t", escape_double = FALSE, 
                  col_names = TRUE, trim_ws = TRUE)
  d$model <- gsub(".tsv", "", testfiles_urum[i])
  #colnames(d) <- c("utt_id", "phone", "prec_phone", "diff", "accuracy", "model")
  test_urum <- rbind(test_urum, d)
}

# merge utt stats with all models
joined_test <- merge(test_urum, test_file_stats, by="utt_id")

# prepare variables for lmer
d_stats <- joined_test
d_stats$utt_id <- NULL
d_stats$phone <- NULL
d_stats$prec_phone <- NULL

# MAIN VARIABLES: 
#   lang (CS or Urum), class of current phone, class of previous phone, 
#   contamination amount, utt duration, spkr in train set, model used

d_stats$Nurum_test_utt <- d_stats$lang == "urum"

# class of current phone: sum-coded, held-out level is "stop"
d_stats$phone_class <- factor(d_stats$phone_class, levels = c("vowel", "approx", "tap-trill", 
                                                  "nasal", "fricative", "affricate", "stop"))
d_stats$Nvowel <- ifelse(d_stats$phone_class == "vowel", 1, ifelse(d_stats$phone_class == "stop", -1, 0))
d_stats$Napprox <- ifelse(d_stats$phone_class == "approx", 1, ifelse(d_stats$phone_class == "stop", -1, 0))
d_stats$Ntap <- ifelse(d_stats$phone_class == "tap-trill", 1, ifelse(d_stats$phone_class == "stop", -1, 0))  # maybe collapse to approx
d_stats$Nnasal <- ifelse(d_stats$phone_class == "nasal", 1, ifelse(d_stats$phone_class == "stop", -1, 0))
d_stats$Nfric <- ifelse(d_stats$phone_class == "fricative", 1, ifelse(d_stats$phone_class == "stop", -1, 0))
d_stats$Naffr <- ifelse(d_stats$phone_class == "affricate", 1, ifelse(d_stats$phone_class == "stop", -1, 0))

# class of preceding phone: sum-coded, held-out level is "SIL"
d_stats$prec_phone_class <- factor(d_stats$prec_phone_class, 
                                   levels = c("vowel", "approx", "tap-trill", "nasal", 
                                              "fricative", "affricate", "stop", "SIL"))
d_stats$Npvowel <- ifelse(d_stats$prec_phone_class == "vowel", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))
d_stats$Npapprox <- ifelse(d_stats$prec_phone_class == "approx", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))
d_stats$Nptap <- ifelse(d_stats$prec_phone_class == "tap-trill", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))
d_stats$Npnasal <- ifelse(d_stats$prec_phone_class == "nasal", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))
d_stats$Npfric <- ifelse(d_stats$prec_phone_class == "fricative", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))
d_stats$Npaffr <- ifelse(d_stats$prec_phone_class == "affricate", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))
d_stats$Npstop <- ifelse(d_stats$prec_phone_class == "stop", 1, ifelse(d_stats$prec_phone_class == "SIL", -1, 0))

d_stats$Nutt_dur <- d_stats$utt_dur/100  # maybe try without /100, or try /1000

# model: treatment-coded. Each model is compard to urum-only2 (47min Urum-only)
d_stats$model <- factor(d_stats$model, 
                        levels = c("urum-only2", "cs-urum-phones3", "cs-russ-phones3", 
                                   "all-urum-phones3", "all-russ-phones3", "urum-only-broad", 
                                   "cs-urum-phones-broad", "all-urum-phones-broad", "engmfa-urum-only-orig", 
                                   "engmfa-cs-urum-phones-orig", "engmfa-cs-russ-phones-orig", 
                                   "engmfa-all-urum-phones-orig", "engmfa-all-russ-phones-orig", 
                                   "russmfa-urum-only-orig", "russmfa-cs-urum-phones-orig", 
                                   "russmfa-cs-russ-phones-orig", "russmfa-all-urum-phones-orig", 
                                   "russmfa-all-russ-phones-orig"))

# d_stats$Nurum_only <- ifelse(d_stats$model == "urum-only2", 1, 0)
d_stats$Ncs_urum_phones <- ifelse(d_stats$model == "cs-urum-phones3", 1, 0)
d_stats$Ncs_russ_phones <- ifelse(d_stats$model == "cs-russ-phones3", 1, 0)
d_stats$Nall_urum_phones <- ifelse(d_stats$model == "all-urum-phones3", 1, 0)
d_stats$Nall_russ_phones <- ifelse(d_stats$model == "all-russ-phones3", 1, 0)

d_stats$Neng_urum_only <- ifelse(d_stats$model == "engmfa-urum-only-orig", 1, 0)
d_stats$Neng_cs_urum_phones <- ifelse(d_stats$model == "engmfa-cs-urum-phones-orig", 1, 0)
d_stats$Neng_cs_russ_phones <- ifelse(d_stats$model == "engmfa-cs-russ-phones-orig", 1, 0)
d_stats$Neng_all_urum_phones <- ifelse(d_stats$model == "engmfa-all-urum-phones-orig", 1, 0)
d_stats$Neng_all_russ_phones <- ifelse(d_stats$model == "engmfa-all-russ-phones-orig", 1, 0)

d_stats$Nruss_urum_only <- ifelse(d_stats$model == "russmfa-urum-only-orig", 1, 0)
d_stats$Nruss_cs_urum_phones <- ifelse(d_stats$model == "russmfa-cs-urum-phones-orig", 1, 0)
d_stats$Nruss_cs_russ_phones <- ifelse(d_stats$model == "russmfa-cs-russ-phones-orig", 1, 0)
d_stats$Nruss_all_urum_phones <- ifelse(d_stats$model == "russmfa-all-urum-phones-orig", 1, 0)
d_stats$Nruss_all_russ_phones <- ifelse(d_stats$model == "russmfa-all-russ-phones-orig", 1, 0)

# random var: spkr ID, file ID

# y-var: boundary diff
d_stats$Ndiff <- ifelse(d_stats$diff == 0, 0.001, d_stats$diff)
d_stats$Ndiff <- log(d_stats$Ndiff)

# LMER equation
fit_boundary_urum <- lmer(Ndiff ~ Ncs_urum_phones + Ncs_russ_phones + Nall_urum_phones + Nall_russ_phones + Neng_urum_only + 
                                Neng_cs_urum_phones + Neng_cs_russ_phones + Neng_all_urum_phones + Neng_all_russ_phones + 
                                Nruss_urum_only + Nruss_cs_urum_phones + Nruss_cs_russ_phones + Nruss_all_urum_phones + Nruss_all_russ_phones + 
                                Nutt_dur + contam_amt + seen_spkr + Nurum_test_utt +
                                Npvowel + Npapprox + Nptap + Npnasal + Npfric + Npaffr + Npstop + 
                                Nvowel + Napprox + Ntap + Nnasal + Nfric + Naffr +
                                Npvowel:Nvowel + Npvowel:Napprox + Npvowel:Ntap + Npvowel:Nnasal + Npvowel:Nfric + Npvowel:Naffr +
                                Npapprox:Nvowel + Npapprox:Napprox + Npapprox:Ntap + Npapprox:Nnasal + Npapprox:Nfric + Npapprox:Naffr + 
                                Nptap:Nvowel + Nptap:Napprox + Nptap:Nptap + Nptap:Nnasal + Nptap:Nfric + Nptap:Naffr +
                                Npnasal:Nvowel + Npnasal:Napprox + Npnasal:Ntap + Npnasal:Nnasal + Npnasal:Nfric + Npnasal:Naffr + 
                                Npfric:Nvowel + Npfric:Napprox + Npfric:Ntap + Npfric:Nnasal + Npfric:Nfric + Npfric:Naffr + 
                                Npaffr:Nvowel + Npaffr:Napprox + Npaffr:Ntap + Npaffr:Nnasal + Npaffr:Nfric + Npaffr:Naffr + 
                                Npstop:Nvowel + Npstop:Napprox + Npstop:Ntap + Npstop:Nnasal + Npstop:Nfric + Npstop:Naffr + 
                                (1|file_id) + (1|spkr_id), d_stats)
summary(fit_boundary_urum)


# Logistic regression
fit_accuracy_urum <- glmer(accuracy ~ Ncs_urum_phones + Ncs_russ_phones + Nall_urum_phones + Nall_russ_phones + Neng_urum_only + 
                                 Neng_cs_urum_phones + Neng_cs_russ_phones + Neng_all_urum_phones + Neng_all_russ_phones + 
                                 Nruss_urum_only + Nruss_cs_urum_phones + Nruss_cs_russ_phones + Nruss_all_urum_phones + Nruss_all_russ_phones + 
                                 Nutt_dur + contam_amt + seen_spkr + Nurum_test_utt +
                                 Npvowel + Npapprox + Nptap + Npnasal + Npfric + Npaffr + Npstop + 
                                 Nvowel + Napprox + Ntap + Nnasal + Nfric + Naffr +
                                 (1|file_id) + (1|spkr_id), family = "binomial", d_stats)
summary(fit_accuracy_urum)




