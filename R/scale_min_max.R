#' Scaling Numeric Data
#'
#' \code{step_scale_min_max} creates a \emph{specification} of a recipe
#'  step that will normalize numeric data between 0 and 1.
#'
#' @param recipe A recipe object. The step will be added to the
#'  sequence of operations for this recipe.
#' @param ... One or more selector functions to choose which
#'  variables are affected by the step. See [selections()]
#'  for more details. For the \code{tidy} method, these are not
#'  currently used.
#' @param role Not used by this step since no new variables are
#'  created.
#' @param trained A logical to indicate if the quantities for
#'  preprocessing have been estimated.
#' @param skip A logical. Should the step be skipped when the
#'  recipe is baked by \code{\link[=bake.recipe]{bake.recipe()}} While all operations are baked
#'  when \code{\link[=prep.recipe]{prep.recipe()}} is run, some operations may not be able to be
#'  conducted on new data (e.g. processing the outcome variable(s)).
#'  Care should be taken when using \code{skip = TRUE} as it may affect
#'  the computations for subsequent operations.
#' @param x A \code{step_scale_min_max} object.
#'
#' @return An updated version of \code{recipe} with the new step
#'  added to the sequence of existing steps (if any). For the
#'  \code{tidy} method, a tibble with columns \code{terms} (the
#'  selectors or variables selected) and \code{value} (the
#'  standard deviations).
#'
#' @keywords datagen
#'
#' @concept preprocessing normalization_methods
#'
#' @export
#'
#' @details Scaling based on min and max is defined as: \deqn{(x - min(x)) / (max(x) - min(x))}
#'  The calculation is performed in \code{bake.recipe}.
#'
#' @examples
#' library(recipes)
#' data(mtcars)
#'
#' rec <- recipe(mtcars)
#'
#' scaled_data <- rec %>%
#'   step_scale_min_max(all_numeric())
#'
#' scaled_obj <- prep(scaled_data, retain = TRUE)
#'
#' transformed_obj <- juice(scaled_obj)
#' transformed_obj
#'
#' @importFrom recipes ellipse_check
#' @importFrom recipes add_step
#' @importFrom recipes bake
#' @importFrom recipes prep
#'
step_scale_min_max <-
  function(recipe,
           ...,
           role    = NA,
           skip    = FALSE,
           trained = FALSE,
           columns = NULL) {
    add_step(
      recipe,
      step_scale_min_max_new(
        terms   = ellipse_check(...),
        role    = role,
        skip    = skip,
        trained = trained,
        columns = columns
      )
    )
  }

step_scale_min_max_new <-
  function(terms   = NULL,
           role    = NA,
           skip    = FALSE,
           trained = FALSE,
           base    = NULL,
           columns = NULL) {
    step(
      subclass = "scale_min_max",
      terms    = terms,
      role     = role,
      skip     = skip,
      trained  = trained,
      columns  = columns
    )
  }

#' @export
prep.step_scale_min_max <- function(x,
                                    training,
                                    info = NULL,
                                    ...) {
  col_names <- terms_select(x$terms, info = info)
  step_scale_min_max_new(
    terms   = x$terms,
    role    = x$role,
    skip    = x$skip,
    trained = TRUE,
    columns = col_names
  )
}

#' @export
bake.step_scale_min_max <- function(object,
                                    newdata,
                                    ...) {
  col_names <- object$columns
  print(col_names)
  for (i in seq_along(col_names)) {
    col <- newdata[[ col_names[i] ]]
    newdata[, col_names[i]] <-
      (col - min(col)) / (max(col) - min(col))
  }
  as_tibble(newdata)
}

print.step_scale_min_max <-
  function(x, width = max(20, options()$width - 30), ...) {
    cat("Scaling for ", sep = "")
    printer(x$columns, x$terms, x$trained, width = width)
    invisible(x)
  }


#' @rdname step_scale_min_max
#' @param x A \code{step_scale_min_max} object.
tidy.step_scale_min_max <- function(x, ...) {
  if (is_trained(x)) {
    res <- tibble(terms = x$columns)
  } else {
    res <- tibble(terms = sel2char(x$terms))
  }
  res
}







