##########################Environment##########################

# R-3.6
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("TCGAutils")

#R-3.5
source("https://bioconductor.org/biocLite.R")
biocLite("TCGAutils")
##########################Process##########################

UUIDtoBarcode("c5354db6-6d87-46e4-8e10-d1493e7226a7", id_type = "file_id")
