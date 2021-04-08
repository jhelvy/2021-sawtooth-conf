# Render the slides
xaringanBuilder::build_html(here::here("slides", "index.Rmd"))
xaringanBuilder::build_pdf(
    here::here("slides", "index.html"), "2021-sawtooth-conf-logitr-wtp.pdf")

# Then render the README & index.html
rmarkdown::render("README.Rmd", output_format = "github_document")
rmarkdown::render("index.Rmd")
