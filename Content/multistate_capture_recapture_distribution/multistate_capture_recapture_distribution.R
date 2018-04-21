## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'multi_state_CR_orchids'))
source("orchids_basic.R")
source("orchids_dDHMM.R")
setwd(cur_dir)


## ----basic-code----------------------------------------------------------
orchids_code

## ----MCMC-basic----------------------------------------------------------
parameters <- c("s", "psiV", "psiF", "psiD")
## One could argue to monitor the underlying random variables instead:
## parameters <- c('a', 'b', 'c', 's')


orchids_basic_comparison <- compareMCMCs(
    orchids_info,
    MCMCs = c("jags", "nimble"),
    monitors = parameters,
    niter = 20000,
    burnin = 2000,
    summary = FALSE
)

make_MCMC_comparison_pages(orchids_basic_comparison,
                           dir = "orchids_basic_comparison",
                           modelNames = "orchids_basic")

browseURL(file.path("orchids_basic_comparison", "orchids_basic.html"))


## ----inspect-basic-MCMC--------------------------------------------------
orchids_basic_comparison[[1]]$summary

## ----orchids-DHMM-model--------------------------------------------------
orchids_DHMM_code

## ----dDHMM---------------------------------------------------------------
dDHMMorchid <- nimbleFunction(
    run = function(x = double(1),    ## Observed capture (state) history
                   length = double(),## length of x (needed as a separate param for rDHMM)
                   prior = double(1),## 
                   Z = double(2),
                   T = double(3),
                   log = integer(0, default = 0)) {
        pi <- prior
        logL <- 0
        for(t in 1:length) {
            Zpi <- Z[x[t], ] * pi
            sumZpi <- sum(Zpi)
            logL <- logL + log(sumZpi)
            if(t != length)   pi <- (T[,,t] %*% asCol(Zpi) / sumZpi)[ ,1]
        }
        returnType(double())
        if(log) return(logL)
        return(exp(logL))
    }
)

rDHMMorchid <- nimbleFunction(
    run = function(n = integer(),
        length = double(), prior = double(1),
        Z = double(2),
        T = double(3)) {
        if(n != 1) print('should only specify n=1 in rDHMM() distribution')
        print('STILL NEED TO WRITE THE rDHMM() METHOD!')
        returnType(double(1))
        return(numeric(length, value = 1))
    }
)


## ----orchids-DHMM--------------------------------------------------------
orchids_DHMM_comparison <- compareMCMCs(
    list(code = orchids_DHMM_code,
         data = orchids_DHMM_data,
         constants = orchids_DHMM_constants,
         inits = orchids_DHMM_inits()), 
    MCMCs = c("nimble"),
    monitors = parameters,
    niter = 20000,
    burnin = 2000,
    summary = FALSE
)

orchids_DHMM_comparison[[1]] <- rename_MCMC_comparison_method("nimble", "nimbleDHMM", orchids_DHMM_comparison[[1]])


orchids_all_comparison <- combine_MCMC_comparison_results(orchids_basic_comparison[[1]],
                                                         orchids_DHMM_comparison[[1]],
                                                         name = "orchids_MCMC_comparison")

make_MCMC_comparison_pages(orchids_all_comparison,
                           dir = "orchids_all_comparison",
                           modelNames = "orchids")

## browseURL(file.path("orchids_all_comparison", "orchids.html"))


