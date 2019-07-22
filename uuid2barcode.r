##########################Environment##########################

# R-3.6
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("TCGAutils")

#R-3.5
source("https://bioconductor.org/biocLite.R")
biocLite("TCGAutils")
##########################Process##########################
setwd("manifest/")
library("TCGAutils")
files=dir()
# UUID tbl -> barcod list
result=list()
label=NULL
for(i in 1:length(files)){
    temp=unlist(strsplit(x=files[i],split="\\."))
    label=c(label,temp[2])
    d=read.table(files[i],sep="\t",header=T)
    tf=NULL
    for(j in 1:nrow(d)){
        this_row=UUIDtoBarcode(d[j,"id"], id_type = "file_id")
        tf=c(tf,this_row[,"cases.submitter_id"])
    }
    result[[i]]=tf
}
names(result)=label


unique(length(intersect(result[[3]],result[[2]])))
