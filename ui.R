library(shiny)
library(SWTools)

# Define UI for application that draws a histogram
ui <- fluidPage(
  navbarPage("SA River Ops",
             tabPanel("Config",
                     "Not sure what this is yet, maybe select QSA setting/function values or something?"
                      ),
             
             tabPanel("Structures",
                    sidebarLayout(
                      sidebarPanel(
                          selectInput("Structures","Structures:",
                                    choices=VeneerGetNodesbyType("Weir")) #filter to remove some (e.g. woolshed?)
                                     ),
                          mainPanel("Piecewise"
                                   )
                                 )
                      ),
    
             tabPanel("Run Model",
                      fluidPage(
                        fluidRow(
                          column(4,
                                 h3("Select Input Set"),
                                 selectInput("InputSet","Input Set:",
                                             choices=VeneerGetInputSets()$Name)
                                 ),
                          column(4,
                                 h3("Set Thresholds"),
                                 numericInput("minQ", "Minimum Flow (ML/d):", 2500, min = 0, max = 80000),
                                 numericInput("criticalDO", "Cricitcal DO (mg/L):", 2, min = 0, max = 12),
                                 numericInput("adverseDO", "Adverse DO (mg/L):", 4, min = 0, max = 12),
                                 numericInput("warmup", "Warmup - intial period to ignore (days):", 30, min = 0, max = 365)
                          ),
                          column(4,
                                 h3("Run Model"),
                                 actionButton("RunSource","Run!"),
                                 textOutput('RunSource')
                                 )
                                 )
                                )
                      ),
             tabPanel("Summary Results"),
             
             tabPanel("Time Series")
  )
)
