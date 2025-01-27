#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  verbatimTextOutput("summary"),
  tableOutput("table")
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  output$distPlot <- renderPlot({
    output$sumarry <- renderPrint({
      dataset <- get(input$dataset, "package:datasets")
      summary(dataset)
    })
  })

  output$table <- renderTable({
    dataset <- get(input$dataset, "package:datasets")
    dataset
  })
}

# Run the application
shinyApp(ui = ui, server = server)
