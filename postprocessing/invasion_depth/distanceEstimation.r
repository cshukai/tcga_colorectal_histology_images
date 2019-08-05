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
 this_width=as.integer(gsub(x=temp2[3],pattern=".tif",replacement=""))
 this_height=as.integer(temp2[2])
 
}
