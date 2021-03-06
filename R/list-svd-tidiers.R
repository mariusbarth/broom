#' @templateVar class svd
#' @template title_desc_tidy_list
#'
#' @inherit tidy.prcomp return details params
#' @param x A list with components `u`, `d`, `v` returned by [svd()].
#'
#' @examples
#'
#' mat <- scale(as.matrix(iris[, 1:4]))
#' s <- svd(mat)
#'
#' tidy_u <- tidy(s, matrix = "u")
#' tidy_u
#'
#' tidy_d <- tidy(s, matrix = "d")
#' tidy_d
#'
#' tidy_v <- tidy(s, matrix = "v")
#' tidy_v
#'
#' library(ggplot2)
#' library(dplyr)
#'
#' ggplot(tidy_d, aes(PC, percent)) +
#'   geom_point() +
#'   ylab("% of variance explained")
#'
#' tidy_u %>%
#'   mutate(Species = iris$Species[row]) %>%
#'   ggplot(aes(Species, value)) +
#'   geom_boxplot() +
#'   facet_wrap(~PC, scale = "free_y")
#' @seealso [svd()]
#' @aliases svd_tidiers
#' @family svd tidiers
#' @family list tidiers
tidy_svd <- function(x, matrix = "u", ...) {
  if (length(matrix) > 1) {
    stop("Must specify a single matrix to tidy.")
  }

  if (matrix == "u") {
    ret <- x$u %>%
      as_tibble(.name_repair = "unique") %>%
      tibble::rowid_to_column("row") %>%
      pivot_longer(
        cols = c(dplyr::everything(), -row),
        names_to = "PC",
        values_to = "value"
      ) %>%
      dplyr::mutate(PC = stringr::str_remove(PC, "...") %>% as.numeric()) %>%
      arrange(PC, row) %>%
      as.data.frame()
  } else if (matrix == "d") {
    ret <- tibble(PC = seq_along(x$d), std.dev = x$d) %>%
      mutate(
        percent = std.dev^2 / sum(std.dev^2),
        cumulative = cumsum(percent)
      )
  } else if (matrix == "v") {
    ret <- x$v %>%
      as_tibble(.name_repair = "unique") %>%
      tibble::rowid_to_column("column") %>%
      pivot_longer(
        cols = c(dplyr::everything(), -column),
        names_to = "PC",
        values_to = "value"
      ) %>%
      dplyr::mutate(PC = stringr::str_remove(PC, "...") %>% as.numeric()) %>%
      arrange(PC, column) %>%
      as.data.frame()
  }
  as_tibble(ret)
}
