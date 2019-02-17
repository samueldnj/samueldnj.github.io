
library(kableExtra)
library(dplyr)
library(RColorBrewer)

# Set NAs to - signs
options(knitr.kable.NA = '-')

growthData <- read.csv( "./baby-growth.csv", header = TRUE,
                        stringsAsFactors = FALSE ) %>%
              mutate( date = as.Date(date),
                      height = as.numeric(height),
                      weight = as.numeric(weight),
                      j = julian.Date( 
                                x = date, 
                                origin = as.Date("2018-01-02") ) + 1,
                      j = as.integer(j) ) %>%
              dplyr::select( j, height, weight )

 # Pull each value
  d <- as.integer(growthData$j)
  h <- as.numeric(growthData$height)
  w <- as.numeric(growthData$weight)


  # set up par
  par(mfrow  = c(2,1), oma = c(3,3,2,2), mar = c(0,2,0,2) )

  # First, plot height
  # Get indices where height exists
  hIdx <- which(!is.na(h))
  plot( x = range(d), y = range(h,na.rm = T), axes = F, 
        type = "n" )
    axis( side = 2, las = 1 )
    mtext( side = 2, text = "Height (cm)", line = 3)
    box()
    lines( x = d[hIdx], y = h[hIdx], lwd = 2, lty = 1 )
    points( x = d, y = h, cex = 2, pch = 16 )
    lines( loess.smooth(x = d[hIdx], y = h[hIdx], span = 100, degree = 2 ),      col = "red", lty = 2, lwd = 2 )

  # Now weight
  # Get indices where weight exists
  wIdx <- which(!is.na(w))
  plot( x = range(d), y = range(w,na.rm = T), axes = F, 
        type = "n" )
    axis( side = 2, las = 1 )
    mtext( side = 2, text = "Weight (kg)", line = 3)
    axis( side = 1)
    mtext( side = 1, text = "Julian Day Since Birthday", line = 2)
    box()
    lines( x = d[wIdx], y = w[wIdx], lwd = 2, lty = 1 )
    points( x = d, y = w, cex = 2, pch = 16 )
    lines( loess.smooth(x = d[wIdx], y = w[wIdx], span = 100, degree = 2 ),      col = "red", lty = 2, lwd = 2 )

    mtext( side = 3, text = "Height and Weight Data", font = 2,
            outer = TRUE )


# First, create a function to calculate the 
# height at a given day d. Pars and D values
# are separated as pars are estimated model
# parameters only
vonB <- function( d = 1, 
                  pars = c( H_1 = 62.5, 
                            H_2 = 74.5, 
                            K = 0.25/365 ), 
                  D = c(100,365) )
{
  # Recover pars
  H_1 <- pars[1]
  H_2 <- pars[2]
  K   <- pars[3]

  # Recover D values
  D_1 <- D[1]
  D_2 <- D[2]
  
  # Run calculation
  H_d <- H_1 + (H_2 - H_1) * (exp(-K*D_1) - exp(-K*d)) /( exp(-K*D_1) - exp(-K*D_2) )

  # Return H_d
  return(H_d)
}

H <- vonB( d = 1:7300 )

plot( x = 1:7300, y = H, type = "l", las = 1,
      xlab = "Age (days)", ylab = "Height (cm)",
      col = "red" )
  points( growthData$j, growthData$height, pch = 16,
          col = "grey40", cex = .7 )

vonB_negLogPost <- function(  theta = c( logH_1 = log(62.5), 
                                         logH_2 = log(74.5), 
                                         logK = log(0.25/365),
                                         logsigma = -1 ),
                              data = growthData,
                              D = c(100,365),
                              H2Prior = c(74.5, 74.5) )
{
  # Exponentiate leading pars of vonB
  lpars <- exp(theta[1:3])

  # uncertainty in the observations
  sigma <- exp(theta["logsigma"])

  # Calculate expected observations in a new column
  # of the data frame, then residuals,
  # and then the negative-log-likelihood (with
  # normalising scalar omitted)
  data <- data %>%
          mutate( expHeight = sapply( X = j, FUN = vonB, pars = lpars, D = D),
                  resid = expHeight - height,
                  negloglik = 0.5 * resid^2/sigma^2 )
  # Calculate observation NLL and H2 NLP
  nll     <- sum(data$negloglik, na.rm = T)
  nlp_H2  <- 0.5 * (lpars[2] - H2Prior[1])^2/H2Prior[2]^2

  browser()

  objFun  <- nll + nlp_H2

  return(objFun)
}
