library(shiny)
library(plotly)

server <- function(input, output, session) {
  # game state
  RV <- reactiveValues(
    run_timer = FALSE,
    start_time = Sys.time(),
    elapsed_time = Sys.time() - Sys.time(),
    current_problem = list(
      prompt = "-- queries with blanks will appear here\n-- no syntax highlighting :(",
      answer = NA_character_
    ),
    n_correct = 0,
    terms = c(),
    leaderboard = if (HAS_SHEETS_CONNECTION) read_scores(GSHEETS) else NULL
  )

  observeEvent(input$start_btn, {
    RV$run_timer <- TRUE
    RV$start_time <- Sys.time()
    RV$elapsed_time <- Sys.time() - RV$start_time
    RV$current_problem <- sample_problem(ALL_PROBLEMS)
    RV$n_correct <- 0
    RV$terms <- c()

    # Place cursor in the answer box when start button is clicked
    session$sendCustomMessage(type = "focusInput", message = "answer_box")
  })

  observeEvent(input$stop_btn, {
    RV$run_timer <- FALSE
  })

  observeEvent(input$answer_box, {
    req(RV$run_timer)
    correct <- check_answer(input$answer_box, RV)

    if (isTRUE(correct)) {
      RV$terms[length(RV$terms) + 1] <- RV$current_problem$answer
      RV$n_correct <- RV$n_correct + 1
      updateTextInput(session, inputId = "answer_box", value = "")


      if (RV$n_correct >= WINNING_NUMBER) {
        RV$run_timer <- FALSE
        RV$current_problem <- list(
          prompt = "DONE!",
          answer = NA
        )
        if (HAS_SHEETS_CONNECTION) {
          player_name <- input$player_name
          if (player_name == "Enter name for leaderboard") {
            player_name <- "Anonymous"
          }
          store_record(GSHEETS, game_state = RV, name = player_name)
          RV$leaderboard <- read_scores(GSHEETS)
        }
      } else {
        RV$current_problem <- sample_problem(ALL_PROBLEMS)
      }
    }
  })

  observe({
    invalidateLater(100)
    running <- isolate(RV$run_timer)

    if (running) {
      start_time <- isolate(RV$start_time)
      RV$elapsed_time <- Sys.time() - RV$start_time
    }
  })

  output$timer <- renderText({
    sprintf("%.1f", abs(as.numeric(RV$elapsed_time, units = "secs")))
  })

  ui <- fluidPage(
    sliderInput("slider", "slider", 0, 100, 5),
    uiOutput("bar")
  )

  output$progress_bar <- renderUI({
    value <- 100 * (RV$n_correct / WINNING_NUMBER)

    prgoressBar(
      value = value,
      color = "yellow",
      striped = TRUE,
      active = TRUE,
      size = "sm"
    )
  })

  output$prompt <- renderText({
    RV$current_problem$prompt
  })

  output$leaderboard_dt <- renderTable(
    {
      req(HAS_SHEETS_CONNECTION)

      lb <- RV$leaderboard
      lb$Time <- sprintf("%.1f", lb$finish_time)
      lb$Name <- lb$name

      rownames(lb) <- NULL
      lb <- lb[, c("Name", "Time")]
    },
    rownames = TRUE,
    striped = TRUE,
    bordered = TRUE
  )

  output$scores_dist_plot <- renderPlotly({
    req(HAS_SHEETS_CONNECTION)

    RV$run_timer
    plot_scores(GSHEETS)
  })
}
