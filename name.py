#namecube.py
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

comp = pd.read_csv('tmp.txt',names=('dai','Rotation','BB','RB','difference','max','machine'))

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

now = datetime.datetime.now()
strdate = now.strftime('%m:%d %H:%M:%S')
comp.to_csv(f'../{strdate}.csv', header=False, index=False)

if (comp.isnull().values.sum() != 0):
	print ("Missing value")
	print (comp.shape)
else:
	print ("OK")
	print (comp.shape)
quit()