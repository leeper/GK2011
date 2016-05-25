# packages
library("foreign")
library("car")

# load data
dat <- read.dta("gaineskuklinski-ajps2011.dta")
dat <- data[!is.na(data$sept_pho), ] # remove respondents with missing treatment data

# treatment variable
dat$cond.rand <- recode(dat$sept_pho,"'assigned positive flyers'=1;'assigned negative flyers '=-1;'assigned no flyers'=0;'opportunity to choose flyers'=9")
dat$cond.rand <- recode(as.numeric(dat$cond.rand),"1=3;2=1;3=2;4=9") #converting to numeric recodes -1=1;0=2;1=3;9=4; this recodes to final condition numbers

# clean up variable labels
dat$cond.choice <- gsub(",'"," ",dat$v1478_a) 
dat$cond.choice <- recode(data$cond.choice,'"yes  i ll look at the positive flyers."=1;"yes  i ll look at the negative flyers."=-1;"no thanks  i ll skip the flyers."=0')

# Temporary Conditions
#1=Randomized Control
#2=Randomized Pro Flyer
#3=Randomized Con Flyer
#4=Choice Control
#5=Choice Pro Flyer
#6=Choice Con Flyer

dat$conditions <- ifelse(dat$cond.rand == 9, dat$cond.choice, dat$cond.rand)

dat$tr <- ifelse(dat$conditions == 1, 2,
                 ifelse(dat$conditions == 3, 1,
                        ifelse(dat$conditions == 4, 4,
                               ifelse(dat$conditions == 6, 3, NA_real_))))
# subset data to exclude "pro" conditions
dat <- dat[!is.na(dat$tr), ]
# Final Conditions
#1=Randomized Con Flyer
#2=Randomized Control
#3=Choice Con Flyer
#4=Choice Control

# partyID
#'strong democrat'=1;
#'not very strong democrat'=.67;
#'lean democrat'=.33;
#'independent'=0;
#'lean republican'=-.33;
#'not very strong republican'=-.67;
#'strong republican'=-1;
# recode 'not sure' and NAs to 0/independent
dat$partyid <- recode(as.numeric(dat$scap8),"1=1;2=.67;3=.33;4=0;5=-.33;6=-.67;7=-1;8=0;NA=0")

# outcomes
dat$therm.mccain <- (as.numeric(dat$v1479_a)-1)/100 #rescaled 0-1; conversion to numeric adds 1 to 0-100 scale; 112 missing obs (no DKs)
dat$therm.obama <- (as.numeric(dat$v1480_a)-1)/100 #rescaled 0-1; conversion to numeric adds 1 to 0-100 scale; 107 missing obs (no DKs)

# subset for sharing
tmp <- na.omit(dat[, c("tr", "therm.obama", "therm.mccain", "pid")])

# rescale to match reported results
ajps$therm.obama <- 100*ajps$therm.obama
ajps$therm.mccain <- 100*ajps$therm.mccain

pmean <- function(x) sprintf("%0.1f", mean(x))
cbind(
    # Democrats
    aggregate(cbind(therm.mccain, therm.obama) ~ tr, data = tmp[tmp$pid == 1, ], FUN = pmean)[, 1:3],
    n_dem = aggregate(therm.obama ~ tr, data = tmp[tmp$pid == 1, ], FUN = length)[, 2],
    # Republicans
    aggregate(cbind(therm.mccain, therm.obama) ~ tr, data = tmp[tmp$pid == -1, ], FUN = pmean)[, 2:3],
    n_rep = aggregate(therm.obama ~ tr, data = tmp[tmp$pid == -1, ], FUN = length)[, 2]
)

ajps <- tmp

save(ajps, file = "ajps.RData")
