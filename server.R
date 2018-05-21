library(SWTools)

server <- function(input, output) {
  
  output$RunSource <- renderText({
    input$RunSource #run when button is clicked
    VeneerRunSource(InputSet = input$InputSet)
  })
  
  
}