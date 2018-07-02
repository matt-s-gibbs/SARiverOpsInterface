library(shiny)
library(SWTools)
library(plotly)
library(dygraphs)
library(rhandsontable)

# Define UI for application that draws a histogram
ui <- fluidPage(
  navbarPage("SA River Ops",
             tabPanel("Config",
                     "Not sure what this is yet, maybe select QSA setting/function values or something?\nShow schematic - maybe not, got the model open..."
                      ),
             
             tabPanel("Structures",
                    sidebarLayout(
                      sidebarPanel(
                          selectInput("Structures","Structures:",
                                    choices=Structures$Node),
                          h4("Notes"),
                          p("Right click to add or remove rows."),
                          p("Click the column name (Date) to sort in order. This will happen automatically when passed to the model."),
                          p("Source will extrapolate if it needs to, so make sure the start and end points cover the run period, or that the first and last segments are flat."),
                          p("If running over a calendar year, include points for 31 Dec and 1 Jan.")
                                     ),
                          mainPanel(rHandsontableOutput("tbl"),
                                    actionButton('writeSourceTable', 'Update Model'),
                                    plotlyOutput("StructurePlot",height="100%")
                                   )
                                 )
                      ),
    
             tabPanel("Run Model",
                      fluidPage(
                        fluidRow(
                          column(4,
                                 h4("Select Input Set"),
                                 selectInput("InputSet","Input Set:",
                                             choices=VeneerGetInputSets()$Name)
                                 ),
                          column(4,"empty"
                          ),
                          column(4,
                                 h4("Run Model"),
                                 textInput("RunName","Run Name"),
                                 actionButton("RunSource","Run!"),
                                 textOutput("SourceReturn")
                                 )
                                 )
                                )
                      ),
             tabPanel("Summary Results",
                      sidebarLayout(
                        sidebarPanel(
                          wellPanel(
                            h4("Select Run"),
                          selectInput("SummaryResults","Results:",
                                      choices="No Source runs available")
                          ),
                          wellPanel(
                          h4("Set Thresholds"),
                          numericInput("minQ", "Minimum Flow (ML/d):", 2500, min = 0, max = 80000),
                          numericInput("minDO", "Minimum DO (mg/L):", 2, min = 0, max = 12),
                          numericInput("maxSalt", "Maximum Salinity (mg/L):", 360 , min = 0, max = 480),
                          numericInput("warmup", "Warmup - intial period to ignore (days):", 30, min = 0, max = 365)
                          )#,
                        ),
                        mainPanel(
                          plotlyOutput("SummaryPlot",height="100%")
                        )
                       )),
             
             tabPanel("Time Series",
                      sidebarLayout(
                        sidebarPanel(
                          radioButtons("TimeseriesVariable","Variables:",
                                      choices="No Source runs available"),
                          checkboxGroupInput("TimeseriesResults","Results:",
                                      choices="No Source runs available")
                          #TODO could add sites to be able to turn some off. make all selected with selected.
                        ),
                        mainPanel(
                          uiOutput("plots")
                      )
                      )
             )
  )
)
