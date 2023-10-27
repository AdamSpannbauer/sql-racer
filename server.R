library(shiny)
library(lubridate)

server <- function(input, output, session) {
  # game state
  RV <- reactiveValues(
    run_timer = FALSE,
    start_time = Sys.time(),
    elapsed_time = difftime(Sys.time(), Sys.time(), units = "secs"),
    current_problem = list(
      prompt = "-- queries with blanks will appear here\n-- no syntax highlighting :(",
      answer = NA_character_
    ),
    n_correct = 0
  )

  observeEvent(input$start_btn, {
    RV$run_timer <- TRUE
    RV$start_time <- Sys.time()
    RV$elapsed_time <- difftime(Sys.time(), RV$start_time, units = "secs")
    RV$current_problem <- sample_problem(ALL_PROBLEMS)
    RV$n_correct <- 0
  })

  observeEvent(input$stop_btn, {
    RV$run_timer <- FALSE
    RV$start_time <- Sys.time()
    RV$elapsed_time <- difftime(Sys.time(), Sys.time(), units = "secs")
    RV$current_problem <- list(
      prompt = "-- queries with blanks will appear here\n-- no syntax highlighting :(",
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

      if (RV$n_correct >= WINNING_NUMBER) {
        RV$run_timer <- FALSE
        RV$current_problem <- list(
          prompt = "DONE!",
          answer = NA
        )
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
      RV$elapsed_time <- Sys.time() - start_time
    }
  })

  output$timer <- renderText({
    sprintf("%.1f", abs(RV$elapsed_time))
  })

  ui <- fluidPage(
    sliderInput("slider", "slider", 0, 100, 5),
    uiOutput("bar")
  )

  output$progress_bar <- renderUI({
    value <- 100 * (RV$n_correct / WINNING_NUMBER)

    prgoressBar(
      value = value,
      color = "blue",
      striped = TRUE,
      active = TRUE,
      size = "sm"
    )
  })


  shinyApp(ui = ui, server = server)

  output$prompt <- renderText({
    RV$current_problem$prompt
  })
}
