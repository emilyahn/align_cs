#Eliminates a specific tier for all textgrids in a directory - useful for alignment purposes.

#Copyright Christian DiCanio, SUNY Buffalo, 2023
# Modified by Emily P. Ahn, UW, 2024

form Eliminate tier
   sentence In_directory_name: /Users/eahn/work/align_cs/data/clean_utt_tg3/
   sentence Out_directory_name: /Users/eahn/work/align_cs/data/mfa_input/all_tg3/
   positive Tier_number_1: 2
   positive Tier_number_2: 3
endform

Create Strings as file list... list 'in_directory_name$'/*.TextGrid
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'in_directory_name$'/'fileName$'
	textGridID = selected("TextGrid")
	Remove tier: tier_number_1
	Remove tier: tier_number_2
	Save as text file... 'out_directory_name$'/'fileName$'
endfor
select all
Remove