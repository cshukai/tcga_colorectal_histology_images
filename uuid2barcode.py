import json
import os
import grequests
import asyncio
import csv
from gevent import sleep

uuids=os.listdir('/storage/htc/nih-tcga/wholeslides/coad')
file_endpt = 'https://api.gdc.cancer.gov/legacy/files/'
########################################################


def save2Df(rslist,urls,iterator):
    successList=[v for i,v in enumerate(rslist) if v != None and  v.status_code==200] # nontype and 429 returend is failure
    if(len(successList)>0): 
        for idx,obj in enumerate(successList):
            temp=obj.content.decode('utf8')
            this_json=json.loads(temp.replace("'", '"'))
            print(idx)
            print("------")
            print(this_json)
            thisrow={'data_type':'image','uuid':this_json['data']['file_id']  ,'barcode': this_json['data']['file_name']}
            if (iterator==0):
                w = csv.DictWriter(csv_file, thisrow.keys())
                w.writeheader()
                w.writerow(thisrow)
            else :
                w.writerow(thisrow)
            iterator=iterator+1
    successIdx=[i for i,v in enumerate(rslist) if v != None and  v.status_code==200]
    if(len(successIdx)>0):
        allIndexSet=set(list(range(len(urls))))
        successIdxSet=set(successIdx)
        failedIdx=list(allIndexSet.difference(successIdxSet))
        return(failedIdx)
    else:
        return 0 

def fireBulkRequest(urls):
    isAllNone=True
    while isAllNone:
        rs = (grequests.get(u) for u in urls)
        rslist=grequests.map(rs)
        sleep(60)
        indices_none = [i for i, x in enumerate(rslist) if x is  None]
        if(len(indices_none)<len(urls)):
            isAllNone=False
    return(rslist)
##########################################################
    

urls=[]
for i,uuid in enumerate(uuids) :
    urls.append(file_endpt + uuid)

iterator=0
counter=1
#############################################################

rslist=fireBulkRequest(urls)
sleep(30)
    



with open('/storage/htc/nih-tcga/wholeslides/coad_uuidbarcode.csv','w') as csv_file:
    failedIdx=save2Df(rslist,urls,iterator)
    while counter!=0:
        if(failedIdx==0):
            print("here")
            counter=0
        else:
            urls = [urls[i] for i in failedIdx]
            rslist=fireBulkRequest(urls)
            sleep(30)
            failedIdx=save2Df(rslist,urls,iterator)

    

