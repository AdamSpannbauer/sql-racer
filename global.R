library(shiny)
library(shinythemes)
library(lubridate)
library(markdown)

source("helpers/prompt_helpers.R")
source("helpers/progress_bar.R")

# ------------------------------------------------------------------------
# Where's the data
QUIZ_TERMS_FILE <- "study_terms.txt"
QUIZ_QUERIES_FILE <- "study_queries.txt"
QUIZ_QUERIES_FILE_DELIM <- "*********************************"

# How many prompts per round?
WINNING_NUMBER <- 10
# ------------------------------------------------------------------------

ALL_PROBLEMS <- gen_problems(QUIZ_TERMS_FILE, QUIZ_QUERIES_FILE, QUIZ_QUERIES_FILE_DELIM)
