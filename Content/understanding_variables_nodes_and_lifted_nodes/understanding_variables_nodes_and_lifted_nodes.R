## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(igraph)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
source(file.path(nimble_course_dir,
                 'examples_code',
                 'pump',
                 'pump_model.R'))
source(file.path(nimble_course_dir,
                 'general_code',
                 'drawGraph.R'))

## ----pump-model----------------------------------------------------------
pumpCode

## ----use-variable--------------------------------------------------------
pump$lambda ## accesses the variable lambda
pump$lambda[3:5] ## accesses elements of lambda
## which may or may not be one node or multiple nodes.

## ----use-node------------------------------------------------------------
pump[['lambda[3]']] ## accesses node lambda[3]

## ----see-nodes-----------------------------------------------------------
pump$getNodeNames()

## ----expand-nodes--------------------------------------------------------
pump$expandNodeNames('lambda')
pump$expandNodeNames('lambda[2:5]')

## ----see-variables-------------------------------------------------------
pump$getVarNames()

## ----see-varInfo---------------------------------------------------------
pump$getVarInfo('lambda')
pump$getVarInfo('theta')

## ----see-logProb---------------------------------------------------------
pump$logProb_theta ## These were all initialized with the same value
pump$logProb_x

## ----getLogProb----------------------------------------------------------
pump$getLogProb('x[3]')

## ----see-logProb-vars----------------------------------------------------
pump$getVarNames(includeLogProb = TRUE)

## ---- deps-graph, fig.cap=""---------------------------------------------
## function drawGraph is defined in the R file for this module
drawGraph(pump, colorBy = pump$getDependencies('theta[3]'))

## ----stoch-determ-data-fig, fig.cap = ""---------------------------------
drawGraph(pump, colorBy = "stochDetermData")

## ------------------------------------------------------------------------
## deterministic nodes
pump$getNodeNames(determOnly = TRUE)
## all stochastic nodes
pump$getNodeNames(stochOnly = TRUE, includeData = TRUE)
## non-data stochastic nodes
pump$getNodeNames(stochOnly = TRUE, includeData = FALSE)

## ----top-latent-end-fig, fig.cap=""--------------------------------------
drawGraph(pump, 'topLatentEnd')

## ------------------------------------------------------------------------
pump$getNodeNames(topOnly = TRUE)   #salmon
pump$getNodeNames(latentOnly = TRUE)  #cyan
pump$getNodeNames(endOnly = TRUE)    #plum

## ----stoch-latent-nodes--------------------------------------------------
pump$getNodeNames(stochOnly = TRUE, latentOnly = TRUE)

## ----RHSonly-------------------------------------------------------------
pump$getNodeNames(includeRHSonly = TRUE)

## ----see-RHSonly---------------------------------------------------------
## Move "t" from constants to data
pumpData2 <- c(pumpData, pumpConsts['t'])
pumpConsts2 <- pumpConsts['N']
pump2 <- nimbleModel(
    pumpCode,
    data = pumpData2,
    constants = pumpConsts2
)
pump2$getNodeNames()
pump2$getNodeNames(includeRHSonly = TRUE)

## ------------------------------------------------------------------------
pump$topologicallySortNodes(c('x[1:3]','beta','theta[1:3]'))

## ------------------------------------------------------------------------
pump$getDependencies('theta[3]')

## ------------------------------------------------------------------------
pump$getDependencies('theta[3]', determOnly = TRUE)

## ---- echo=FALSE, fig.cap=""---------------------------------------------
drawGraph(pump, pump$getDependencies('theta[3]', determOnly = TRUE))

## ------------------------------------------------------------------------
args(pump$getDependencies)
## or help(modelBaseClass)

## ---- fig.cap=""---------------------------------------------------------
m1 <- nimbleModel(
    nimbleCode({
        tau ~ dunif(0, 100)
        x ~ dnorm(0, tau) #by default, tau is a precision
    }))
plot(m1$getGraph())
m1$getNodeNames()

## ---- eval = FALSE-------------------------------------------------------
## nimbleCode({
##     tau ~ dunif(0, 100)
##     lifted_d1_over_sqrt_oPtau_cP <- 1/sqrt(tau)
##     x ~ dnorm(0, sd = lifted_d1_over_sqrt_oPtau_cP) #by default, tau is a precision
## }))

## ---- eval = FALSE-------------------------------------------------------
## m1$calculate(c('tau','x')) ## Wrong: the lifted node is being neglected

## ---- eval = FALSE-------------------------------------------------------
## m1$calculate( m1$getDependencies('tau') )

## ---- fig.cap=""---------------------------------------------------------
m2 <- nimbleModel(
    nimbleCode({
        a ~ dnorm(0, 1)
        b ~ dnorm(a + 1, 1)
    }))
plot(m2$getGraph())
m2$getNodeNames()

