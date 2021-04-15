# # Install logitr package from github
# devtools::install_github('jhelvy/logitr')

# Load logitr package
library('logitr')

# ============================================================================
# Estimate homogeneous MNL models

# Run a MNL model in the Preference Space:
mnl_pref <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'hiland', 'yoplait', 'dannon')
)

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

# Save results
saveRDS(mnl_pref,
        here::here('models', 'mnl_pref.Rds'))
saveRDS(mnl_wtp,
        here::here('models', 'mnl_wtp.Rds'))

# ============================================================================
# Estimate heterogeneous MXL models

yogurt_neg_price <- yogurt
yogurt_neg_price$price <- -1*yogurt$price

mxl_pref1 <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'hiland', 'yoplait', 'dannon'),
  randPars   = c(hiland = 'n', yoplait = 'n', dannon = 'n'),
  options = list(numMultiStarts = 10)
)

mxl_pref2 <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'hiland', 'yoplait', 'dannon'),
  randPars   = c(
    price = 'n', hiland = 'n', yoplait = 'n', dannon = 'n'),
  options = list(numMultiStarts = 10)
)

mxl_pref3 <- logitr(
  data       = yogurt_neg_price,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('price', 'hiland', 'yoplait', 'dannon'),
  randPars   = c(
    price = 'ln', hiland = 'n', yoplait = 'n', dannon = 'n'),
   options = list(numMultiStarts = 10)
)

mxl_wtp <- logitr(
  data       = yogurt,
  choiceName = 'choice',
  obsIDName  = 'obsID',
  parNames   = c('hiland', 'yoplait', 'dannon'),
  priceName  = 'price',
  randPars   = c(hiland = 'n', yoplait = 'n', dannon = 'n'),
  modelSpace = 'wtp',
  options    = list(
    keepAllRuns = TRUE,
    numMultiStarts = 10)
)

# Save results
saveRDS(mxl_pref1, here::here('models', 'mxl_pref1.Rds'))
saveRDS(mxl_pref2, here::here('models', 'mxl_pref2.Rds'))
saveRDS(mxl_pref3, here::here('models', 'mxl_pref3.Rds'))
saveRDS(mxl_wtp,   here::here('models', 'mxl_wtp.Rds'))
