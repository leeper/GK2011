# Gaines and Kuklinski (2011) Estimators for Hybrid Experiments

**GK2011** is a package for providing implementations of the treatment effect estimators for hybrid (self-selection) experiments, as developed by Gaines and Kuklinski (2011).

These functions estimate local average treatment effects for unobserved population subgroups inclined and disinclined to be treated, as revealed by a three-condition (two-arm) "hybrid" experimental design. In the design, participants are randomly assigned to one of three conditions: 1) treatment (T), 2) control (C), or 3) self-selection (S) of treatment or control. The design enables the estimation of four treatment effects:

 1. The sample average treatment effect,
 2. The effect for those inclined to choose treatment,
 3. The effect for those disinclined to choose treatment (or, equivalent, to inclined to choose control), and
 4. The naive difference in the outcome between those who chose treatment rather than control.



## Code Examples

The only function is `estimate()`, which provides a simple interface for estimating all effects:


```r
library("GK2011")

# create fake data
set.seed(12345)
d <- 
data.frame(rand = c(rep(1, 200), rep(0, 100)),
           tr = c(rep(0, 100), rep(1, 100), rep(0, 37), rep(1, 63)),
           y = c(rnorm(100), rnorm(100) + 1, rnorm(37), rnorm(63) + 3))

# estimate effects
estimate(rand = d$rand, tr = d$tr, y = d$y)
```

```
##   Effect   Estimate        SE         t            p
## 1      t  0.8000359 0.2076146  3.853467 1.570643e-04
## 2    t_s  2.5374464 0.3327255  7.626245 9.735505e-13
## 3    t_n -2.1582576 0.5848236 -3.690442 2.889546e-04
## 4  naive  2.9034906 0.3065426  9.471736 1.554308e-15
```

The response structure is a data.frame containing the name of each effect, the effect estimate, and bootstrapped standard error.

### Gaines and Kuklinski's data

A small example dataset is included that contains treatment and outcome data from Gaines and Kuklinski's (2011) study. The following code replicate the main descriptive results from Table 2 of their paper:


```r
data(ajps)
pmean <- function(x) sprintf("%0.1f", mean(x))
cbind(
  # Democrats
  aggregate(cbind(therm.mccain, therm.obama) ~ tr, data = ajps[ajps$pid == 1, ], FUN = pmean)[, 1:3],
  n_dem = aggregate(therm.obama ~ tr, data = ajps[ajps$pid == 1, ], FUN = length)[, 2],
  # Republicans
  aggregate(cbind(therm.mccain, therm.obama) ~ tr, data = ajps[ajps$pid == -1, ], FUN = pmean)[, 2:3],
  n_rep = aggregate(therm.obama ~ tr, data = ajps[ajps$pid == -1, ], FUN = length)[, 2]
)
```

```
##   tr therm.mccain therm.obama n_dem therm.mccain therm.obama n_rep
## 1  1         27.1        80.9    53         79.2        22.4    56
## 2  2         30.6        76.7    65         81.3        28.0    54
## 3  3         27.9        77.9    47         76.0        24.8    34
## 4  4         25.6        82.0    68         81.4        24.6    63
```

The paper reports four main sets of experimental results, separating the experiment by outcome (feeling thermometers for Obama and McCain) and by respondents' party identification (Democrats and Republicans).


Here are effects for McCain among Democrats:


```r
with(ajps[ajps$pid == 1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.mccain)
})
```

```
##   Effect    Estimate       SE          t         p
## 1      t  -3.5175617 4.735196 -0.7428544 0.4590587
## 2    t_s -10.0114566 9.744498 -1.0273958 0.3056205
## 3    t_n   0.9708657 7.138275  0.1360084 0.8919784
## 4  naive   2.2546934 4.826405  0.4671579 0.6412786
```

Here are effects for McCain among Republicans:


```r
with(ajps[ajps$pid == -1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.mccain)
})
```

```
##   Effect   Estimate       SE          t         p
## 1      t -2.1177249 3.419383 -0.6193296 0.5369916
## 2    t_s -5.0217865 8.877852 -0.5656533 0.5724746
## 3    t_n -0.5504535 4.673361 -0.1177853 0.9063932
## 4  naive -5.4444444 3.845384 -1.4158389 0.1600589
```

Here are effects for Obama among Democrats:


```r
with(ajps[ajps$pid == 1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.obama)
})
```

```
##   Effect  Estimate       SE          t         p
## 1      t  4.201451 4.458794  0.9422843 0.3479887
## 2    t_s  8.762684 9.338501  0.9383394 0.3493344
## 3    t_n  1.048835 6.703290  0.1564657 0.8758550
## 4  naive -4.040989 4.675241 -0.8643381 0.3892172
```

Here are effects for Obama among Republicans:


```r
with(ajps[ajps$pid == -1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.obama)
})
```

```
##   Effect   Estimate        SE           t         p
## 1      t -5.5522487  5.085318 -1.09181929 0.2773200
## 2    t_s -9.4531590 13.110036 -0.72106281 0.4719932
## 3    t_n -3.4469955  7.068427 -0.48766092 0.6264927
## 4  naive  0.1774043  5.689454  0.03118125 0.9751897
```


## Installation

[![CRAN](https://www.r-pkg.org/badges/version/GK2011)](https://cran.r-project.org/package=GK2011)
[![Build Status](https://travis-ci.org/leeper/GK2011.png?branch=master)](https://travis-ci.org/leeper/GK2011)
[![codecov.io](https://codecov.io/github/leeper/GK2011/coverage.svg?branch=master)](https://codecov.io/github/leeper/GK2011?branch=master)

This package is not yet on CRAN. To install the latest development version you can pull directly from GitHub:

```R
if(!require("remotes")){
    install.packages("remotes")
}
remotes::install_github("leeper/GK2011")
```


## References

Brian J. Gaines and James H. Kuklinski, (2011), "Experimental Estimation of Heterogeneous Treatment Effects Related to Self-Selection," *American Journal of Political Science* 55(3): 724-736, doi:10.1111/j.1540-5907.2011.00518.x.
