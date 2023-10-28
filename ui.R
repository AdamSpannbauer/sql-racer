library(shiny)
library(shinythemes)
library(shinycssloaders)
library(plotly)

ui <- fluidPage(
  theme = shinytheme("darkly"),
  tags$head(
    includeHTML("www/meta-tags.html"),
    tags$link(rel = "shortcut icon", href = "favicon.ico"),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "style.css"
    )
  ),
  fluidRow(
    column(
      width = 8,
      offset = 2,
      align = "center",
      img(src = "./logo.png", width = "50%"),
      img(src = "./rubbin-drums.png", width = "15%", style = "border-radius: 5%; margin: 10px"),
      br(),
      hr(),
      h1(textOutput("timer"), style = "font-size: 9rem; font-weight: bold;"),
      br(),
      uiOutput("progress_bar"),
      wellPanel(
        div(
          align = "left",
          withSpinner(
            verbatimTextOutput("prompt"),
            type = 2,
            color = "#0079cb",
            color.background = "#ffd538",
            proxy.height = "100px"
          ),
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
        ),
        br(), br(),
        textInput(
          inputId = "player_name",
          label = "Before you start!",
          value = "Enter name for leaderboard",
          placeholder = "Enter name for leaderboard"
        )
      ),
      hr(),
      div(
        align = "left",
        includeMarkdown("www/instructions.md")
      ),
      hr(),
      fluidRow(
        style = "margin-bottom: 32px;",
        column(
          width = 6,
          h4("Leaderboard"),
          tableOutput("leaderboard_dt")
        ),
        column(
          width = 6,
          plotlyOutput("scores_dist_plot")
        )
      )
    ),
  )
)
