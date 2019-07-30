calc_streak <- function(data) {
  `%>%` <- magrittr::`%>%`

  data %>%
    dplyr::bind_rows(tibble::tibble(shot = "M")) %>%
    dplyr::mutate(index = dplyr::row_number(), hit = shot == "H") %>%
    dplyr::filter(!hit) %>%
    dplyr::mutate(streak = index - dplyr::lag(index, default = 0) - 1) %>%
    dplyr::select(streak)
}
