# Gaines and Kuklinski (2011) Estimators for Hybrid Experiments #

**GK2011** is a package for providing implementations of the treatment effect estimators for hybrid (self-selection) experiments, as developed by Gaines and Kuklinski (2011).

These functions estimate local average treatment effects for unobserved population subgroups inclined and disinclined to be treated, as revealed by a three-condition (two-arm) "hybrid" experimental design. In the design, participants are randomly assigned to one of three conditions: 1) treatment (T), 2) control (C), or 3) self-selection (S) of treatment or control. The design enables the estimation of four treatment effects:

 1. The sample average treatment effect,
 2. The effect for those inclined to choose treatment,
 3. The effect for those disinclined to choose treatment (or, equivalent, to inclined to choose control), and
 4. The naive difference in the outcome between those who chose treatment rather than control.



## Code Examples ##

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
##   Effect   Estimate         SE         t
## 1      t  0.8000359 0.08413274   9.50921
## 2    t_s  2.5374464 0.12514084  20.27672
## 3    t_n -2.1582576 0.20110420 -10.73204
## 4  naive  2.9034906 0.21775390  13.33382
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
##   Effect    Estimate       SE          t
## 1      t  -3.5175617 2.190063 -1.6061460
## 2    t_s -10.0114566 6.121120 -1.6355596
## 3    t_n   0.9708657 2.444609  0.3971455
## 4  naive   2.2546934 1.270427  1.7747517
```

Here are effects for McCain among Republicans:


```r
with(ajps[ajps$pid == -1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.mccain)
})
```

```
##   Effect   Estimate       SE          t
## 1      t -2.1177249 4.986360 -0.4247036
## 2    t_s -5.0217865 9.682214 -0.5186609
## 3    t_n -0.5504535 2.418357 -0.2276146
## 4  naive -5.4444444 4.185957 -1.3006451
```

Here are effects for Obama among Democrats:


```r
with(ajps[ajps$pid == 1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.obama)
})
```

```
##   Effect  Estimate       SE          t
## 1      t  4.201451 8.485957  0.4951064
## 2    t_s  8.762684 1.905155  4.5994593
## 3    t_n  1.048835 6.035416  0.1737800
## 4  naive -4.040989 2.340061 -1.7268729
```

Here are effects for Obama among Republicans:


```r
with(ajps[ajps$pid == -1, ], {
  estimate(rand = tr %in% 1:2, tr = tr %in% c(1,3), y = therm.obama)
})
```

```
##   Effect   Estimate        SE           t
## 1      t -5.5522487  6.611357 -0.83980468
## 2    t_s -9.4531590  7.709704 -1.22613780
## 3    t_n -3.4469955  8.345105 -0.41305595
## 4  naive  0.1774043 15.775211  0.01124576
```


## Installation ##

[![CRAN](http://www.r-pkg.org/badges/version/GK2011)](http://cran.r-project.org/package=GK2011)
[![Build Status](https://travis-ci.org/leeper/GK2011.png?branch=master)](https://travis-ci.org/leeper/GK2011)
[![codecov.io](http://codecov.io/github/leeper/GK2011/coverage.svg?branch=master)](http://codecov.io/github/leeper/GK2011?branch=master)

This package is not yet on CRAN. To install the latest development version you can pull directly from GitHub:

```R
if(!require("ghit")){
    install.packages("ghit")
}
ghit::install_github("leeper/GK2011")
```


## References ##

Brian J. Gaines and James H. Kuklinski, (2011), "Experimental Estimation of Heterogeneous Treatment Effects Related to Self-Selection," *American Journal of Political Science* 55(3): 724-736, doi:10.1111/j.1540-5907.2011.00518.x.
