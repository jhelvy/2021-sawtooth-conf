# Render the slides
xaringanBuilder::build_html(here::here("slides", "index.Rmd"))
xaringanBuilder::build_pdf(
    here::here("slides", "index.html"),
    here::here("slides", "2021-sawtooth-conf-logitr-wtp.pdf"))

# Then render the repo index page
rmarkdown::render("index.Rmd")
