#Cuts up a large sound file into smaller chunks using an existing tier on an associated TextGrid file.
#The object name is the sound file name. The TextGrid name is the name of the Praat TextGrid file which
#is time-aligned with the sound file. The Renamed file prefix is a string that the user can add to all
#extracted intervals for the particular sound file, e.g. speaker name, session info, etc. The tier number
#reflects the tier containing the string which will be used for the main file name. The assumption of this
#script is that you have a tier containing only ascii characters which you wish to use as the filename of
#the smaller file.

#This script is useful for either experimental purposes (e.g. cutting up tokens into smaller files which are more
#manageable) or for corpus/fieldwork linguistic purposes (e.g. you export an ELAN file to Praat and then extract
#words of a particular type).

#Copyright Christian DiCanio, SUNY Buffalo, 2016, 2020.


# Modified Emily P. Ahn, UW, 2024.
# Cut Urum files (textgrids only!) into utts using naming of 1st tier

# form Extract smaller files from large file
#    sentence Tg_dir: /Users/eahn/work/align_cs/data/doreco_repo/
#    sentence Wav_dir: /Users/eahn/work/align_cs/eleanor/tst_mfainput/
#    sentence Out_dir: /Users/eahn/work/align_cs/data/all_utts/
#    sentence Objects_name: doreco_urum1249_UUM-TXT-AN-00000-A02
#    sentence TextGrid_name: doreco_urum1249_UUM-TXT-AN-00000-A02
#    positive Tier_number: 1
# endform

tg_dir$ = "/Users/eahn/work/align_cs/eleanor/urum_gold/"
out_dir$ = "/Users/eahn/work/align_cs/data/gold_utts/"
tier_number = 1
tg_files$ = tg_dir$ + "*.TextGrid"

# Create Strings as file list... list 'wav_dir$'/*.wav
tg_list = Create Strings as file list: "tg_list", tg_files$
# selectObject: wav_list
num = Get number of strings
for ifile to num
	selectObject: tg_list
	# select Strings list
	tg_file$ = Get string: ifile
	tg_filename$ = tg_dir$ + tg_file$
	appendInfoLine: tg_filename$

	Read from file: tg_filename$
	textGridID = selected("TextGrid")
	select 'textGridID'
	intvl_length = Get number of intervals: tier_number

	for i from 1 to intvl_length
		lab$ = Get label of interval: tier_number, i
		time = Get starting point: tier_number, i
		index$ = string$(time)

		if lab$ = "<p:>"
			#do nothing
		elsif lab$ = "****"
			#do nothing
		else
			start = Get starting point: tier_number, i
			end = Get end point: tier_number, i
			select 'textGridID'
			tg_chunk = Extract part: start, end, "no"
			# select 'soundID'
			# Extract part... start end rectangular 1 no
			# Write to WAV file... 'out_dir$'/'lab$'.wav
			select 'tg_chunk'
			Save as text file... 'out_dir$'/'lab$'.TextGrid
		endif
		select 'textGridID'
	endfor

	# select all
	# Remove

endfor
select all
Remove