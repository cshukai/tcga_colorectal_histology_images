eudist<-function(x1,x2,y1,y2){
  d=sqrt((x1-x2)^2+(y1-y2)^2)
  return(d)
}
##########################slid center###################
slide_dims=read.csv("dim.txt",header=T)
slide_dims=slide_dims[,-1]
slide_center=NULL
for(i in 1:nrow(slide_dims)){
  this_center_width=slide_dims[i,"width"]
  this_center_height=slide_dims[i,"height"]
  slide_center=rbind(slide_center,cbind(this_center_width,this_center_height))
}

slide_dims=cbind(slide_dims,slide_center)

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


##########################patch depth ###################

patch_list=patch_list[-which(patch_list[,2]=="ADI"),]
patch_list=patch_list[-which(patch_list[,2]=="BACK"),]
patch_list=patch_list[-which(patch_list[,2]=="DEB"),]

crop_size=225
eu_dists=NULL
for(i in 1:nrow(patch_list)){
  temp=unlist(strsplit(x=as.character(patch_list[i,1]),split="/"))
  locs=temp[length(temp)]  
  temp2=unlist(strsplit(x=locs,split="_"))
  this_x_start=as.integer(gsub(x=temp2[3],pattern=".tif",replacement=""))
  this_y_start=as.integer(temp2[2])
  this_x_end=this_x_start+crop_size
  this_y_end=this_y_start+crop_size
  this_patch_center_x=(this_x_start+this_x_end)/2
  this_patch_center_y=(this_y_start+this_y_end)/2
  this_barcode=temp[10]
  this_slide_center_x=slide_dims[which(slide_dims[,"barcode"]==this_barcode),"this_center_width"]
  this_slide_center_y=slide_dims[which(slide_dims[,"barcode"]==this_barcode),"this_center_height"]
  this_distance=eudist(this_patch_center_x,this_slide_center_x,this_patch_center_y,this_slide_center_y)
  eu_dists=c(eu_dists,this_distance)
}
patch_list=cbind(patch_list,eu_dists)
