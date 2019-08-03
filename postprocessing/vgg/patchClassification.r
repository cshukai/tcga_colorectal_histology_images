setwd("../Downloads/")
d=read.csv("predOutcome.txt",header=F)
tiss.lbl=names(table(d[,2]))
barplot(height=table(d[,2]),names.arg =tiss.lbl,ylim=c(0,1500)) # overview across all patients
