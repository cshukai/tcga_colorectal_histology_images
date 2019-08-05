eudist<-function(x1,x2,y1,y2){
 d=sqrt((x1-x2)^2+(y1-y2)^2)
 return(d)
}

patch_list=read.csv("predOutcome.txt",header=F)
crop_size=225
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
                        
}
