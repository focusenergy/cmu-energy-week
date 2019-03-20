context("Generate Test Data")

generator <- TestDataGenerator$new()
d <- generator$next_runtime(lag=5)

test_that("List structure is correct", {
  expect_equal(length(names(d)), 2)
})
