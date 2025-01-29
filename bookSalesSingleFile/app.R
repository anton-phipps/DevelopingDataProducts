library(shiny)
library(markdown)
library(MASS)

ui <- fluidPage(
  titlePanel("Swap Content Example"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("content", "Select the content to Display:",
        choices = list("README" = "readme", "Project" = "project")
      ),
      hr(),
      textInput("num_list", "Enter numbers actual sales numbers (comma-separated):", "1,2,3,4,5"),
      actionButton("fit", "Fit Gamma Distribution"),
      numericInput("point", "Enter point to calculate estimated percentage of sales above a certain value:", value = 3)
    ),
    mainPanel(
      conditionalPanel(
        condition = "input.content == 'project'",
        verbatimTextOutput("params"),
        verbatimTextOutput("percentage"),
        verbatimTextOutput("optimal_value"),
        plotOutput("gammaPlot")
      ),
      conditionalPanel(
        condition = "input.content == 'readme'",
        includeMarkdown("README.md")
      )
    )
  )
)

server <- function(input, output) {
  observeEvent(input$fit, {
    num_list <- as.numeric(unlist(strsplit(input$num_list, ",")))
    fit <- fitdistr(num_list, "gamma")

    output$params <- renderPrint({
      fit
    })

    output$percentage <- renderPrint({
      point <- input$point
      shape <- fit$estimate["shape"]
      rate <- fit$estimate["rate"]
      percentage <- 1 - pgamma(point, shape = shape, rate = rate)
      paste("Percentage of values greater than", point, ":", round(percentage * 100, 2), "%")
    })

    output$optimal_value <- renderPrint({
      shape <- fit$estimate["shape"]
      rate <- fit$estimate["rate"]
      objective_function <- function(x) {
        x * (1 - pgamma(x, shape = shape, rate = rate))
      }
      result <- optimize(objective_function, interval = c(0, max(num_list)), maximum = TRUE)
      sh <- fit$estimate["shape"]
      rt <- fit$estimate["rate"]
      perc <- 1 - pgamma(result$maximum, shape = sh, rate = rt)
      paste("Value that maximizes x * (1 - F(x)):", round(result$maximum, 2))
    })

    output$gammaPlot <- renderPlot({
      hist(num_list, probability = TRUE, main = "Gamma Distribution Fit", xlab = "Value")
      curve(dgamma(x, shape = fit$estimate["shape"], rate = fit$estimate["rate"]), add = TRUE, col = "blue")
    })
  })
}

shinyApp(ui = ui, server = server)
