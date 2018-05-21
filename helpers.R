library(SWTools)
library(zoo)
warmup<-30 #change to input variable
minQ<-2500
minDO<-2/1000

A<-VeneerGetTSbyVariable("Flow")
A<-window(A,start=start(A)+warmup)
FlowT<-apply(A,2,function(x) sum(x<minQ)/length(x))

A<-VeneerGetTSbyVariable("Constituents@DO@Downstream Flow Concentration")
#units are Units":"kg\/m³, need to fix in package
DOT<-apply(A,2,function(x) sum(x<minDO)/length(x))

#derive velocity from volume

#cbind(DOT,FlowT)
#melt
#ggplot shading by %age.