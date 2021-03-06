#' @title estimate
#' @aliases estimate
#' @description Estimators for Hybrid Experiments
#' @param rand An integer or logical vector specifying whether each observation is from the random (1) or self-selection (0) arm of the experiment.
#' @param tr An integer or logical vector specifying whether each observation was treated (1) or control (0), regardless of the arm of the experiment.
#' @param y A numeric vector specifying outcome values.
#' @param iterations An integer specifying the number of bootstrap iterations used to estimate standard errors.
#' @details The package provides R implementations of the treatment effect estimators for hybrid (self-selection) experiments, as developed by Gaines and Kuklinski (2011). These functions estimate local average treatment effects for unobserved population subgroups inclined and disinclined to be treated, as revealed by a three-condition (two-arm) experimental design. In the design, participants are randomly assigned to one of three conditions: 1) treatment (T), 2) control (C), or 3) self-selection (S) of treatment or control. The design enables the estimation of three treatment effects:
#' \enumerate{
#'   \item First, the sample average treatment effect is estimated from conditions (1) and (2) as:\\
#'           \eqn{\hat{t} = \bar{Y}_{T} - \bar{Y}_{C}}
#'   \item The effect for those inclined to choose treatment is given by:\\
#'           \eqn{\hat{t}_s = \frac{\bar{Y}_{S} - \bar{Y}_{C}}{\hat{\alpha}}}
#'         where \eqn{\hat{\alpha}} is the observed proportion of individuals in group S that choose T (rather than C).
#'   \item The effect for those disinclined to choose treatment (or, equivalently, inclined to choose control) is given by:\\
#'            \eqn{\hat{t}_n = \frac{\bar{Y}_{T} - \bar{Y}_{S}}{1-\hat{\alpha}}}
#' }
#' By definition, the sample average treatment effect is an average of the other two effects.
#' @references Brian J. Gaines and James H. Kuklinski, (2011), "Experimental Estimation of Heterogeneous Treatment Effects Related to Self-Selection," \emph{American Journal of Political Science} 55(3): 724-736.
#' @return A data.frame containing the following variables:
#' \itemize{
#' \item \code{Effect}, a character vector of effect names (\dQuote{t}, \dQuote{t_s}, \dQuote{t_n}, \dQuote{naive})
#' \item \code{Estimate}, a numeric vector of effect estimates
#' \item \code{SE}, a numeric vector of bootstrapped standard errors
#' \item \code{t}, a t-statistic for the effect
#' \item \code{p}, a two-tailed p-value
#' }
#' The return value will also carry an attribute \dQuote{alpha}, indicating the estimated proportion \eqn{\alpha}.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' # create fake data
#' set.seed(12345)
#' d <- 
#' data.frame(rand = c(rep(1, 200), rep(0, 100)),
#'            tr = c(rep(0, 100), rep(1, 100), rep(0, 37), rep(1, 63)),
#'            y = c(rnorm(100), rnorm(100) + 1, rnorm(37), rnorm(63) + 3))
#' 
#' # estimate effects
#' estimate(rand = d$rand, tr = d$tr, y = d$y)
#' @importFrom stats sd pt
#' @seealso \code{\link{ajps}}
#' @export
estimate <- function(rand, tr, y, iterations = 5e3L) {
    
    # define estimators
    ## sate
    sate <- function(t, c) {
        mean(t) - mean(c)
    }
    ## alpha
    alpha <- function(st, sc) {
        (length(st)/length(c(st, sc)))
    }
    ## t_s
    t_s <- function(s, c, alpha) {
        (mean(s) - mean(c))/alpha
    }
     
    ## t_n
    t_n <- function(t, s, alpha) {
        (mean(t) - mean(s))/(1-alpha)
    }
    
    ## naive
    naive <- function(st, sc) {
        mean(st) - mean(sc)
    }
    
    # perform estimation
    te <- sate(y[rand == 1 & tr == 1], y[rand == 1 & tr == 0])
    a <- alpha(y[rand == 0 & tr == 1], y[rand == 0 & tr == 0])
    tes <- t_s(y[rand == 0], y[rand == 1 & tr == 0], a)
    ten <- t_n(y[rand == 1 & tr == 1], y[rand == 0], a)
    nv <- naive(y[rand == 0 & tr == 1], y[rand == 0 & tr == 0])
    
    # bootstrap standard errors
    ses <- replicate(iterations, {
        s <- sample(1:length(rand), length(rand), TRUE)
        alphatmp <- alpha(y[rand[s] == 0 & tr[s] == 1], y[rand[s] == 0 & tr[s] == 0])
        c(
          # SATE
          sate(y[rand[s] == 1 & tr[s] == 1], y[rand[s] == 1 & tr[s] == 0]),
          # t_s
          t_s(y[rand[s] == 0], y[rand[s] == 1 & tr[s] == 0], alphatmp),
          # t_n
          t_n(y[rand[s] == 1 & tr[s] == 1], y[rand[s] == 0], alphatmp),
          # naive
          naive(y[rand[s] == 0 & tr[s] == 1], y[rand[s] == 0 & tr[s] == 0])
          )
    })
    
    # output
    out <- list(Effect = c("t", "t_s", "t_n", "naive"),
                Estimate = c(te, tes, ten, nv),
                SE = c(sd(ses[1,]), sd(ses[2,]), sd(ses[3,]), sd(ses[4,]) ))
    out[["t"]] <- out[["Estimate"]]/out[["SE"]]
    dfs <- c(length(y[rand == 1]),
             length(y[(rand == 0) | (rand == 1 & tr == 0)]),
             length(y[(rand == 0) | (rand == 1 & tr == 1)]),
             length(y[rand == 0]))
    out[["p"]] <- 2*pt(abs(out[["t"]]), df = dfs - 1, lower.tail = FALSE)
    structure(out,
              class = "data.frame",
              row.names = 1:4,
              means = c(y_t = mean(y[rand == 1 & tr == 1]), 
                        y_c = mean(y[rand == 1 & tr == 0]),
                        y_s = mean(y[rand == 0]),
                        y_st = mean(y[rand == 0 & tr == 1]),
                        y_sc = mean(y[rand == 0 & tr == 01])),
              alpha = a)
}
