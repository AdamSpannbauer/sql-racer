library(shiny)
library(shinythemes)
library(shinyWidgets)
library(lubridate)
source("gen_problems.R")

WINNING_NUMBER <- 10
ALL_PROBLEMS <- gen_problems(QUIZ_WORDS, QUIZ_QUERIES)

sample_problem <- function() {
  i <- sample(length(ALL_PROBLEMS), size = 1)
  problem <- ALL_PROBLEMS[[i]]

  return(problem)
}

check_answer <- function(user_input, game_state) {
  s1 <- tolower(user_input)
  s2 <- tolower(game_state$current_problem$answer)

  return(s1 == s2)
}

ui <- fluidPage(
  theme = shinytheme("cosmo"),
  setBackgroundColor("#aaaaaa"),
  fluidRow(
    column(
      width = 8,
      offset = 2,
      align = "center",
      h1("SQL Racer!!"),
      img(src = "./running-drums.png", width = "25%", style = "border-radius: 5%; margin: 10px"),
      hr(),
      h1(textOutput("timer"), style = "font-size: 9rem; font-weight: bold;"),
      br(),
      wellPanel(
        div(
          align = "left", verbatimTextOutput("prompt"),
          textInput(
            inputId = "answer_box",
            label = "SQL!",
            placeholder = "SQL!"
          )
        )
      ),
      fluidRow(
        actionButton(
          inputId = "start_btn",
          label = "(re)Start!",
          icon = icon("face-laugh-beam"),
          class = "btn btn-primary"
        ),
        actionButton(
          inputId = "stop_btn",
          label = "Stop...",
          icon = icon("face-meh"),
          class = "btn btn-secondary"
        )
      ),
    )
  )
)

server <- function(input, output, session) {
  # game state stuff
  RV <- reactiveValues(
    run_timer = FALSE,
    start_time = Sys.time(),
    elapsed_time = difftime(Sys.time(), Sys.time(), unit = "secs"),
    current_problem = list(
      prompt = "-- fill in the blanks will appear here; no syntax highlighting... :(",
      answer = NA_character_
    ),
    n_correct = 0
  )

  observeEvent(input$start_btn, {
    RV$run_timer <- TRUE
    RV$start_time <- Sys.time()
    RV$elapsed_time <- difftime(Sys.time(), RV$start_time, unit = "secs")
    RV$current_problem <- sample_problem()
    RV$n_correct <- 0
  })

  observeEvent(input$stop_btn, {
    RV$run_timer <- FALSE
    RV$start_time <- Sys.time()
    RV$elapsed_time <- difftime(Sys.time(), Sys.time(), unit = "secs")
    RV$current_problem <- list(
      prompt = "-- fill in the blanks will appear here; no syntax highlighting... :(",
      answer = NA_character_
    )
    RV$n_correct <- 0
  })

  observeEvent(input$answer_box, {
    req(RV$run_timer)
    correct <- check_answer(input$answer_box, RV)

    if (isTRUE(correct)) {
      RV$n_correct <- RV$n_correct + 1
      updateTextInput(session, inputId = "answer_box", value = "")

      if (RV$n_correct > WINNING_NUMBER) {
        RV$run_timer <- FALSE
        RV$current_problem <- list(
          prompt = "DONE!",
          answer = NA
        )
      } else {
        RV$current_problem <- sample_problem()
      }
    }
  })

  observe({
    invalidateLater(100)
    running <- isolate(RV$run_timer)

    if (running) {
      start_time <- isolate(RV$start_time)
      RV$elapsed_time <- Sys.time() - start_time
    }
  })

  output$timer <- renderText({
    sprintf("%.1f", abs(RV$elapsed_time))
  })

  output$prompt <- renderText({
    RV$current_problem$prompt
  })
}

shinyApp(ui, server)
