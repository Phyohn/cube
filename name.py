#name.py
#python  -i
import cv2
import base64
import numpy as np
from PIL import Image
import io
import pandas as pd
import os
import pathlib
import datetime
import time
import platform

tmp = pd.read_csv('tmp.txt',names=('dai','Rotation','BB','RB','difference','max','machine','holl','date'))
#dailist series to df
posdai = tmp.loc[:,'dai'].unique()
tmp.insert(0,'posdai',posdai)
dailist = pd.read_csv('dailist.txt',names=('posdai','kuu'))
merged = pd.merge(tmp, dailist, how='outer')
reindexed = merged.reindex(columns=['posdai','Rotation','BB','RB','difference','max','machine'])
#fillna(0) float to int64 'machine'object0 dtype to str for replacement
fillnaed = reindexed.fillna(0)
comp = fillnaed.astype({'posdai': 'int64','Rotation':'int64','BB':'int64','RB':'int64','difference':'int64','max':'int64','machine':'str'})
#df.sort_values
comp = comp.sort_values('posdai')

#DailistRenameSequence
#pd.Series.unique()
defdai = comp.loc[:,'machine'].unique()

#series to df
defdaidf = pd.DataFrame(defdai)
defdaidf.insert(0,'namebank', defdai)
dainame = pd.read_csv('namebank.csv',names=('namebank','neoname'))
#drop_duplicates(subset=['namebank']
dainame = dainame.drop_duplicates(subset=['namebank'])
newdailist = pd.merge(defdaidf, dainame, how='outer')
newdailist = newdailist.reindex(columns=['namebank','neoname'])
newdailist.to_csv('./namebank.csv', header=False, index=False)


#to String conversion
dainame = pd.read_csv('namebank.csv', header=None)
#tolist
machinename = (dainame.iloc[:,0]).values.tolist()
newname = (dainame.iloc[:,1]).values.tolist()
#replace
comp = comp.replace(machinename,newname)

#y/n date today?
#y/Ndef
def yes_no_input():
	while True:
		choice = input("Please respond with 'today? yes' or 'no' [y/N]: ").lower()
		if choice in ['y', 'ye', 'yes']:
			return True
		elif choice in ['n', 'no']:
			return False
'''
datetime to date
'''
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

#now = datetime.datetime.now()
#strdate = now.strftime('%m:%d %H:%M:%S')
#comp.to_csv(f'/Users/mac2018/Applications/Collection/linkdata/{strdate}.csv', header=False, index=False)
comp.to_csv(f'/Users/mac2018/Applications/Collection/linkdata/hakui.csv', header=False, index=False)

quit()