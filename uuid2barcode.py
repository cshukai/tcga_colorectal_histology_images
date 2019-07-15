import json
import os
import pandas
import grequests
import asyncio

uuids=os.listdir('/storage/htc/nih-tcga/wholeslides/coad')
file_endpt = 'https://api.gdc.cancer.gov/legacy/files/'
########################################################


def save2Df(rslist,df,urls):
    successList=[v for i,v in enumerate(rslist) if v != None and v.status_code!=429] # nontype and 429 returend is failure
     
    for idx,obj in enumerate(successList):
        temp=obj.content.decode('utf8')
        this_json=json.loads(temp.replace("'", '"'))
        thisrow={'data_type':'image','uuid':this_json['data']['file_id']  ,'barcode': this_json['data']['file_name']}
        df =df.append(thisrow)
    #continuing the rest
    successIdx=[i for i,v in enumerate(rslist) if v != None and v.status_code!=429]
    if(len(successIdx)>0):
        allIndexSet=set(list(range(len(urls))))
        successIdxSet=set(successIdx)
        failedIdx=list(allset.difference(successIdxSet))
        return(failedIdx)
    else:
        return 0 
def fireBulkRequest(urls):
    rs = (grequests.get(u) for u in urls)
    rslist=grequests.map(rs)
    return(rslist)
##########################################################
    
df=pandas.DataFrame(columns=['data_type','uuid', 'barcode'])

urls=[]
for i,uuid in enumerate(uuids) :
    urls.append(file_endpt + uuid)

counter=1
rslist=fireBulkRequest(urls)
sleep(30)
failedIdx=save2Df(rslist,df,urls)
while counter!=0:
    if(failedIdx==0):
        counter=0
    else:
        urls = [urls[i] for i in failedIdx]
        rslist=fireBulkRequest(urls)
        sleep(30)
        failedIdx=save2Df(rslist,df,urls)

    

df.to_csv(path="coad.barcode.csv")
