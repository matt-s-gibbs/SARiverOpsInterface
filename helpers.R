library(SWTools)
library(zoo)
library(reshape2)
library(ggplot2)
library(dygraphs)

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
  
  A<-VeneerGetTSbyVariable("Constituents@DO@Downstream Flow Concentration",run=RunNo)
  A<-window(A,start=start(A)+warmup)
  DOT<-apply(A,2,function(x) sum(x<minDO)/length(x))
  
  #TO DO
  #derive velocity from volume
  
  Results<-cbind(DOT,FlowT)
  Results<-melt(Results)
  colnames(Results)<-c("Site","Variable","Value")
  Results$Value<-round(Results$Value*100,0)
  
  p<-ggplot(Results)+geom_tile(aes(x=Variable,y=Site,fill=Value))+
    scale_fill_distiller("Percent of Time\nless than threshold",palette = "RdYlGn",limits=c(0,100))
  return(p)
}

TimeseriesPlot<-function(var,runs)
{
  # Results<-NULL
  # for(run in runs)
  # {
  #   r<-RunLog[which(RunLog$RunName==run),]$RunNo
  #   A<-VeneerGetTSbyVariable(variable = var,run = r)
  #   A<-fortify(A,melt=TRUE)
  #   A$Run<-run
  #   Results<-rbind(Results,A)
  # }
  # p<-ggplot(Results)+geom_line(aes(x=Index,y=Value,colour=Run))+facet_grid(Series ~ .)
  # return(p)
  
  r<-RunLog[which(RunLog$RunName==runs[1]),]$RunNo
  A<-VeneerGetTSbyVariable(variable = var,run = r)
  p<-dygraph(A) %>% dyRangeSelector
  return(p)
}