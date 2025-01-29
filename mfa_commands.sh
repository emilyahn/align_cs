# all commands that involve MFA

####
# Training from scratch
####

# Urum-only (trained on 47min)
mfa train --clean data/mfa_input/train/urum_train2 data/urum_only_dict_v4.txt out/models/urum-only2.zip
mfa align data/mfa_input/test2/ data/urum_only_dict_v4.txt out/models/urum-only2.zip out/tg/urum-only2
# FYI run-time on MacBook Pro 2019
	# train: 1987sec = 33min 7sec
	# test: 61sec
# run-time half on cluster (~16/17 min train)

# Code-switched only (trained on 47min, matched with Urum)

# using dict with Urum phones only (Russian words mapped to Urum phone set)
mfa train --clean data/mfa_input/train/cs_train2 data/cs_urum-phones_dict3.txt out/models/cs-urum-phones3.zip
mfa align data/mfa_input/test2 data/cs_urum-phones_dict3.txt out/models/cs-urum-phones3.zip out/tg/cs-urum-phones3
# using dict including Russ phones
mfa train --clean data/mfa_input/train/cs_train2 data/cs_russ-phones_dict3.txt out/models/cs-russ-phones3.zip
mfa align data/mfa_input/test2 data/cs_russ-phones_dict3.txt out/models/cs-russ-phones3.zip out/tg/cs-russ-phones3

# Urum + CS data (94min)
mfa train --clean data/mfa_input/train data/cs_urum-phones_dict3.txt out/models/all-urum-phones3.zip
mfa align data/mfa_input/test2 data/cs_urum-phones_dict3.txt out/models/all-urum-phones3.zip out/tg/all-urum-phones3

mfa train --clean data/mfa_input/train data/cs_russ-phones_dict3.txt out/models/all-russ-phones3.zip
mfa align data/mfa_input/test2/ data/cs_russ-phones_dict3.txt out/models/all-russ-phones3.zip out/tg/all-russ-phones3


# Experiments removing diacritic symbol, in effect allowing symbols/phones like /s:/ to merge with /s/
# NOTE: used data that didn't include fully-tagged words/tokens
mfa train --clean data/mfa_input/train/urum_train2 data/urum_only_dict_v4_broad.txt out/models/urum-only-broad.zip
mfa align data/mfa_input/test2/ data/urum_only_dict_v4_broad.txt out/models/urum-only-broad.zip out/tg/urum-only-broad

mfa train --clean data/mfa_input/train/cs_train2 data/cs_urum-phones_dict3_broad.txt out/models/cs-urum-phones-broad.zip
mfa align data/mfa_input/test2 data/cs_urum-phones_dict3_broad.txt out/models/cs-urum-phones-broad.zip out/tg/cs-urum-phones-broad

mfa train --clean data/mfa_input/train data/cs_urum-phones_dict3_broad.txt out/models/all-urum-phones-broad.zip
mfa align data/mfa_input/test2 data/cs_urum-phones_dict3_broad.txt out/models/all-urum-phones-broad.zip out/tg/all-urum-phones-broad


####
# Pretrained models adapted on target data
####

# Global English model
mfa model download acoustic english_mfa

# Urum-only 47min
mfa adapt --clean data/mfa_input/train/urum_train2 data/urum-to-eng.dict english_mfa out/models/engmfa-urum-only.zip
mfa align data/mfa_input/test2/ data/urum-to-eng.dict out/models/engmfa-urum-only.zip out/tg/engmfa-urum-only

# CS 47min
# urum phones
mfa adapt --clean data/mfa_input/train/cs_train2 data/urum-to-eng.dict english_mfa out/models/engmfa-cs-urum-phones.zip
mfa align data/mfa_input/test2/ data/urum-to-eng.dict out/models/engmfa-cs-urum-phones.zip out/tg/engmfa-cs-urum-phones
# russ phones
mfa adapt --clean data/mfa_input/train/cs_train2 data/cs-to-eng.dict english_mfa out/models/engmfa-cs-russ-phones.zip
mfa align data/mfa_input/test2/ data/cs-to-eng.dict out/models/engmfa-cs-russ-phones.zip out/tg/engmfa-cs-russ-phones

# ALL Urum + CS 94min
# urum phones
mfa adapt --clean data/mfa_input/train/ data/urum-to-eng.dict english_mfa out/models/engmfa-all-urum-phones.zip
mfa align data/mfa_input/test2/ data/urum-to-eng.dict out/models/engmfa-all-urum-phones.zip out/tg/engmfa-all-urum-phones
# russ phones
mfa adapt --clean data/mfa_input/train/ data/cs-to-eng.dict english_mfa out/models/engmfa-all-russ-phones.zip
mfa align data/mfa_input/test2/ data/cs-to-eng.dict out/models/engmfa-all-russ-phones.zip out/tg/engmfa-all-russ-phones


# Russian MFA model
mfa model download acoustic russian_mfa

# Urum-only 47min
mfa adapt --clean data/mfa_input/train/urum_train2 data/urum-to-russ.dict russian_mfa out/models/russmfa-urum-only.zip
mfa align data/mfa_input/test2/ data/urum-to-russ.dict out/models/russmfa-urum-only.zip out/tg/russmfa-urum-only

# CS 47min
# urum phones
mfa adapt --clean data/mfa_input/train/cs_train2 data/urum-to-russ.dict russian_mfa out/models/russmfa-cs-urum-phones.zip
mfa align data/mfa_input/test2/ data/urum-to-russ.dict out/models/russmfa-cs-urum-phones.zip out/tg/russmfa-cs-urum-phones
# russ phones
mfa adapt --clean data/mfa_input/train/cs_train2 data/cs-to-russ.dict russian_mfa out/models/russmfa-cs-russ-phones.zip
mfa align data/mfa_input/test2/ data/cs-to-russ.dict out/models/russmfa-cs-russ-phones.zip out/tg/russmfa-cs-russ-phones

# ALL Urum + CS 94min
# urum phones
mfa adapt --clean data/mfa_input/train/ data/urum-to-russ.dict russian_mfa out/models/russmfa-all-urum-phones.zip
mfa align data/mfa_input/test2/ data/urum-to-russ.dict out/models/russmfa-all-urum-phones.zip out/tg/russmfa-all-urum-phones
# russ phones
mfa adapt --clean data/mfa_input/train/ data/cs-to-russ.dict russian_mfa out/models/russmfa-all-russ-phones.zip
mfa align data/mfa_input/test2/ data/cs-to-russ.dict out/models/russmfa-all-russ-phones.zip out/tg/russmfa-all-russ-phones




