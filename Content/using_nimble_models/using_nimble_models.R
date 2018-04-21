## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
source(file.path(nimble_course_dir,
                 'examples_code',
                 'pump',
                 'pump_model.R'))

## ---- get-set-values-----------------------------------------------------
pump$lambda
pump$lambda[3] <- 100
pump$lambda

## ---- simulate-----------------------------------------------------------
pump$lambda
pump$simulate('lambda[1:5]')
pump$lambda

## ---- calculate----------------------------------------------------------
pump$calculate(c('lambda[1:5]', 'theta[1:5]'))

## ---- graph-query--------------------------------------------------------
pump$getDependencies('lambda[1:5]')

## ---- generic-simulate---------------------------------------------------
simulate_downstream <- function(model, nodes) {
  downstream_nodes <- model$getDependencies(nodes, downstream = TRUE)
  model$simulate( downstream_nodes )
  logProb <- model$calculate( downstream_nodes )
  logProb
}

