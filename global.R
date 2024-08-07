library(shiny)
library(shinythemes)
library(shinydashboard)
library(htmltools)

library(markdown)
library(DT)

library(googledrive)
library(googlesheets4)

library(plotly)

source("helpers/prompt_helpers.R")
source("helpers/progress_bar.R")
source("helpers/leaderboard.R")
source("helpers/syntax_highlighting.R")

# ------------------------------------------------------------------------
# Where's the data
QUIZ_TERMS_FILE <- "study_terms.txt"
QUIZ_QUERIES_FILE <- "study_queries.txt"
QUIZ_QUERIES_FILE_DELIM <- "*********************************"

# How many prompts per round?
WINNING_NUMBER <- 10
# ------------------------------------------------------------------------

ALL_PROBLEMS <- gen_problems(QUIZ_TERMS_FILE, QUIZ_QUERIES_FILE, QUIZ_QUERIES_FILE_DELIM)

GSHEETS <- NULL
if (dir.exists(".secrets")) {
  tryCatch(
    expr = {
      setup_gsheets_auth()
      GSHEETS <<- read_scores_sheets()
    },
    error = function(e) {}
  )
}

HAS_SHEETS_CONNECTION <- !is.null(GSHEETS)
