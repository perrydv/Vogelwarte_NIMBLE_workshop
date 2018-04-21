CH <- as.matrix(read.table("orchids.txt", sep=" ", header = FALSE))
n_occasions <- dim(CH)[2]
## Compute vector with occasion of first capture
f <- numeric()
for (i in 1:dim(CH)[1]){f[i] <- min(which(CH[i,]!=0))}

## Modification for NIMBLE:
CH <- CH[which(f!=11), ]  ## remove all individuals not seen until the last occasion: They contribute no information and create problems for the dDHMM version.
## Reset f from the reduced CH
f <- numeric()
for (i in 1:dim(CH)[1])
    f[i] <- min(which(CH[i,]!=0))


## Recode CH matrix: note, a 0 is not allowed by WinBUGS!
## 1 = seen vegetative, 2 = seen flowering, 3 = not seen 
rCH <- CH  # Recoded CH 
rCH[rCH==0] <- 3 

## Function to create known latent states z 
known_state_ms <- function(ms, notseen){
    ## notseen: label for not seen 
    state <- ms 
    state[state==notseen] <- NA 
    for (i in 1:dim(ms)[1]){
        m <- min(which(!is.na(state[i,]))) 
        state[i,m] <- NA 
    }
    return(state) 
}
## Bundle data 
orchids_data <- list(y = rCH,
                  f = f,
                  n_occasions = dim(rCH)[2],
                  nind = dim(rCH)[1],
                  z = known_state_ms(rCH, 3)) 

ms_init_z <- function(ch, f){
   for (i in 1:dim(ch)[1]){ch[i,1:f[i]] <- NA}
   states <- max(ch, na.rm = TRUE)
   known.states <- 1:(states-1)
   v <- which(ch==states)
   ch[-v] <- NA
   ch[v] <- sample(known.states, length(v), replace = TRUE)
   return(ch)
   }

## Initial values 
orchids_inits <- function(){
    list(s = runif((dim(rCH)[2]-1), 0, 1),
         z = ms_init_z(rCH, f)
         )}

orchids_DHMM_initZ <- array(c(1,0,0, ## column 1
             0,1,0, ## column 2, etc.
             0,0,1,
             0,0,1),
           c(3,4))
orchids_DHMM_constants <- list(f=f,
                               k=dim(rCH)[2],
                               nind=dim(rCH)[1],
                               prior=c(1/2,1/2,0,0),
                               Z=orchids_DHMM_initZ)
orchids_DHMM_data <- list(y = rCH)
orchids_DHMM_inits <- function() {
    list(s = runif((dim(rCH)[2]-1), 0, 1),
         a = rep(1,3),
         b = rep(1,3),
         c = rep(1,3))
}
