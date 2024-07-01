library(shiny)


prismDependencies <- tags$head(
  tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/prism.min.js"),
  tags$link(
    rel = "stylesheet",
    type = "text/css",
    href = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/themes/prism.min.css"
  ),
  # For SQL
  tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/components/prism-sql.min.js")
  # For R
  # tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/components/prism-r.min.js")
)

prismCodeBlock <- function(code) {
  tagList(
    HTML(paste0("<pre><code class='language-sql'>", code, "</code></pre>")),
    tags$script("Prism.highlightAll()")
  )
}
