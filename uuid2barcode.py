#python2
#import requests
import json
import os
import pandas
import grequests



uuids=os.listdir('coad')
file_endpt = 'https://api.gdc.cancer.gov/legacy/files/'
df=pandas.DataFrame(columns=['uuid', 'barcode'])

urls=[]
for i,uuid in enumerate(uuids) :
    urls.append(file_endpt + uuid)

rs = (grequests.get(u) for u in urls)
x=grequests.map(rs) # x is a list
nonetype_idx=
#        x=response.json()
#        y=x['data']['file_name']
#        barcode="-".join(y.split("-")[0:3])
#        df.loc[i]=uuid+barcode
df.to_csv(path="coad.barcode.csv")
