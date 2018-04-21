## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)

## ----setup-section-------------------------------------------------------

## Original code from Section 6.4 for AHM

# 6.4 A slightly more complex N-mixture model with covariates
# ------------------------------------------------------------------------

# Choose sample sizes and prepare obs. data array y
set.seed(1)                   # So we all get same data set
M <- 100                      # Number of sites
J <- 3                        # Number of repeated abundance measurements
C <- matrix(NA, nrow = M, ncol = J) # to contain the observed data

# Create a covariate called vegHt
vegHt <- sort(runif(M, -1, 1)) # sort for graphical convenience

# Choose parameter values for abundance model and compute lambda
beta0 <- 0                    # Log-scale intercept
beta1 <- 2                    # Log-scale slope for vegHt
lambda <- exp(beta0 + beta1 * vegHt) # Expected abundance
plot(vegHt, lambda, type = "l", lwd = 3)  # Expected abundance

# Draw local abundance and look at data so far
N <- rpois(M, lambda)
points(vegHt, N)              # Add realized abundance to plot
table(N)

# Plot the true system state (Fig. left)
par(mfrow = c(1, 3), mar = c(5,5,2,2), cex.axis = 1.5, cex.lab = 1.5)
plot(vegHt, N, xlab="Vegetation height", ylab="True abundance (N)", frame = F, cex = 1.5)
lines(seq(-1,1,,100), exp(beta0 + beta1* seq(-1,1,,100)), lwd=3, col = "red")


# Create a covariate called wind
wind <- array(runif(M * J, -1, 1), dim = c(M, J))

# Choose parameter values for measurement error model and compute detectability
alpha0 <- -2                        # Logit-scale intercept
alpha1 <- -3                        # Logit-scale slope for wind
p <- plogis(alpha0 + alpha1 * wind) # Detection probability
#plot(p ~ wind, ylim = c(0,1))       # Look at relationship

# Take J = 3 abundance measurements at each site
for(j in 1:J) {
    C[,j] <- rbinom(M, N, p[,j])
}

# Plot observed data and effect of wind on det. probability (Fig. middle)
plot(wind, C/max(C), xlab="Wind", ylab="Scaled counts: C/max(C)", frame = F, cex = 1.5)
lines(seq(-1,1,,100), plogis(alpha0 + alpha1*seq(-1,1,,100)), lwd=3, col="red")


# Expected (lambda) and realized abundance (N) and measurements (C)
cbind(lambda=round(lambda,2), N=N, C1=C[,1], C2=C[,2], C3=C[,3])


# Create factors
time <- matrix(rep(as.character(1:J), M), ncol = J, byrow = TRUE)
hab <- c(rep("A", 33), rep("B", 33), rep("C", 34))  # assumes M = 100

## A section of original code for creating book figures has been removed here.

# Bundle data
win.data <- list(C = C, M = nrow(C), J = ncol(C), wind = wind, vegHt = vegHt, hab = as.numeric(factor(hab)), XvegHt = seq(-1, 1,, 100), Xwind = seq(-1, 1,,100) )
str(win.data)

## ----jags-section--------------------------------------------------------
# Specify model in BUGS language
cat(file = "model2.txt", "
model {
# Priors
for(k in 1:3){                # Loop over 3 levels of hab or time factors
   alpha0[k] ~ dunif(-10, 10) # Detection intercepts
   alpha1[k] ~ dunif(-10, 10) # Detection slopes
   beta0[k] ~ dunif(-10, 10)  # Abundance intercepts
   beta1[k] ~ dunif(-10, 10)  # Abundance slopes
}

# Likelihood
# Ecological model for true abundance
for (i in 1:M){
   N[i] ~ dpois(lambda[i])
   log(lambda[i]) <- beta0[hab[i]] + beta1[hab[i]] * vegHt[i]
   # Some intermediate derived quantities
   critical[i] <- step(2-N[i])# yields 1 whenever N is 2 or less
   z[i] <- step(N[i]-0.5)     # Indicator for occupied site
   # Observation model for replicated counts
   for (j in 1:J){
      C[i,j] ~ dbin(p[i,j], N[i])
      logit(p[i,j]) <- alpha0[j] + alpha1[j] * wind[i,j]
   }
}

# Derived quantities
Nocc <- sum(z[])         # Number of occupied sites among sample of M
Ntotal <- sum(N[])       # Total population size at M sites combined
Nhab[1] <- sum(N[1:33])  # Total abundance for sites in hab A
Nhab[2] <- sum(N[34:66]) # Total abundance for sites in hab B
Nhab[3] <- sum(N[67:100])# Total abundance for sites in hab C
for(k in 1:100){         # Predictions of lambda and p ...
   for(level in 1:3){    #    ... for each level of hab and time factors
      lam.pred[k, level] <- exp(beta0[level] + beta1[level] * XvegHt[k])
      logit(p.pred[k, level]) <- alpha0[level] + alpha1[level] * Xwind[k]
   }
}
N.critical <- sum(critical[]) # Number of populations with critical size
}")

# Initial values
Nst <- apply(C, 1, max)+1   # Important to give good inits for latent N
inits <- function() list(N = Nst, alpha0 = rnorm(3), alpha1 = rnorm(3), beta0 = rnorm(3), beta1 = rnorm(3))

# Parameters monitored
params <- c("alpha0", "alpha1", "beta0", "beta1", "Nocc", "Ntotal", "Nhab", "N.critical", "lam.pred", "p.pred") # could also estimate N, bayesian counterpart to BUPs before: simply add "N" to the list

# MCMC settings
nc <- 3   ;   ni <- 22000   ;   nb <- 2000   ;   nt <- 10

## ----run-mcmc, eval = FALSE----------------------------------------------
## # Call JAGS, time run (ART 1 min) and summarize posteriors
## system.time(out <- jags(win.data, inits, params, "model2.txt", n.chains = nc,
## n.thin = nt, n.iter = ni, n.burnin = nb, parallel = TRUE)
## )

