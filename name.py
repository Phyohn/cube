#name.py
#python  -i

import base64
import cv2
import datetime
import io
import numpy as np
import os
import pandas as pd
import pathlib
from PIL import Image
import platform
import sys
import time


def csv_stdout(df_c):
	return df_c.to_csv(sys.stdout)

def yes_no_input():
	while True:
		choice = input("           OK? [y/N]: ( q = quit )").lower()
		if choice in ['y', 'ye', 'yes']:
			return True
		elif choice in ['n', 'no']:
			return False
		elif choice in ['q', 'Q']:
			return quit()

tmp = pd.read_csv('pre_out_topy.txt',names=('dai','Rotation','BB','RB','difference','max','model','hall','date'))
#dailist series to df
posdai = tmp.loc[:,'dai'].unique()
tmp.insert(0,'posdai',posdai)
dailist = pd.read_csv('dailist.txt',names=('posdai','kuu'))
merged = pd.merge(tmp, dailist, how='outer')
reindexed = merged.reindex(columns=['posdai','Rotation','BB','RB','difference','max','model','hall'])
#fillna(0) float to int64 'model'object0 dtype to str for replacement
fillnaed = reindexed.fillna(0)
comp = fillnaed.astype({'posdai': 'int64','Rotation':'int64','BB':'int64','RB':'int64','difference':'int64','max':'int64','model':'str'})
#df.sort_values
comp = comp.sort_values('posdai')

#DailistRenameSequence
#pd.Series.unique()
#defdai = comp.loc[:,'model'].unique()

#series to df
#defdaidf = pd.DataFrame(defdai)
#defdaidf.insert(0,'namebank', defdai)
#dainame = pd.read_csv('namebank.csv',names=('namebank','neoname'))
#drop_duplicates(subset=['namebank']
#dainame = dainame.drop_duplicates(subset=['namebank'])
#newdailist = pd.merge(defdaidf, dainame, how='outer')
#newdailist = newdailist.reindex(columns=['namebank','neoname'])
#newdailist.to_csv('./namebank.csv', header=False, index=False)

#auto model_name_bank
model_name_df = pd.DataFrame(comp['model'].drop_duplicates())
model_name_df['fuga'] = '0'
rename_list_df = pd.read_csv('namebank.csv',names=('model','renamed_model_name'))
merged_model_name_df = pd.merge(model_name_df, rename_list_df , how='outer').drop(columns='fuga')
sorted_model_df = merged_model_name_df.sort_values('renamed_model_name', na_position='first')
empty_value = (sorted_model_df['renamed_model_name'].isnull())

if empty_value.sum() > 0 :
	csv_stdout(sorted_model_df)
	new_model_list = (sorted_model_df['model'])[empty_value].tolist()
	renamed_new_model_list = []
	for new_model in new_model_list:
		newshortname = input(f"new model arrive. {new_model}  (q = quit) Input newname. ")
		if newshortname == "q" :
			print("Finish!")
			quit()
			brake
		else:
			print(f'{new_model} is "{newshortname}"')
			if yes_no_input():
				renamed_new_model_list.append(newshortname)	
			else:
				pass
	'''	
	create a zipped list of tuples from above lists
	'''
	
	zippedlist =  list(zip(new_model_list, renamed_new_model_list))
	
	'''
	create df
	'''
	df_by_list = pd.DataFrame(zippedlist, columns = ['model', 'renamed_model_name'])
	added_sorted_model_df = pd.merge(sorted_model_df, df_by_list, on=('model', 'renamed_model_name'), how = 'outer').drop_duplicates(subset='model', keep='last')
	#sorted_model_df = sorted_model_df.replace( new_model_list, renamed_new_model_list)
	print("done!")
	sorted_model_df = added_sorted_model_df.sort_values('renamed_model_name', na_position='first')
else:
	pass

print("all model name has arrived")
sorted_model_df.to_csv('./namebank.csv', header=False, index=False)

#rename
dailist_df =  pd.read_csv('namebank.csv', header=None)
longname_list = (dailist_df.iloc[:,0]).values.tolist()
shortname_list = (dailist_df.iloc[:,1]).values.tolist()
comp = comp.replace(longname_list,shortname_list)

#y/n date today?
today = datetime.datetime.now()
intdt= int(today.strftime('%Y%m%d'))

print(f' today? {intdt}' )
if __name__ == '__main__':
	if yes_no_input():
		d = datetime.datetime.now()
	else:
		d = datetime.datetime.now() - datetime.timedelta(days=1)
#8 digits to int
intdt= int(d.strftime('%Y%m%d'))
print(intdt)
#'date'.values replace intdt all
comp['date'] = intdt
#'hall'columns delete
test_comp = comp.drop(columns='hall')


#now = datetime.datetime.now()
#strdate = now.strftime('%m:%d %H:%M:%S')
#test_comp.to_csv(f'/Users/mac2018/Applications/Collection/linkdata/{strdate}.csv', header=False, index=False)
#Test pattern output for error countermeasures
test_comp.to_csv(f'/Users/mac2018/Applications/Collection/linkdata/hakui.csv', header=False, index=False)

#4.8marge diff_topy.txt 
diff = pd.read_csv('diff_topy.txt',names=('posdai','max','difference','hall'))
#.update is It ’s very simple, but the consistency remains questionable.
#comp.update(diff)
#Marge'max'and'difference' with hall and posdai as keys
#'max','difference'columns delete
drop_comp = comp.drop(columns=['max','difference'])
merged_comp = pd.merge(drop_comp, diff, on=['posdai','hall'])
reindexed_merged_comp= merged_comp.reindex(columns=['posdai','Rotation','BB','RB','difference','max','model','date'])

#Overwrite hakui.csv with final output
reindexed_merged_comp.to_csv(f'/Users/mac2018/Applications/Collection/linkdata/hakui.csv', header=False, index=False)

quit()