rep_kfold_cv <- function(data, k, model, cv_reps) {
  full_data_pointer <- modelr::resample(data, 1:nrow(data))

  repeated_data <- dplyr::data_frame(
    full_data = rep(list(full_data_pointer), cv_reps)
  )

  repeated_cv_errors <- purrr::map_df(
    .x = pull(repeated_data, full_data),
    .f = cv_train_test_,
    k = k,
    model = formula(model)
  )

  cv_score <- dplyr::summarize(
    repeated_cv_errors,
    r_squared = mean(r_squared),
    mse = mean(mse),
    adjusted_mse = mean(adjusted_mse)
  )

  return(cv_score)
}

cv_train_test_ <- function(data, k, model) {
  model_terms <- terms(model)
  response <- model_terms[[2]]

  training_error <- compute_training_error_(
    data = tibble::as_tibble(data), model = model
  )

  trained_model_df <- kfold_train_model_(
    data = tibble::as_tibble(data), k = k, model = model
  )

  validation_df <- kfold_validation_(
    trained_model_df = trained_model_df
  )

  errors_per_fold_df <- compute_errors_per_fold_(
    validation_df = validation_df,
    response = response
  )

  cv_errors_df <- reduce_errors_over_folds_(
    errors_per_fold_df = errors_per_fold_df,
    training_dataset_error = training_error
  )

  return(cv_errors_df)
}

# Based on https://drsimonj.svbtle.com/k-fold-cross-validation-with-modelr-and-broom
kfold_train_model_ <- function(data, k, model) {
  full_data_pointer <- modelr::resample(data, 1:nrow(data))
  trained_model_df <- dplyr::mutate(
    modelr::crossv_kfold(data = data, k = k),
    full = rep(list(full_data_pointer), k),
    trained_model = purrr::map(train, ~ lm(model, data = .))
  )
  trained_model_df <- dplyr::select(
    trained_model_df,
    full,
    train,
    test,
    .id,
    trained_model
  )

  return(trained_model_df)
}

kfold_validation_ <- function(trained_model_df) {
  validation_df <- dplyr::mutate(
    trained_model_df,
    train_prediction = purrr::map2(
      trained_model,
      full,
      ~ broom::augment(.x, newdata = .y)
    )
  )

  validation_df <- dplyr::mutate(
    validation_df,
    test_prediction = purrr::map2(
      trained_model,
      test,
      ~ broom::augment(.x, newdata = .y)
    )
  )

  return(validation_df)
}

compute_training_error_ <- function(data, model) {
  full_model <- lm(model, data = data)
  full_model_terms <- terms(full_model)
  response_variable <- full_model_terms[[2]]
  response_label <- all.vars(response_variable)
  response <- dplyr::quo(!!rlang::sym(response_label))

  augmented_data <- tibble::as_tibble(broom::augment(full_model, data = data))

  error <- dplyr::summarize(
    augmented_data,
    validation_type = "full_train_prediction",
    sse = sum((!!response - .fitted)^2),
    sst = sum((!!response - mean(!!response))^2),
    mse = sse / n(),
    r_squared = 1 - sse / sst
  )

  return(dplyr::select(error, validation_type, mse, r_squared))
}

compute_error_ <- function(validation_df, prediction_column, response_variable) {
  response_label <- all.vars(response_variable)
  response <- dplyr::quo(!!rlang::sym(response_label))
  prediction_column_quosure <- dplyr::enquo(prediction_column)
  prediction_column_label <- dplyr::quo_name(prediction_column_quosure)

  prediction_df <- tidyr::unnest(validation_df, !!prediction_column_quosure)
  prediction_df_grouped <- dplyr::group_by(prediction_df, .id)

  error <- dplyr::summarize(
    prediction_df_grouped,
    validation_type = prediction_column_label,
    sse = sum((!!response - .fitted)^2),
    sst = sum((!!response - mean(!!response))^2),
    mse = sse / n(),
    observations_in_fold = n(),
    r_squared = 1 - sse / sst
  )

  return(error)
}

compute_errors_per_fold_ <- function(validation_df, response) {
  kfold_cv_error <- compute_error_(
    validation_df = validation_df,
    prediction_column = test_prediction,
    response_variable = response
  )

  kfold_training_error <- dplyr::mutate(
    compute_error_(
      validation_df = validation_df,
      prediction_column = train_prediction,
      response_variable = response
    ),
    observations_in_fold = dplyr::pull(kfold_cv_error, observations_in_fold)
  )

  errors_per_fold_df <- dplyr::bind_rows(kfold_cv_error, kfold_training_error)

  return(errors_per_fold_df)
}

reduce_errors_over_folds_ <- function(errors_per_fold_df,
                                      training_dataset_error) {
  reduced_test_train_errors_df <- dplyr::summarize(
    dplyr::group_by(
      errors_per_fold_df,
      validation_type
    ),
    mse = sum(
      (observations_in_fold * mse) / sum(observations_in_fold)
    ),
    r_squared = sum(
      (observations_in_fold * r_squared) / sum(observations_in_fold)
    )
  )
  reduced_test_train_errors_df <- dplyr::mutate(
    reduced_test_train_errors_df,
    mse = if_else(validation_type == "train_prediction", -mse, mse)
  )

  reduced_errors_df <- dplyr::bind_rows(
    reduced_test_train_errors_df,
    training_dataset_error
  )

  adjusted_errors_df <- dplyr::summarize(
    reduced_errors_df,
    adjusted_mse = sum(mse)
  )

  unadjusted_errors_df <- select(
    filter(reduced_errors_df, validation_type == "test_prediction"),
    r_squared,
    mse
  )

  cv_errors_df <- dplyr::bind_cols(unadjusted_errors_df, adjusted_errors_df)

  return(cv_errors_df)
}
