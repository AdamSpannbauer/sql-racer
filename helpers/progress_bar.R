library(shiny)
library(shinydashboard)
library(htmltools)

# https://github.com/rstudio/shinydashboard/issues/119
prgoressBar <- function(value = 0, label = FALSE, color = "aqua", size = NULL,
                        striped = FALSE, active = FALSE, vertical = FALSE) {
  stopifnot(is.numeric(value))
  if (value < 0 || value > 100) {
    stop("'value' should be in the range from 0 to 100.", call. = FALSE)
  }
  if (!(color %in% shinydashboard:::validColors || color %in% shinydashboard:::validStatuses)) {
    stop("'color' should be a valid status or color.", call. = FALSE)
  }
  if (!is.null(size)) {
    size <- match.arg(size, c("sm", "xs", "xxs"))
  }
  text_value <- paste0(value, "%")
  if (vertical) {
    style <- htmltools::css(height = text_value, `min-height` = "2em")
  } else {
    style <- htmltools::css(width = text_value, `min-width` = "2em")
  }
  tags$div(
    class = "progress",
    class = if (!is.null(size)) paste0("progress-", size),
    class = if (vertical) "vertical",
    class = if (active) "active",
    tags$div(
      class = "progress-bar",
      class = paste0("progress-bar-", color),
      class = if (striped) "progress-bar-striped",
      style = style,
      role = "progressbar",
      `aria-valuenow` = value,
      `aria-valuemin` = 0,
      `aria-valuemax` = 100,
      tags$span(class = if (!label) "sr-only", text_value),
      tags$style(paste0(".progress-bar-", color, " {background-color: ", color, ";}"))
    )
  )
}
