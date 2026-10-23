library(tidyverse)

dat <- diamonds %>%
  mutate(across(where(is.ordered), as.character))

set.seed(1234)
training_index <- sample(1:nrow(dat), 37758)

training_dat <- dat[training_index,]
test_dat <- dat[-training_index,]

diamonds %>%
  select(where(is.numeric)) %>%
  cor()


training_dat %>%
  ggplot(aes(x=carat, y=price)) +
  geom_point()

simple_mod <- lm(price ~ carat, data = training_dat)

summary(simple_mod)


# Examine factor variables:
training_dat %>%
  ggplot(aes(x=log(carat), y=log(price))) +
  geom_point(aes(color=color))


color_mod <- lm(price ~ color + carat, data = training_dat)

summary(color_mod)

color_x_mod <- lm(price ~ color + carat + x, data = training_dat)

summary(color_x_mod)


# SSE metric (higher is worse)
calculate_sse <- function(model, data, response_col = NULL) {
  # 1. Validate inputs
  if (!inherits(model, "lm")) {
    stop("Argument 'model' must be a fitted linear model (class 'lm').")
  }
  if (!is.data.frame(data)) {
    stop("Argument 'data' must be a data frame.")
  }
  
  # 2. Identify the response variable
  if (is.null(response_col)) {
    response_col <- all.vars(formula(model))[1]
  }
  
  if (!response_col %in% names(data)) {
    stop(sprintf("Response variable '%s' not found in the provided dataset.", response_col))
  }
  
  # 3. Compute predicted values and actuals
  y_actual <- data[[response_col]]
  y_pred <- predict(model, newdata = data)
  
  # 4. Handle any missing data rows consistently
  residuals <- y_actual - y_pred
  valid_residuals <- residuals[!is.na(residuals)]
  
  # 5. Sum of squared errors
  sse <- sum(valid_residuals^2)
  return(sse)
}

# simple_mod, color_mod, color_x_mod

color_x_y_mod <- lm(price ~ carat + x + y + color, data = training_dat)

calculate_sse(simple_mod, data=test_dat) # 39071566886
calculate_sse(color_mod, data=test_dat) # 35307920768
calculate_sse(color_x_mod, data=test_dat) # 34541275953
calculate_sse(color_x_y_mod, data=test_dat) # 34516126909



