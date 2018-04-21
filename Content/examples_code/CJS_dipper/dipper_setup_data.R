load('dipperData.RData')
## We will over-ride the x_inits from the .RData file

make_state_data_and_inits <- function(CH) {
    capture_history_2_states <- function(CH) {
        iOnes <- which(CH == 1)
        iFirstOne <- min(iOnes)
        iLastOne <- max(iOnes)
        ans <- CH
        ans[iFirstOne:iLastOne] <- 1
        ans[ans == 0] <- NA
        ans
    }
    states_2_state_inits <- function(states) {
        ans <- states
        iLastOne <- max(which(states == 1))
        ans[states==1] <- NA
        if(iLastOne < length(states)) {
            years_alive <- rgeom(1, 0.6)
            ans[(iLastOne+1):length(states)] <- 0
            ans[(iLastOne+1):(min(iLastOne + 1 + years_alive, length(states)))] <- 1
        }
        ans
    }
    remove_first_one <- function(states) {
        states[min(which(states==1))] <- NA
        states
    }
    states <- t(apply(CH, 1, capture_history_2_states))
    states_inits <- t(apply(states, 1, states_2_state_inits))
##    states_inits <- t(apply(states_inits, 1, remove_first_one))
##    states <- t(apply(states, 1, remove_first_one))
    list(data = states, inits = states_inits)
}

x_data_and_inits <- make_state_data_and_inits(y)

dipper_constants <- list(k=k, nind=nind, first=first)
dipper_data      <- list(y=y, x = x_data_and_inits$data)
dipper_inits     <- list(phi=0.6, p=0.9, x=x_data_and_inits$inits)
