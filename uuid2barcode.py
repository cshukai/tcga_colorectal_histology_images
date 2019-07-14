import json
import os
import pandas
import grequests
import asyncio

loop = asyncio.get_event_loop()
uuids=os.listdir('/storage/htc/nih-tcga/wholeslides/coad')
file_endpt = 'https://api.gdc.cancer.gov/legacy/files/'

def getAgainIfstillMissing(x):
     l=[i for i,v in enumerate(x) if v == None]
     if len(l)>0:
       urlss = [urls[i] for i in l]
       loop.call_later(5,fireBulkRequest(urlss))

def fireBulkRequest(urls):
    rs = (grequests.get(u,timeout=100) for u in urls)
    x=grequests.map(rs)
    loop.call_later(5,getAgainIfstillMissing(x))

if __name__ == '__main__':
    loop.call_soon(fireBulkRequest)
    loop.run_forever()

    
df=pandas.DataFrame(columns=['uuid', 'barcode'])

urls=[]
for i,uuid in enumerate(uuids) :
    urls.append(file_endpt + uuid)


rs = (grequests.get(u,timeout=10) for u in urls)
grequests.map(rs)

df.to_csv(path="coad.barcode.csv")
