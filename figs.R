library(tidyverse)
library(logitr)
library(cowplot)
library(viridis)

set.seed(5678)

# Compare WTP from Pref and WTP space models ---------------------------------

# Extract pars
mxl_pref1 <- readRDS(here::here('models', 'mxl_pref1.Rds'))
mxl_pref2 <- readRDS(here::here('models', 'mxl_pref2.Rds'))
mxl_pref3 <- readRDS(here::here('models', 'mxl_pref3.Rds'))
mxl_wtp <- readRDS(here::here('models', 'mxl_wtp1.Rds'))
pars_pref1 <- coef(mxl_pref1)
pars_pref2 <- coef(mxl_pref2)
pars_pref3 <- coef(mxl_pref3)
pars_wtp <- coef(mxl_wtp)

# Generate simulated data from the estimated parameters
N <- 10^4
pars <- tibble(
  alpha1 = rep(-1*pars_pref1['price'], N),
  alpha2 = rnorm(N, -1*pars_pref2['price_mu'], pars_pref2['price_sigma']),
  alpha3 = rlnorm(N, pars_pref3['price_mu'], pars_pref3['price_sigma']),
  beta1 = rnorm(N, pars_pref1['yoplait_mu'], pars_pref1['yoplait_sigma']),
  beta2 = rnorm(N, pars_pref2['yoplait_mu'], pars_pref2['yoplait_sigma']),
  beta3 = rnorm(N, pars_pref3['yoplait_mu'], pars_pref3['yoplait_sigma']),
  omega = rnorm(N, pars_wtp['yoplait_mu'], pars_wtp['yoplait_sigma']))

df <- pars %>%
  mutate(
    pref1 = beta1 / alpha1,
    pref2 = beta2 / alpha2,
    pref3 = beta3 / alpha3
  ) %>%
  select(pref1, pref2, pref3, omega) %>%
  gather(key = "model", value = "wtp_pref", pref1:pref3) %>%
  mutate(model = fct_recode(model,
    "Fixed price" = "pref1",
    "Normally distributed price" = "pref2",
    "Log-normally distributed price" = "pref3"
  )) %>%
  gather("space", "wtp", c(wtp_pref, omega)) %>%
  mutate(space = fct_recode(space,
    "Preference" = "wtp_pref",
    "WTP" = "omega",
  ))

# Compute means and standard deviations
stats <- df %>%
  group_by(space, model) %>%
  summarise(
    mean = mean(wtp),
    sd = sd(wtp)) %>%
  arrange(model, space) %>%
  mutate(
    label_mean = paste0("Mean: ", round(mean, 2)),
    label_sd = paste0("SD:     ", round(sd, 3))
  ) %>%
  cbind(data.frame(
    x = c(3.72, 3.665, 3.35, 3.77, 2.7, 1.38),
    y_mean = c(43, 43, 43, 43, 970, 970),
    y_sd = c(38, 38, 38, 38, 850, 850)
  ))

# Make the plot
font <- "Fira Sans Condensed"
plotColors <- c("grey42", "red")
wtpCompare <- ggplot(df) +
  geom_vline(
    data = stats,
    mapping = aes(xintercept = mean, color = space),
    size = 0.5, linetype = "dashed") +
  geom_density(
    aes(x = wtp, y = ..density.., fill = space),
    color = "black", size = 0.1, alpha = 0.42) +
  facet_wrap(vars(model), scales = "free") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  scale_fill_manual(values = plotColors) +
  scale_color_manual(values = plotColors, guide = FALSE) +
  theme_minimal_hgrid(font_family = font) +
  panel_border() +
  theme(
    legend.position = "bottom",
    strip.background = element_rect(fill = "grey90")
  ) +
  labs(
    x = "Willingness to pay for Yoplait Brand ($)",
    y = "Density",
    fill = "Model parameterization:"
  ) +
  geom_text(
    data = stats,
    mapping = aes(x = x, y = y_mean, label = label_mean, color = space),
    hjust = 0
  ) +
  geom_text(
    data = stats,
    mapping = aes(x = x, y = y_sd, label = label_sd, color = space),
    hjust = 0
  )

ggsave(here::here("images", "wtpCompare.png"),
       wtpCompare, width = 9, height = 3.5)
