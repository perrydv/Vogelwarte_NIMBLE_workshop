load('dipperData.RData')

library(nimble)
## dipper (with latent states, suitable for jags)
code <- nimbleCode({
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    for (i in 1:nind) {
        x[i, first[i]] <- 1
        for (t in (first[i] + 1):k) {
            mu_x[i, t] <- phi * x[i, t-1]
            mu_y[i, t] <- p * x[i, t]
            x[i, t] ~ dbin(mu_x[i, t], 1)
            y[i, t] ~ dbin(mu_y[i, t], 1)
        }
    }
})
constants <- list(k=k, nind=nind, first=first)
data      <- list(y=y)
inits     <- list(phi=0.6, p=0.9, x=x_init)
dipper <- list(code=code, constants=constants, data=data, inits=inits)

dipper_basic <- compareMCMCs(
    dipper,
    MCMCs = c("jags", "nimble", "nimble_slice"),
    monitors = c("phi", "p"),
    niter = 10000,
    burnin = 1000,
    summary = FALSE)

make_MCMC_comparison_pages(dipper_basic,
                           dir = "comparison_results",
                           modelNames = "dipper_basic")

browseURL(Sys.glob(file.path("comparison_results", "dipper_basic.html")))
