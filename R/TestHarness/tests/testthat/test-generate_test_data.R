context("Generate Test Data")

test_data <- simulate_dataset()

generator <- TestDataGenerator$new(test_data = test_data)
d <- generator$next_runtime(lag=5)

test_that("List structure is correct", {
  expect_equal(length(names(d)), 2)
})
