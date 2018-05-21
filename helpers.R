library(zoo)
warmup<-30 #change to input variable
minQ<-2500

A<-VeneerGetTSbyVariable("Flow")
A<-window(A,start=start(A)+warmup)
FlowT<-apply(A,2,function(x) sum(x<minQ)/length(x))

A<-VeneerGetTSbyVariable("Constituents@DO@Downstream Flow Concentration")
