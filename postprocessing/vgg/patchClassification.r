setwd("../Downloads/")
d=read.csv("predOutcome.txt",header=F)
##########################viz#########################
tiss.lbl=names(table(d[,2]))
barplot(height=table(d[,2]),names.arg =tiss.lbl,ylim=c(0,1500)) # overview across all patients
##########################cohort##########################
allbarcode=NULL
allpatient=NULL
for (i in 1:nrow(d)){
  tcga_barcode =unlist(strsplit(as.character(x=d[i,1]),split="/"))[10]
  temp=unlist(strsplit(x=tcga_barcode,split="-")) # first three for a patient id
  this_patient=paste(temp[1:3],collapse="-")
  allpatient=c(allpatient,this_patient)
  allbarcode=c(allbarcode,tcga_barcode)
  
}
unique(allpatient)
