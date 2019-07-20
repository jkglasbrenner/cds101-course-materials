#!/usr/bin/env Rscript

get_token_file <- function() {
  token_file <- fs::path(fs::path_home(), "twitter_token", ext = "rds")

  token_file
}

get_renviron_file <- function() {
  renviron_file <- fs::path(fs::path_home(), ".Renviron")
  fs::file_create(path = renviron_file)
  fs::file_chmod(path = renviron_file, mode = "600")

  renviron_file
}

ask_yes_no <- function(yes_no_question_text) {
  response <- NA
  while (is.na(response)) {
    response <- tolower(
      as.character(readline(paste(yes_no_question_text, "[y/n] ")))
    )
    response <- ifelse(grepl("[^yn]", response), NA, response)
  }

  ifelse(grepl("y", response), TRUE, FALSE)
}

ask_for_rtweet_setting <- function(setting) {
  setting_value <- -1
  while (is.na(setting_value) | is.numeric(setting_value)) {
    setting_value <- readline(paste0("Enter your ", setting, ": "))
    setting_value <- ifelse(
      grepl("[[:alpha:]]", setting_value),
      as.character(setting_value),
      -1
    )
  }

  setting_value
}

input_rtweet_settings <- function() {
  rtweet_settings_correct <- FALSE

  while (!rtweet_settings_correct) {
    app <- ask_for_rtweet_setting("twitter app name")
    consumer_key <- ask_for_rtweet_setting("twitter consumer api key")
    consumer_secret <- ask_for_rtweet_setting("twitter consumer api secret key")
    access_token <- ask_for_rtweet_setting("twitter access token")
    access_secret <- ask_for_rtweet_setting("twitter access token secret")
    cat(
      paste0(
        "You entered the following information:\n",
        "Twitter app name: ",
        app,
        "\n",
        "Twitter consumer API key: ",
        consumer_key,
        "\n",
        "Twitter consumer API secret key: ",
        consumer_secret,
        "\n",
        "Twitter access token: ",
        access_token,
        "\n",
        "Twitter access token secret: ",
        access_secret
      )
    )
    rtweet_settings_correct <- ask_yes_no("Is this correct?")
  }

  list(
    app = app,
    consumer_key = consumer_key,
    consumer_secret = consumer_secret,
    access_token = access_token,
    access_secret = access_secret
  )
}

save_rtweet_settings <- function(
  app,
  consumer_key,
  consumer_secret,
  access_token,
  access_secret
) {
  twitter_app <- paste0("TWITTER_APP=", app)
  twitter_consumer_key <- paste0("TWITTER_CONSUMER_KEY=", consumer_key)
  twitter_consumer_secret <- paste0("TWITTER_CONSUMER_SECRET=", consumer_secret)
  twitter_access_token <- paste0("TWITTER_ACCESS_TOKEN=", access_token)
  twitter_access_token_secret <- paste0(
    "TWITTER_ACCESS_TOKEN_SECRET=",
    access_secret
  )

  usethis::write_union(
    path = get_renviron_file(),
    lines = dplyr::combine(
      twitter_app,
      twitter_consumer_key,
      twitter_consumer_secret,
      twitter_access_token,
      twitter_access_token_secret
    )
  )
}

set_twitter_token_location <- function() {
  twitter_pat <- paste0("TWITTER_PAT=", get_token_file())

  usethis::write_union(
    path = get_renviron_file(),
    lines = dplyr::combine(twitter_pat)
  )
}

create_rtweet_token <- function(
  app = Sys.getenv("TWITTER_APP"),
  consumer_key = Sys.getenv("TWITTER_CONSUMER_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
) {
  rtweet::create_token(
    app = app,
    consumer_key = consumer_key,
    consumer_secret = consumer_secret,
    access_token = access_token,
    access_secret = access_secret,
    set_renv = FALSE
  )
}

save_twitter_token <- function(twitter_token) {
  token_file <- get_token_file()
  readr::write_rds(x = twitter_token, path = token_file)
  fs::file_chmod(path = token_file, mode = "600")
}

print_upload_instructions <- function() {
  token_file <- get_token_file()
  usethis::ui_info(
    c(
      paste0(
        "Your locally generated Twitter token was saved to the following ",
        "location on your computer:"
      ),
      usethis::ui_path(token_file),
      "Upload this token to your home directory on RStudio Server."
    )
  )
  usethis::ui_info(
    paste0(
      "Then, on RStudio Server, activate the project for the 'Mining the ",
      "Social Web' lab, and run the following in the Console window:"
    )
  )
  usethis::ui_code_block(
    c(
      "source(\"configure_rtweet.R\")",
      "use_uploaded_token_on_rstudio_server()"
    )
  )
}

use_uploaded_token_on_rstudio_server <- function() {
  token_file <- get_token_file()

  if (fs::file_exists(token_file)) {
    usethis::ui_done("Twitter token detected, finishing setup...")
    set_twitter_token_location()
    readRenviron(get_renviron_file())
    usethis::ui_done("Setup complete.")
  } else {
    usethis::ui_warn(
      "Twitter token not found in your home directory, terminating setup."
    )
  }
}

configure_rtweet_rstudio_server <- function() {
  usethis::ui_info("Starting rtweet setup...")
  rtweet_settings <- input_rtweet_settings()
  save_rtweet_settings(
    rtweet_settings$app,
    rtweet_settings$consumer_key,
    rtweet_settings$consumer_secret,
    rtweet_settings$access_token,
    rtweet_settings$access_secret
  )
  usethis::ui_done("rtweet settings saved.")
  usethis::ui_info("Generating Twitter token...")
  set_twitter_token_location()
  readRenviron(get_renviron_file())
  twitter_token <- create_rtweet_token()
  save_twitter_token(twitter_token)
  if (fs::file_exists(get_token_file())) {
    usethis::ui_done("Setup complete.")
  } else {
    usethis::ui_warn(
      "Twitter token not found in your home directory, terminating setup."
    )
  }
}

generate_token_on_local_computer <- function() {
  usethis::ui_info(
    paste0(
      "Generating Twitter token, login to your Twitter account and ",
      "authorize rtweet."
    )
  )
  twitter_token <- rtweet::get_token()
  save_twitter_token(twitter_token)
  print_upload_instructions()
}
