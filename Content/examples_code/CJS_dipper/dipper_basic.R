source("dipper_setup_data.R")

library(nimble)
## dipper (with latent states, suitable for jags)
dipper_code <- nimbleCode({
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    for (i in 1:nind) {
   ##     x[i, first[i]] <- 1
        for (t in (first[i] + 1):k) {
            mu_x[i, t] <- phi * x[i, t-1]
            mu_y[i, t] <- p * x[i, t]
            x[i, t] ~ dbin(mu_x[i, t], 1)
            y[i, t] ~ dbin(mu_y[i, t], 1)
        }
    }
})

dipper_info <- list(code=dipper_code,
                   constants=dipper_constants,
                   data=dipper_data,
                   inits=dipper_inits)

## dipper_basic_comparison <- compareMCMCs(
##     dipper_info,
##     MCMCdefs = list(
##         nim_slice_p_phi = quote({
##             MCMCconf <- configureMCMC(Rmodel)
##             MCMCconf$removeSamplers(c("p","phi"))
##             MCMCconf$addSampler("p", type = "slice")
##             MCMCconf$addSampler("phi", type = "slice")
##             MCMCconf
##         })),
##     MCMCs = c("jags", "nimble", "nim_slice_p_phi"),
##     monitors = c("phi", "p"),
##     niter = 10000,
##     burnin = 1000,
##     summary = FALSE)

## make_MCMC_comparison_pages(dipper_basic_comparison,
##                            dir = "dipper_basic_comparison",
##                            modelNames = "dipper_basic")

## browseURL(file.path("dipper_basic_comparison", "dipper_basic.html"))
