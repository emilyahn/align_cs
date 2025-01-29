# get_formants_urum_gold.praat
# Specify high (5 formants @ 5500Hz) for female, low (5 formants @ 5000Hz) formant ranges for male speakers
# Get formants 1--2 at midpoints (or avg midpoint w/ 10ms before/after)
# Get information about the file, vowel, and duration
# Use XSAMPA (following Urum dataset)
# All decimals are rounded to 4 places (using fixed$)
# Based on script: outliers/src/getFormantsCommonVoice_highlow.praat
# => original script from VoxClamantis by Eleanor Chodroff: getFormantsWilderness.praat
# Modified by Emily P. Ahn
# 6 January 2025

# ###################
masterdir$ = "/Users/eahn/work/align_cs/data/"

# TOGGLE (1) system_dir and (2) use midpoint-averaging or not for formnat extraction
# system_dir$ = "case_study/gold_analysis/"
# system_dir$ = "case_study/russmfa-all-urum-phones/"
# system_dir$ = "case_study/cs-urum-phones3/"
# system_dir$ = "case_study/engmfa-all-urum-phones-orig/"
system_dir$ = "case_study/all-urum-phones3/"

# average_midpoints = 1
average_midpoints = 0

# var totalFormants: range [2-4] only
totalFormants = 2
sep$ = ","
langs$# = { "cs", "urum"}
sexs$# = {"m", "f"}
# ###################

if average_midpoints
	pauseScript: "yes, avg"
	csv_ending$ = "_formants10.csv"
else
	pauseScript: "not avg"
	csv_ending$ = "_formants.csv"
endif

for langi from 1 to 2
	lang$ = langs$#[langi]
	for sexj from 1 to 2
		sex$ = sexs$#[sexj]
		tg_dir$ = masterdir$ + system_dir$ + lang$ + "/" + sex$ + "/"
		wav_dir$ = masterdir$ + "mfa_input/test/"
		outfile$ = masterdir$ + system_dir$ + lang$ + "_" + sex$ + csv_ending$

		# pauseScript: "tgdir: " + tg_dir$
		deleteFile: outfile$
		@createHeader

		Create Strings as file list: "files", tg_dir$ + "*.TextGrid"
		nFiles = Get number of strings
		for i from 1 to nFiles
			@processFile
		endfor

	endfor
endfor

procedure createHeader
	appendFile: outfile$, "utt_id", sep$, "vowel", sep$, "prec", sep$, "foll", sep$
	appendFile: outfile$, "start", sep$, "end", sep$, "dur", sep$
	appendFile: outfile$, "f1_mid", sep$, "f2_mid"
	appendFile: outfile$, newline$
endproc


procedure processFile
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".TextGrid"
	# pauseScript: "basename: " + basename$
	Read from file: tg_dir$ + basename$ + ".TextGrid"
	Read from file: wav_dir$ + basename$ + ".wav"

	# convert wav files to formant objects
	# use default male/female settings
	# [OLD: TRACKING] only track if total # of formants is 2 (Track setting often fails with 3 or 4)
	if sex$ == "f"
		# To Formant (burg): 0, 4, 4200, 0.025, 50
		To Formant (burg): 0, 5, 5500, 0.025, 50
		# if totalFormants = 2
		# 	nocheck Track: 2, 550, 1650, 2750, 3850, 4950, 1.0, 1.0, 1.0
		# endif
	elsif sex$ == "m"
		# To Formant (burg): 0, 4, 4000, 0.025, 50
		To Formant (burg): 0, 5, 5000, 0.025, 50
		# if totalFormants = 2
		# 	nocheck Track: 2, 500, 1500, 2500, 3500, 4500, 1.0, 1.0, 1.0
		# endif
	endif

	# loop through TextGrid to find vowels
	selectObject: "TextGrid " + basename$

	# EPA: add info because there are several tiers. Only want phone tier
	nTiers = Get number of tiers
	for tier to nTiers
		tierName$ = Get tier name: tier
		if startsWith(tierName$, "ph")

			nInt = Get number of intervals: tier
			for j from 1 to nInt
				selectObject: "TextGrid " + basename$
				label$ = Get label of interval: tier, j
				# updated set of vowels below, IPA format (not XSAMPA)
				# check if I need backslash to escape the { char
				if index_regex(label$, "^[9aeiMouy\{1]")
					@getLabels
					@getTime
					for form from 1 to totalFormants
						@getFormants: form
					endfor
				endif
			endfor
		endif
	endfor

	# pauseScript: "done one file"
	# do some clean up
	select all
	minusObject: "Strings files"
	Remove
endproc

procedure getLabels
	if j > 1
		prec$ = Get label of interval: tier, j-1
	else
		prec$ = "NA"
	endif
	if j < nInt
		foll$ = Get label of interval: tier, j+1
	else
		foll$ = "NA"
	endif
	appendFile: outfile$, basename$, sep$, label$, sep$, prec$, sep$, foll$, sep$
endproc

procedure getTime
	start = Get start time of interval: tier, j
	end = Get end time of interval: tier, j
	dur = end - start
	# round values to 4 decimals at most
	appendFile: outfile$, number(fixed$(start, 4)), sep$, number(fixed$(end, 4)), sep$, number(fixed$(dur, 4)), sep$
endproc

procedure getFormants: formantNum
	selectObject: "Formant " + basename$

	# round all values to 4 decimals at most
	# get formants at each quartile (including start and end)
	# for f from 0 to 4
	# 	f_time4 = Get value at time: formantNum, start + f*(dur/4), "hertz", "Linear"
	# 	appendFile: outfile$, fixed$(f_time4, 4), sep$
	# endfor

	# get formants at 2 additional points: 10ms before midpoint & 10ms after midpoint
	f_mid = Get value at time: formantNum, start + (dur/2), "hertz", "Linear"
	f_mid_avg = f_mid

	if average_midpoints
		f_time_mp1 = Get value at time: formantNum, start + (dur/2) - 0.01, "hertz", "Linear"
		f_time_mp2 = Get value at time: formantNum, start + (dur/2) + 0.01, "hertz", "Linear"
		f_mid_avg = (f_time_mp1 + f_time_mp2 + f_mid) / 3
	endif

	if formantNum = totalFormants
		appendFile: outfile$, fixed$(f_mid_avg, 4), newline$
	else
		appendFile: outfile$, fixed$(f_mid_avg, 4), sep$
	endif

endproc
