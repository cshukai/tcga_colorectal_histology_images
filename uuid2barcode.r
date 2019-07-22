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
for(i in 1:length(files)){
    temp=unlist(strsplit(x=files[i],split="\\."))
    this_type=temp[2]
    d=read.table(files[i],sep="\t",header=T)
    
}
UUIDtoBarcode("c5354db6-6d87-46e4-8e10-d1493e7226a7", id_type = "file_id")
