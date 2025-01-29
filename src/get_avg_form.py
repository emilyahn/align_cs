import sys
import csv
import os
import numpy as np
import pandas as pd
from collections import defaultdict
from statistics import mean
from scipy.stats import norm


# get AVG F1/F2 per vowel per speaker, per setting (Urum vs CS, male vs female)
# outfile format: spkr_id, vowel, F1 avg, F2 avg, V_count_spkr
# to run:
# python get_avg_form.py {filter|no_filter} {formant_file} {xsampa_IPA_map}
# ex:
# python src/get_avg_form.py no_filter data/case_study/gold_analysis/cs_m_formants.csv data/map/cs-xsampa-to-ipa.map > data/case_study/gold_analysis/cs_m_formants_spkravg.tsv

filter_out = sys.argv[1]  # 'filter' or 'no_filter'
formant_file = sys.argv[2]  # ex. data/cv8/{lang}/{lang}_formants_low2.csv
xsampa_map_file = sys.argv[3]

if filter_out == 'filter':
	filter_out = True
else:
	filter_out = False

xsipa_dict = {}
with open(xsampa_map_file, 'r') as f:
	for line in f.readlines():
		items = line.strip().split('\t')
		if items:
			xsipa_dict[items[0]] = items[1]


def process_vowel_dict(formant_infile):
	spkr_vowel_dict = {}  # spkr_vowel_dict[spkr][vowel] = list(tuples(f1,f2))
	vowel_ft_dict = {}  # vowel_ft_dict[vowel][{'f1','f2'}] = list(float)
	# skip_dur = 0

	# with open(formant_infile, encoding='utf-16') as csvfile:
	with open(formant_infile) as csvfile:
		reader = csv.DictReader(csvfile, delimiter=',')

		for row in reader:

			spkr = row['utt_id'].split('-')[-1]  # ex. A01

			if filter_out:
				if float(row['dur']) > 0.3:
					# skip_dur += 1
					continue

			raw_vowel = row['vowel']
			vowel = xsipa_dict[raw_vowel]

			# f1 = mean([float(row['f1_mid']), float(row['f1_mp1']), float(row['f1_mp2'])])
			# f2 = mean([float(row['f2_mid']), float(row['f2_mp1']), float(row['f2_mp2'])])
			try:
				f1 = float(row['f1_mid'])
				f2 = float(row['f2_mid'])
			except:
				continue

			if spkr not in spkr_vowel_dict:
				spkr_vowel_dict[spkr] = defaultdict(list)

			if vowel not in vowel_ft_dict:
				vowel_ft_dict[vowel] = defaultdict(list)

			spkr_vowel_dict[spkr][vowel].append((f1, f2))  # tuple
			vowel_ft_dict[vowel]['f1'].append(f1)
			vowel_ft_dict[vowel]['f2'].append(f2)

	# process vowel_ft_dict first, save thresholds (2SD away from mean)
	thresh_dict = defaultdict(dict)  # thresh_dict[vowel][{'f1','f2'}] = (float, float)
	for vowel in vowel_ft_dict:
		for ft in vowel_ft_dict[vowel]:  # iterate over ['f1', 'f2']
			mu, std = norm.fit(vowel_ft_dict[vowel][ft])
			lower_thresh = mu - (2 * std)
			upper_thresh = mu + (2 * std)
			thresh_dict[vowel][ft] = (lower_thresh, upper_thresh)

	# skip_thresh = 0
	# then get avgs per speaker, filtering out > 2SD, print
	for spkr in spkr_vowel_dict:
		for vowel, form_list in spkr_vowel_dict[spkr].items():
			f1_keep_list = []
			f2_keep_list = []
			for tup in form_list:
				# skip if any of F1 or F2 is out of bounds
				if filter_out:
					if tup[0] < thresh_dict[vowel]['f1'][0] or tup[0] > thresh_dict[vowel]['f1'][1] or tup[1] < thresh_dict[vowel]['f2'][0] or tup[1] > thresh_dict[vowel]['f2'][1]:
						# skip_thresh += 1
						# print(vowel, tup, thresh_dict[vowel]['f1'], thresh_dict[vowel]['f2'])
						continue

				f1_keep_list.append(tup[0])
				f2_keep_list.append(tup[1])

			# list may be empty. then don't print
			if not f1_keep_list:
				continue

			mean_f1 = mean(f1_keep_list)
			mean_f2 = mean(f2_keep_list)

			print(f'{spkr}\t{vowel}\t{mean_f1:.2f}\t{mean_f2:.2f}\t{len(f1_keep_list)}')

	# print("DUR SKIP", file=sys.stderr)
	# print(skip_dur, file=sys.stderr)
	# print("THRESH SKIP", file=sys.stderr)
	# print(skip_thresh, file=sys.stderr)

print('spkr\tvowel\tmean_f1\tmean_f2\tV_count_spkr')
process_vowel_dict(formant_file)
