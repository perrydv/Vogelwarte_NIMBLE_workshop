source("dipper_setup_data.R")

library(nimble)
## dipper (with latent states, suitable for jags)
dipper_code_CJS <- nimbleCode({
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    for (i in 1:nind) {
        ## year after first seen is first[i] + 1
        ## One pain in nimble: We need to ensure we don't
        ## use a scalar where a vector was expected, so
        ## we use first[i]:k instead of (first[i]+1):k.
        y[i, first[i]:k] ~ dCJS(survival = phi, capture = p, l = k-first[i]+1)
    }
})

dCJS <- nimbleFunction(
    run = function(x = double(1),    ## standard name for the "data"
                   survival = double(),
                   capture = double(),
                   l = double(),
                   log = integer(0, default = 0) ## required log argument
                   ) {
        probAliveGivenHistory <- 1
        ## logProbData will be the final answer
        logProbData <- 0
        if(l == 1) {  ## l==1 should not occur, but be defensive
            return(logProbData) 
        }
        for(t in 2:l) {
            ## probAlive is P(Alive(t) | x(1)...x(t-1))
            ## probAliveGivenHistory is (Alive(t-1) | x(1)...x(t-1))
            probAlive <- probAliveGivenHistory * survival
            if(x[t] == 1) {
                ## ProbThisObs = P(x(t) | x(1)...x(t-1))
                probThisObs <- probAlive * capture
                probAliveGivenHistory <- 1
            } else {
                probAliveNotSeen <- probAlive * (1-capture)
                probThisObs <- probAliveNotSeen + (1-probAlive)
                probAliveGivenHistory <- probAliveNotSeen / probThisObs
            }
            logProbData <- logProbData + log(probThisObs)
        }
        if(log) return(logProbData)
        return(exp(logProbData))
        returnType(double())
    }
)

rCJS <- nimbleFunction(
    run = function(n = integer(),
                   survival = double(),
                   capture = double(),
                   l = double()) {
        returnType(double(1))
        return(numeric(l))
    }
)

dipper_data_CJS <- dipper_data[c('y')]
dipper_inits_CJS <- dipper_inits[c('phi','p')]

dipper_info_CJS <- list(code=dipper_code_CJS,
                        constants=dipper_constants,
                        data=dipper_data_CJS,
                        inits=dipper_inits_CJS)

## dipper_CJR_comparison <- compareMCMCs(
##     dipper_info_CJS,
##     MCMCdefs = list(
##         nimCJS_slice_p_phi = quote({
##             MCMCconf <- configureMCMC(Rmodel)
##             MCMCconf$removeSamplers(c("p","phi"))
##             MCMCconf$addSampler("p", type = "slice")
##             MCMCconf$addSampler("phi", type = "slice")
##             MCMCconf
##         })),
##     MCMCs = c("nimble", "nimCJS_slice_p_phi"),
##     monitors = c("phi", "p"),
##     niter = 10000,
##     burnin = 1000,
##     summary = FALSE)

## dipper_CJR_comparison[[1]] <- rename_MCMC_comparison_method("nimble", "nimbleCJS", dipper_CJR_comparison[[1]])

## dipper_all_comparison <- combine_MCMC_comparison_results(dipper_basic_comparison[[1]],
##                                                          dipper_CJR_comparison[[1]],
##                                                          name = "dipper_MCMC_comparison")

## make_MCMC_comparison_pages(dipper_all_comparison,
##                            dir = "dipper_all_comparison",
##                            modelNames = "dipper")

## browseURL(file.path("dipper_all_comparison", "dipper.html"))

