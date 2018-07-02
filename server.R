library(SWTools)
library(plotly)
library(dygraphs)

RunLog<<-data.frame(RunNo=integer(),RunName=character())
data <- reactiveValues()

source("helpers.R",local=TRUE)

server <- function(input, output,session) {
  
  ##############################
  #run model only when button clicked, update selection buttons for results, and return some logging info
  #############################
  observeEvent(input$RunSource,{
    output$SourceReturn<-renderText("Running Source Model")
    A<-VeneerRunSource(InputSet = input$InputSet)
    B<-UpdateLog(RunLog,input$RunName)
    
    updateSelectInput(session,"SummaryResults",choices = RunLog$RunName)
    updateCheckboxGroupInput(session,"TimeseriesResults",choices = RunLog$RunName)
    updateRadioButtons(session,"TimeseriesVariable",choices = VeneerGetTSVariables())
    
    output$SourceReturn<-renderText(paste(Sys.time(),A,B,sep="\n"))
  })
  
  ##############################
  # Table for updating scenario. Key of node and table names at the top of helpers.R
  #############################
  
  output$tbl=renderRHandsontable({
    Data<-data.frame(VeneerGetPiecewise(Structures[which(Structures$Node==input$Structures),]$Table))
    colnames(Data)<-c("Date","Level")
    year<-substr(Sys.Date(),1,4)
    Data$Date<-as.Date(Data$Date,origin=as.Date(paste0(year,"-01-01"))-1)
    data$table<-Data
    rhandsontable(data$table) %>% hot_cols(columnSorting = TRUE)
  })
  
  
 
  # #updateSource
  observeEvent(input$writeSourceTable, {
    df<-as.data.frame(hot_to_r(input$tbl))
    df$Date<-as.numeric(df$Date)
   df[,1]<-df[,1]-as.numeric(as.Date(paste0(year,"-01-01"))-as.Date("1970-01-01")-1)
  # write.csv(df,"C:\\Source\\table.csv")
   VeneerSetPiecewise(df[order(df$Date),],Structures[which(Structures$Node==input$Structures),]$Table)

  })
  
  #plot the structure piecewise table
  
  pp<-eventReactive(input$writeSourceTable,{
    Data<-data.frame(VeneerGetPiecewise(Structures[which(Structures$Node==input$Structures),]$Table))
  colnames(Data)<-c("Date","Level")
  year<-substr(Sys.Date(),1,4)
  Data$Date<-as.Date(Data$Date,origin=as.Date(paste0(year,"-01-01"))-1)
  ggplot(Data)+geom_line(aes(x=Date,y=Level))
  })
  
  output$StructurePlot<-renderPlotly({
    pp()
  })
  
  
  #################################
  #plot the summary geom_tile() plot
  ###################################
  output$SummaryPlot<-renderPlotly({

      Variables<-c("Flow","Constituents@DO@Downstream Flow Concentration","Constituents@Salt@Downstream Flow Concentration")
      DisplayNames<-c("Minimum Flow","Dissolved Oxygen","Salinity")
      Thresholds<-c(input$minQ,input$minDO,input$maxSalt)
      Operators<-c("<","<",">") #operator to apply to test for failure
    
     RunNo<-RunLog[which(RunLog$RunName==input$RunName),]$RunNo
      
      Failed<-NULL
      names<-NULL
      for(i in 1:length(Variables))
      {
          #try to get results if they're there
          A<-VeneerGetTSbyVariable(Variables[i],run=RunNo)
          if(class(A)=="zoo")
          {
            A<-window(A,start=start(A)+input$warmup)
            sF<-apply(A,2,function(x) sum(do.call(Operators[i],list(x,Thresholds[i])))/length(x))
            Failed<-cbind(Failed,sF)
            names<-c(names,DisplayNames[i])
          }
      }
      
      colnames(Failed)<-names
      
      Failed<-melt(Failed)
      colnames(Failed)<-c("Site","Variable","value")
      
      Failed$value<-round(Failed$value*100,0)
      
      p<-ggplot(Failed)+geom_tile(aes(x=Variable,y=Site,fill=value))+
        scale_fill_distiller("Percent of Time\nless than threshold",palette = "RdYlGn",limits=c(0,100))
      
      #attempting to get auto height working, only hard coded in pixels seems to work.
      p<-ggplotly(p,height=800)
      # p$x$layout$width <- NULL
      # p$x$layout$height <- NULL
      # p$width <- NULL
      # p$height <- NULL
      
      return(p)
    })
    
  ###################################
  #dynamic number of plots for time series results 
  # based on https://gist.github.com/wch/5436415/
  ##################################
  
    output$plots <- renderUI({
      
      #collate the data for the selected conditions into a list
      A<-list()
       if(length(input$TimeseriesResults)>0)
       {
         for(i in input$TimeseriesResults)
        {
           #for the selected Variable, load each run into a list
             my_i <- i
             A[[my_i]]<-VeneerGetTSbyVariable(variable=input$TimeseriesVariable,run=RunLog[which(RunLog$RunName==my_i),]$RunNo)
             A[[my_i]]<-window(A[[my_i]],start=start(A[[my_i]])+input$warmup)
             
             #convert from zoo to data frame fix column select with sapply below. Store number of variables and dates
             if(my_i==input$TimeseriesResults[1])
              {
                Dates<-index(A[[my_i]])
                max_plots<-ncol(A[[my_i]])
             }
             A[[my_i]]<-as.data.frame(A[[my_i]])
        }
        
         # Call renderPlot for each one. Plots are only actually generated when they are visible on the web page.
        for (i in 1:max_plots) {
          # Need local so that each item gets its own number. Without it, the value
          # of i in the renderPlot() will be the same across all instances, because
          # of when the expression is evaluated.
          local({
            my_i <- i
            plotname <- paste("plot", my_i, sep="")
            mydata<-sapply(A,'[[',my_i)
            mydata<-zoo(mydata,Dates)
            #todo - fix main heading when only 1 location recorded, doesn't come through with VeneerGetTSbyVariable() names() not colnames()?
            output[[plotname]] <- renderDygraph(dygraph(mydata,group="results",main=names(A[[1]])[my_i])%>% dyRangeSelector)
          })
          
        }
        
        plot_output_list <- lapply(1:max_plots, function(i) { 
          plotname <- paste("plot", i, sep="")
          dygraphOutput(plotname)
        })
        
        # Convert the list to a tagList - this is necessary for the list of items to display properly.
        do.call(tagList, plot_output_list)
      }
      
      })
}