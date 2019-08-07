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
  up_bounary=min(ys)
  bottom_boundary=max(ys)
  center_x=(left_boundary+right_boundary)/2
  center_y=(up_bounary+bottom_boundary)/2
  
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

