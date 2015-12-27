# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

library(caret)
library(corrgram)
library(ggplot2)
library(reshape)
library(randomForest)
library(googleVis)

train <- read.csv("./data/train.csv")
test <- read.csv("./data/test.csv")

# Preprocess train data - scale all numeric variables
train.2 <- train[,-c(1,2,3)]

pp_hpc <- preProcess(train.2, method = c("scale"))
train.3 <- predict(pp_hpc, newdata = train.2)

train.3$QUART <- train$QUART
train.3$SALES <- train$SALES

train.c <- train.3
train.c$QUART <- as.numeric(train.c$QUART)
train.c$YEAR <- as.numeric(train$YEAR)

# Preprocess test data - scale all numeric variables
test.2 <- test[,-c(1,2,3)]
test.3 <- predict(pp_hpc, newdata = test.2)
test.3$QUART <- test$QUART

shinyServer(function(input, output) {

################################################################################
# Event handling
modelTrained <- eventReactive(input$goButton, {
        dat <- train.3
        columns <- c(input$columns, "SALES")
        columns <- columns[columns != "YEAR"]

        # Keep the selected columns
        dat <- dat[, columns, drop = FALSE]
        set.seed(5271)
        fit <- train(SALES ~ ., dat, method = input$model)
        summary(fit)
})        

modelForecasted <- eventReactive(input$goButton, {
        dat <- train.3
        columns <- c(input$columns, "SALES")
        columns <- columns[columns != "YEAR"]
        # Keep the selected columns
        dat <- dat[, columns, drop = FALSE]
        set.seed(5271)
        fit <- train(SALES ~ ., dat, method = input$model)
        res1 <- predict(fit, newdata = dat)
        
        dat <- test.3
        columns <- input$columns
        columns <- columns[columns != "YEAR"]
        dat <- dat[, columns, drop = FALSE]
        res2 <- predict(fit, newdata = dat)
        c(res1, res2)
})        

modelName <- eventReactive(input$goButton, {
        paste("Trained model", input$model, "with", length(input$columns)-1, "predictors")
})        
################################################################################
# Left panel        
# Check boxes
output$choose_columns <- renderUI({
# Get the data set with the appropriate name
        colnames <- names(train[,-1])
# Create the checkboxes and select them all by default
        checkboxGroupInput("columns", "Choose predictors", 
                choices  = colnames,
                selected = colnames)
        })

output$choose_model <- renderUI({
        selectInput("model", "Choose model", c("lm", "rf"))
})

output$textModel <- renderText({
        modelName()
})

        
# Main panel   

# Train data
output$train_table <- renderGvis({
        if (is.null(input$columns))
                return()

        dat <- train
        columns <- c(input$columns, "SALES")
        dat <- dat[, columns, drop = FALSE]
        gvisTable(dat)         
})

# Test data        
output$test_table <- renderGvis({
        if (is.null(input$columns))
                return()
        
        dat <- test
        dat <- dat[, input$columns, drop = FALSE]
        gvisTable(dat)         
})
#output$test_table <- renderTable({
#        if (is.null(input$columns))
#                return()
        
#        dat <- test
#        dat <- dat[, input$columns, drop = FALSE]
#        dat                
#})

# Correlation plot        
output$corrPlot <- renderPlot({
        if (is.null(input$columns))
                return()
        
        columns <- c(input$columns, "SALES")
        corrgram(train.c[, columns], order=FALSE, 
                lower.panel=panel.ellipse, upper.panel=panel.pie, 
                text.panel=panel.txt)
})

# Model summary
output$summaryModel <- renderPrint({
        modelTrained()
})

# Plot predictions
output$modelPlot <- renderPlot({
        ext_for <- modelForecasted()
        sales <- ts(train$SALES, start = c(2011, 1), frequency = 4)
        hw_object<-HoltWinters(sales)
        forecast<-predict(hw_object,  n.ahead=5,  prediction.interval=T,  level=.95)
        
        for_values<-data.frame(time=round(time(forecast), 3),  
                               value_forecast=as.data.frame(forecast)$fit,  
                               dev=as.data.frame(forecast)$upr-as.data.frame(forecast)$fit)
        
        for_values2<-data.frame(time=c(round(time(hw_object$x), 3), round(time(forecast), 3)), 
                                Model=ext_for)
        
        fitted_values<-data.frame(time=round(time(hw_object$fitted), 3), 
                                  value_fitted=as.data.frame(hw_object$fitted)$xhat)
        
        actual_values<-data.frame(time=round(time(hw_object$x), 3), Actual=c(hw_object$x))
        
        graphset<-merge(actual_values,  fitted_values,  by='time', all=TRUE)
        graphset<-merge(graphset, for_values, all=TRUE, by='time')
        graphset<-merge(graphset, for_values2, by='time', all=TRUE)
        graphset[is.na(graphset$dev),  ]$dev<-0
        
        graphset$Holt_Winters<-c(rep(NA, nrow(graphset) - (nrow(for_values) + nrow(fitted_values))), fitted_values$value_fitted,  for_values$value_forecast)
        
        graphset.melt<-melt(graphset[, c('time', 'Actual', 'Holt_Winters', 'Model')], id='time')
        
        p<-ggplot(graphset.melt,  aes(x=time,  y=value)) + 
                geom_ribbon(data=graphset, aes(x=time, y=Holt_Winters, ymin=Holt_Winters - dev,  ymax=Holt_Winters + dev),  alpha=.2,  fill='green') + 
                geom_line(aes(colour=variable), size=1) + 
                geom_vline(xintercept=max(actual_values$time),  lty=2) + 
                xlab('Time') + ylab('Value') + 
                theme(legend.position='bottom') + 
                scale_colour_hue('')
        print(p)
})
  
    
})
