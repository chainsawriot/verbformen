test_that("input and html_file can't be both NULL", {
    expect_error(verbformen())
    expect_error(verbformen(input = NULL, html_file = NULL))
})
