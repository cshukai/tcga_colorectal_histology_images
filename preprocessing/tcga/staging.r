library(ggplot2)
setwd("../Downloads/")
#####################helper function##################
eudist<-function(x1,x2,y1,y2){
  d=sqrt((x1-x2)^2+(y1-y2)^2)
  return(d)
}


patch_list=read.csv("predOutcome.txt",header=F)
##########################cohort ###################
barcodes=NULL
for(i in 1:nrow(patch_list)){
  temp=unlist(strsplit(x=as.character(patch_list[i,1]),split="/"))
  barcodes=c(barcodes,temp[10])
}
unique(barcodes)

allpatient=NULL
for(i in 1:length(barcodes) ){
  temp=unlist(strsplit(x=barcodes[i],split="-")) # first three for a patient id
  this_patient=paste(temp[1:3],collapse="-")
  allpatient=c(allpatient,this_patient)
}  
unique(allpatient)


##########################invasion depth ###################
result=NULL
barcode_list=unique(barcodes) 
crop_size=225
for(j in 1:length(barcode_list)){
  this_patch_list=patch_list[grep(x=patch_list[,1],pattern=barcode_list[j]),]
  xs=NULL
  ys=NULL
  # get the estimated center of the whole tissue 
  for(i in 1:nrow(this_patch_list)){
    temp=unlist(strsplit(x=as.character(this_patch_list[i,1]),split="/"))
    locs=temp[length(temp)]  
    temp2=unlist(strsplit(x=locs,split="_"))
    this_x_start=as.integer(gsub(x=temp2[3],pattern=".tif",replacement=""))
    this_y_start=as.integer(temp2[2])
    this_x_end=this_x_start+crop_size
    this_y_end=this_y_start+crop_size
    this_patch_center_x=(this_x_start+this_x_end)/2
    this_patch_center_y=(this_y_start+this_y_end)/2
    xs=c(xs,this_patch_center_x)
    ys=c(ys,this_patch_center_y)
    
  }

  left_boundary=min(xs)
  right_boundary=max(xs)
  up_boundary=min(ys)
  bottom_boundary=max(ys)
  center_x=(left_boundary+right_boundary)/2
  center_y=(up_boundary+bottom_boundary)/2
  
  
  #compute distance between image tile and center
  eu_dists=NULL
  for(i in 1:nrow(this_patch_list)){
    temp=unlist(strsplit(x=as.character(this_patch_list[i,1]),split="/"))
    locs=temp[length(temp)]  
    temp2=unlist(strsplit(x=locs,split="_"))
    this_x_start=as.integer(gsub(x=temp2[3],pattern=".tif",replacement=""))
    this_y_start=as.integer(temp2[2])
    this_x_end=this_x_start+crop_size
    this_y_end=this_y_start+crop_size
    this_patch_center_x=(this_x_start+this_x_end)/2
    this_patch_center_y=(this_y_start+this_y_end)/2
    this_dist=eudist(this_patch_center_x,center_x,this_patch_center_y,center_y)
    eu_dists=c(eu_dists,this_dist)
    
  }
  this_patch_list=cbind(this_patch_list,eu_dists)
  result=rbind(result,this_patch_list)
}


# depth estimation
plot_list = list()
for(j in 1:length(barcode_list)){
  this_patch_list=result[grep(x=result[,1],pattern=barcode_list[j]),]
  this_patch_list=this_patch_list[-which(this_patch_list[,2]=="BACK"),]
  #this_patch_list=this_patch_list[union(union(union(which(this_patch_list[,2]=="MUC"),which(this_patch_list[,2]=="TUM")),which(this_patch_list[,2]=="MUS")),which(this_patch_list[,2]=="LYM")),]   
  colnames(this_patch_list)=c("path","type","distance")
  temp=unlist(strsplit(x=as.character(this_patch_list[1,1]),split="/"))
  p=ggplot(this_patch_list , aes(x=distance, fill=factor(type))) + geom_histogram()+ ggtitle(temp[10])
  plot_list[[j]] = p
}

pdf("plots.pdf")
for (i in 1:length(plot_list)) {
  print(plot_list[[i]])
}
dev.off()




######################staging information processing#####
clic=read.csv("COAD_clinical_patients.csv",header=T)
specimen=read.csv("COAD_Biospecimen_sample.csv",header=T)

t_class=NULL
n_class=NULL
#m_class=NULL
for(i in 1:nrow(clic)){ #not looking at metastasis at this point
  temp=unlist(strsplit(x=as.character(clic[i,"stage_event_tnm_categories"]),split=""))
  this_T=paste(temp[2:(grep(x=temp,pattern="N")-1)],collapse="")
  this_N=paste(temp[(grep(x=temp,pattern="N")+1):length(temp)],collapse="")
  if(length(grep(x=temp,pattern="M"))>0){
       this_N=substring(text=this_N,first=1,last=(regexpr(text=this_N,pattern="M")-1))
  }
  #this_M=temp[(grep(x=temp,pattern="M")+1):length(temp)]
  t_class=c(t_class,this_T)
  n_class=c(n_class, this_N)
  #m_class=c(m_class,this_M)
}


clic_stage=cbind(clic[,c("bcr_patient_barcode","stage_event_pathologic_stage","vital_status")],t_class,n_class)
patients=unique(allpatient)
clic_stage_img=clic_stage[which(clic_stage[,1] %in% patients),]
clic_stage_img_ti
