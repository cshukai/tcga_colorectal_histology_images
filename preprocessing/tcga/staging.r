######################staging information processing#####
clic=read.csv("COAD_clinical_patients.csv",header=T)
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
