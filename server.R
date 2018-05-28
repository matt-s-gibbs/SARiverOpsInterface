library(SWTools)
library(plotly)
library(dygraphs)

RunLog<<-data.frame(RunNo=integer(),RunName=character())

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
  
  #################################
  #plot the summary geom_tile() plot
  ###################################
  output$SummaryPlot<-renderPlotly({
      SummaryPlot(input$SummaryResults,input$minQ,input$adverseDO,input$warmup)
    })
    
  ###################################
  #dynamic number of plots for time series results 
  # based on https://gist.github.com/wch/5436415/
  ##################################

  # Insert the right number of plot output objects when selected locations changed
  max_plots<-3
  
    output$plots <- renderUI({
      plot_output_list <- lapply(1:max_plots, function(i) { #max here
        plotname <- paste("plot", i, sep="")
        dygraphOutput(plotname)
      })
      
      # Convert the list to a tagList - this is necessary for the list of items to display properly.
      do.call(tagList, plot_output_list)
    })
    
    # Call renderPlot for each one. Plots are only actually generated when they are visible on the web page.
    A<-VeneerGetTSbyVariable()
    for (i in 1:max_plots) {
      # Need local so that each item gets its own number. Without it, the value
      # of i in the renderPlot() will be the same across all instances, because
      # of when the expression is evaluated.
      local({
        my_i <- i
        plotname <- paste("plot", my_i, sep="")
        output[[plotname]] <- renderDygraph(dygraph(A[,my_i],group="results",main=colnames(A)[my_i])%>% dyRangeSelector)
      })
    }
}