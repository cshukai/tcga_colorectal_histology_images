
# depth estimation
plot_list = list()
for(j in 1:length(barcode_list)){
  this_patch_list=result[grep(x=result[,1],pattern=barcode_list[j]),]
  this_patch_list=this_patch_list[union(union(union(which(this_patch_list[,2]=="MUC"),which(this_patch_list[,2]=="TUM")),which(this_patch_list[,2]=="MUS")),which(this_patch_list[,2]=="LYM")),]   
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
