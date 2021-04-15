# # Install logitr package from github
# devtools::install_github('jhelvy/logitr')

# Load logitr package
library('logitr')

# Preview the yogurt data
head(yogurt)

yogurt_neg_price <- yogurt
yogurt_neg_price$price <- -1*yogurt$price

# ============================================================================
# Estimate homogeneous MNL models

# Run a MNL model in the Preference Space:
mnl_pref <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'hiland', 'yoplait', 'dannon')
)

# Get the WTP implied from the preference space model
wtp_mnl_pref <- wtp(mnl_pref, priceName = 'price')
wtp_mnl_pref

# Run a MNL model in the WTP Space using a multistart:
mnl_wtp <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('hiland', 'yoplait', 'dannon'),
  priceName  = 'price',
  modelSpace = 'wtp',
  options = list(
    # Since WTP space models are non-convex, run a multistart:
    numMultiStarts = 10,
    # If you want to view the results from each multistart run,
    # set keepAllRuns=TRUE:
    keepAllRuns = TRUE,
    # Use the computed WTP from the preference space model as the starting
    # values for the first run:
    startVals = wtp_mnl_pref$Estimate)
)

# Checking for local minima in wtp space models:
wtp_mnl_comparison <- wtpCompare(mnl_pref, mnl_wtp, priceName = 'price')
wtp_mnl_comparison

# Save results
saveRDS(mnl_pref,
        here::here('models', 'mnl_pref.Rds'))
saveRDS(mnl_wtp,
        here::here('models', 'mnl_wtp.Rds'))
saveRDS(wtp_mnl_pref,
        here::here('models', 'wtp_mnl_pref.Rds'))
saveRDS(wtp_mnl_comparison,
        here::here('models', 'wtp_mnl_comparison.Rds'))

# ============================================================================
# Estimate heterogeneous MXL models

mxl_pref1 <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'feat', 'hiland', 'yoplait', 'dannon'),
  randPars   = c(feat = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
  options = list(numMultiStarts = 10)
)

mxl_pref2 <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'feat', 'hiland', 'yoplait', 'dannon'),
  randPars   = c(
    price = 'n', feat = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
  options = list(numMultiStarts = 10)
)

mxl_pref3 <- logitr(
  data       = yogurt_neg_price,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'feat', 'hiland', 'yoplait', 'dannon'),
  randPars   = c(
    price = 'ln', feat = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
   options = list(numMultiStarts = 10)
)

mxl_wtp1 <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('feat', 'hiland', 'yoplait', 'dannon'),
  priceName  = 'price',
  randPars   = c(feat = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
  modelSpace = 'wtp',
  options    = list(
    keepAllRuns = TRUE,
    numMultiStarts = 10,
    startVals = wtp(mxl_pref1, 'price')$Estimate)
)

mxl_wtp2 <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('feat', 'hiland', 'yoplait', 'dannon'),
  priceName  = 'price',
  randPrice  = 'n',
  randPars   = c(feat = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
  modelSpace = 'wtp',
  options    = list(
    numMultiStarts = 5,
    startVals = wtp(mxl_pref2, 'price_mu')$Estimate)
)

mxl_wtp3 <- logitr(
  data       = yogurt_neg_price,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('feat', 'hiland', 'yoplait', 'dannon'),
  priceName  = 'price',
  randPrice  = 'ln',
  randPars   = c(feat = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
  modelSpace = 'wtp',
  options    = list(numMultiStarts = 10, useAnalyticGrad = FALSE)
)

# Save results
saveRDS(mxl_pref1, here::here('models', 'mxl_pref1.Rds'))
saveRDS(mxl_pref2, here::here('models', 'mxl_pref2.Rds'))
saveRDS(mxl_pref3, here::here('models', 'mxl_pref3.Rds'))
saveRDS(mxl_wtp1,   here::here('models', 'mxl_wtp1.Rds'))
saveRDS(mxl_wtp2,   here::here('models', 'mxl_wtp2.Rds'))
saveRDS(mxl_wtp3,   here::here('models', 'mxl_wtp3.Rds'))
