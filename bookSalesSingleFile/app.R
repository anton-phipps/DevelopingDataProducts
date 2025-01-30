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
      textInput("num_list", "Enter numbers actual sales numbers (comma-separated):",
                "9.75, 21.50, 0, 0, 14.50, 17.75, 20.0, 10.25, 7.25, 10.00, 20, 21.25, 14, 40.75, 8.50"),
      actionButton("fit", "Fit Gamma Distribution"),
      numericInput("point", "Enter point to calculate estimated percentage of sales above a certain value:", value = 3)
    ),
    mainPanel(
      conditionalPanel(
        condition = "input.content == 'project'",
        verbatimTextOutput("params"),
        verbatimTextOutput("percentage"),
        verbatimTextOutput("optimal_value"),
        verbatimTextOutput("profit_per_hundred"),
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
    num_list <- ifelse(num_list <= 0, 0.01, num_list)
    
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
      paste("Value that maximizes x * (1 - F(x)):", round(result$maximum, 2))
    })
    
    output$profit_per_hundred <- renderPrint({
      objective_function <- function(x) {
        x * (1 - pgamma(x, shape = fit$estimate["shape"], rate = fit$estimate["rate"]))
      }
      res <- optimize(objective_function, interval = c(0, max(num_list)), maximum = TRUE)
      percentage <- 1 - pgamma(res$maximum, shape =  fit$estimate["shape"], rate =  fit$estimate["rate"])
      paste("The estimated profit made from 100 units of sales is: $", round(percentage * res$maximum * 100, 2))
    })

    output$gammaPlot <- renderPlot({
      hist(num_list, probability = TRUE, main = "Gamma Distribution Fit", xlab = "Value")
      curve(dgamma(x, shape = fit$estimate["shape"], rate = fit$estimate["rate"]), add = TRUE, col = "blue")
    })
  })
}

shinyApp(ui = ui, server = server)
