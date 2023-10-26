QUIZ_WORDS <- c(
  "SELECT", "FROM", "WHERE", "GROUP BY", "HAVING", "ORDER BY", "LIMIT",
  "CREATE", "TABLE",
  "INSERT", "INTO", "VALUES",
  "UPDATE", "SET",
  "DELETE", "ALTER", "DROP",
  "TRUNCATE", "*", "IS NULL",
  "VARCHAR", "COUNT", "BETWEEN", "AND",
  "CONCAT", "AS", "DESC", "AVG"
)

QUIZ_QUERIES <- c(
  "-- get all fields in orders table\n-- sorted by amount large to small\n-- only show top 5\nSELECT *\nFROM orders\nORDER BY amount DESC\nLIMIT 5;",
  "-- show mean score by section\n-- only include sections with a mean greater than 80\nSELECT AVG(score), section\nFROM grade_book\nGROUP BY section\nHAVING AVG(score) > 80;",
  "-- make orders table\nCREATE TABLE orders (\n\torder_id INT AUTO_INCREMENT PRIMARY KEY,\n\tcustomer_id INT NOT NULL,\n\tdate DATE\n);",
  "-- rm orders table\nDROP TABLE orders;",
  "-- remove all records from orders\nTRUNCATE orders;",
  "-- change date column to default as current date\nALTER TABLE orders\nALTER date SET DEFAULT CURDATE();",
  "-- add an is_active column to products that defaults to 1\nALTER TABLE products\nADD is_active INT DEFAULT 1;",
  "-- remove records that have NULL date\nDELETE FROM orders\nWHERE date IS NULL;",
  "-- change customer info for customer_id 1\nUPDATE customers\nSET street = '1000 Volunteer Blvd',\n     city = 'Knoxville',\n     zip = '37916'\nWHERE customer_id = 1;",
  "-- get row count of orders table\nSELECT COUNT(*)\nFROM orders;",
  "-- get NA count of date col in orders table\nSELECT COUNT(*) - COUNT(date)\nFROM orders;",
  "-- filter to an id range of orders\nSELECT *\nFROM orders\nWHERE id BETWEEN 10 AND 20;",
  "-- make pretty percents and alias\nSELECT CONCAT(discount * 100, '%') AS percent_discount\nFROM order_details;",
  "-- assign letter grades for A, B, and other\nSELECT\n\tCASE\n\t\tWHEN score > 90 THEN 'A'\n\t\tWHEN score > 80 THEN 'B'\n\t\tELSE 'Other'\n\tEND AS Grade\nFROM grade_book;"
)

gen_problems <- function(terms = QUIZ_WORDS,
                         queries = QUIZ_QUERIES,
                         blank_char = "_") {
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
