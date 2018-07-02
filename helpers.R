library(SWTools)
library(zoo)
library(reshape2)
library(ggplot2)
library(dygraphs)

#Note no $ at the start of table names, like there is in Source
Structures<-data.frame(Node=c("Chowilla Regulator 254",
                               "Lock 6"),
                       Table=c("pw_CRLevel",
                               "pw_Lock6Level"))

UpdateLog<-function(RunLog,name)
{
  id<-which(RunLog$RunName==name)
  if(length(id)==0)
  {
    RunLog<<-rbind(RunLog,data.frame(RunNo=VeneerlatestRunNumber(),RunName=name))
    return(paste("New run",name,"added"))
  }else
  {
    RunLog[id,]$RunNo<<-VeneerlatestRunNumber()
    return(paste("Run",name,"overwritten"))
  }
}

#Function to show quick summary metrics for all outputs recorded
SummaryPlot<-function(name,minQ,minDO,warmup)
{
  RunNo<-RunLog[which(RunLog$RunName==name),]$RunNo
  A<-VeneerGetTSbyVariable("Flow",run=RunNo)
  A<-window(A,start=start(A)+warmup)
  FlowT<-apply(A,2,function(x) sum(x<minQ)/length(x))
  
  # A<-VeneerGetTSbyVariable("Constituents@DO@Downstream Flow Concentration",run=RunNo)
  # A<-window(A,start=start(A)+warmup)
  # DOT<-apply(A,2,function(x) sum(x<minDO)/length(x))
  # 
  #TO DO
  #derive velocity from volume
  
  
  Results<-data.frame(Site=names(FlowT),value=as.numeric(FlowT),Variable="Flow")
  
  # Results<-cbind(DOT,FlowT)
  # colnames(Results)<-c("Site","Variable","value")
  #Results<-melt(Results)
  
  Results$value<-round(Results$value*100,0)
  
  p<-ggplot(Results)+geom_tile(aes(x=Variable,y=Site,fill=value))+
    scale_fill_distiller("Percent of Time\nless than threshold",palette = "RdYlGn",limits=c(0,100))
  
  #attempting to get auto height working, only hard coded in pixels seems to work.
  p<-ggplotly(p,height=800)
  # p$x$layout$width <- NULL
  # p$x$layout$height <- NULL
  # p$width <- NULL
  # p$height <- NULL
  
  return(p)
}
