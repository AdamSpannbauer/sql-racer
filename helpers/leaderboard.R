library(googledrive)
library(googlesheets4)
library(plotly)

GSHEETS_URL <- gsheet_url <- "https://docs.google.com/spreadsheets/d/18cwWpEqvfLgclJL2OGScl1Z3sdg2KOPv1o8RANrOvzs/edit?usp=sharing"

setup_gsheets_auth <- function() {
  # https://stackoverflow.com/a/59910070
  options(gargle_oauth_cache = ".secrets")
  drive_auth(cache = ".secrets", email = "spannbaueradam@gmail.com")
  gs4_auth(token = drive_token())
}

read_scores_sheets <- function() {
  googlesheets4::gs4_get(GSHEETS_URL)
}

read_scores <- function(sheets_obj, limit = 50) {
  scores <- googlesheets4::read_sheet(sheets_obj)
  scores <- scores[order(scores$finish_time), ]
  top_n <- head(scores, limit)
}

plot_scores <- function(sheets_obj) {
  scores <- googlesheets4::read_sheet(sheets_obj)

  D <- density(scores$finish_time)
  fig <- plot_ly(
    x = ~ D$x,
    y = ~ D$y,
    type = "scatter",
    mode = "lines",
    fill = "tozeroy",
    line = list(color = "#0079cb"),
    fillcolor = '#0079cb80'
  ) %>%
    layout(
      xaxis = list(
        title = "Time (sec)",
        hoverformat = ".2f"
      ),
      yaxis = list(
        title = "",
        showline = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE,
        hoverformat = ".2f"
      ),
      plot_bgcolor = "rgba(0, 0, 0, 0)",
      paper_bgcolor = "rgba(0, 0, 0, 0)",
      font = list(color = "#ffffff")
    ) %>%
    config(displayModeBar = FALSE)

  fig
}

store_record <- function(sheets_obj, game_state, name) {
  finish_time <- abs(as.numeric(game_state$elapsed_time, units = "secs"))
  terms <- paste(game_state$terms, collapse = ", ")
  time_stamp <- as.character(Sys.time())

  row <- data.frame(
    name = name,
    finish_time = finish_time,
    terms = terms,
    time_stamp = time_stamp
  )

  sheet_append(
    ss = sheets_obj,
    data = row,
    sheet = "sql-racer-times"
  )
}
