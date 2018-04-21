---
title: "Introduction to using NIMBLE models"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Models are objects in R

# Get and set values


```r
pump$lambda
```

```
##  [1]  9.430  1.570  6.290 12.600  0.524  3.140  0.105  0.105  0.210  1.050
```

```r
pump$lambda[3] <- 100
pump$lambda
```

```
##  [1]   9.430   1.570 100.000  12.600   0.524   3.140   0.105   0.105
##  [9]   0.210   1.050
```

# Simulate values

Simulation means:

* Draw values of stochastic nodes
* Calculate values of deterministic nodes


```r
pump$lambda
```

```
##  [1]   9.430   1.570 100.000  12.600   0.524   3.140   0.105   0.105
##  [9]   0.210   1.050
```

```r
pump$simulate('lambda[1:5]')
pump$lambda
```

```
##  [1]  9.430  1.570  6.290 12.600  0.524  3.140  0.105  0.105  0.210  1.050
```

# Calculate values and log probabilities 

Calculation means:

* Calculate and store log probabilities of stochastic nodes
* Calculate values of deterministic nodes
* Return the sum of log probabilities of stochastic nodes


```r
pump$calculate(c('lambda[1:5]', 'theta[1:5]'))
```

```
## [1] -0.5
```

# Query the graph structure


```r
pump$getDependencies('lambda[1:5]')
```

```
##  [1] "lambda[1]" "lambda[2]" "lambda[3]" "lambda[4]" "lambda[5]"
##  [6] "x[1]"      "x[2]"      "x[3]"      "x[4]"      "x[5]"
```

# Model-generic programming

Say we want a function that simulates all parts of a model that depend on some input nodes and then returns the corresponding summed log probability.  I will call this part of the model "downstream".


```r
simulate_downstream <- function(model, nodes) {
  downstream_nodes <- model$getDependencies(nodes, downstream = TRUE)
  model$simulate( downstream_nodes )
  logProb <- model$calculate( downstream_nodes )
  logProb
}
```
Notice that this function will work with *any* model and *any* set of input nodes.
