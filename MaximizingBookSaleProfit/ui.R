#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define UI for application that draws a histogram
fluidPage(

  # Application title
  titlePanel("Maximizing Book Sale Profit"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel({
      sliderInput("productionCost", label = "Book Production Cost ($)", min = 0, max = 40, value = 10, step = 0.25)
    }),

    # Show a plot of the generated distribution
    mainPanel({

    })
  )
)
