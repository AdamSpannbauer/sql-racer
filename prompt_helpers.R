parse_terms_file <- function(file_path) {
  terms <- readLines(file_path)
  trimws(terms)
}


parse_query_file <- function(file_path, query_delim) {
  all_query_lines <- readLines(file_path)
  query_id <- cumsum(all_query_lines == query_delim)
  split_query_lines <- split(all_query_lines, query_id)

  # Drop first - contributing instructions
  # Drop last - should be nothing unless entry error
  split_query_lines <- head(split_query_lines, -1)
  split_query_lines <- tail(split_query_lines, -1)

  vapply(split_query_lines, function(q_lines) {
    # rm delim and blanks
    q_lines <- q_lines[q_lines != query_delim]
    q_lines <- q_lines[trimws(q_lines) != ""]

    # make single multi-line string
    paste(q_lines, collapse = "\n")
  }, character(1))
}


gen_problems <- function(quiz_words_file = "study_terms.txt",
                         quiz_queries_file = "study_queries.txt",
                         query_delim = "*********************************",
                         blank_char = "_") {
  terms <- parse_terms_file(quiz_words_file)
  queries <- parse_query_file(quiz_queries_file, query_delim)

  problems <- list()
  for (term in terms) {
    for (query in queries) {
      term_in_query <- grepl(term, query, fixed = TRUE)
      if (!term_in_query) next

      blank <- gsub(".", blank_char, term)
      query_w_blanks <- gsub(term, blank, query, fixed = TRUE)

      problem <- list(
        prompt = query_w_blanks,
        answer = term
      )

      problems[[length(problems) + 1]] <- problem
    }
  }

  return(problems)
}


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
