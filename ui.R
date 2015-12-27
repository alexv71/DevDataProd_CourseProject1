
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(markdown)

shinyUI(fixedPage(

title = "Sales forecasting",
titlePanel(
        h1("Sales Forecasting")
),
fixedRow(
        column(2, style = "background-color:#dddddd;",
                br(),
                uiOutput("choose_columns"),
                uiOutput("choose_model"), 
                actionButton("goButton", "Train model"),
                br(),br(),
                strong(textOutput('textModel')),
                br(),br(),
                tags$head(tags$style("#textModel{color: red; font-style: italic;}"))
        ),
        column(10, 
                tabsetPanel(
                tabPanel("Getting started", 
                         includeMarkdown("README.md")
                ),
                tabPanel("Data", 
                        h4("Train set"),
                        htmlOutput("train_table") ,
                        h4("Test set"),
                        htmlOutput("test_table")
                ),
                tabPanel("Pairs correlations", 
                        plotOutput("corrPlot", width="700", height = "670")
                ),
                tabPanel("Model summary", 
                        br(),
                        verbatimTextOutput('summaryModel')
                ),
                tabPanel("Forecast plot", 
                        br(),
                        plotOutput("modelPlot")
                ))
        )
)))
