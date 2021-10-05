## src needs to be serialized using xml2::write_xml


test_that("issue #1", {
    x <- verbformen(html_file = "../testdata/aufgeben.html")
    res <- x$table %>% dplyr::filter(tempus == "Imperativ")
    expect_equal(res$wort, c("gib auf", "geben auf", "gebt auf", "geben auf"))
})

test_that("Don't cause issue for untrennbare Verben", {
    ## x <- verbformen:::.request("geben")
    ## xml2::write_xml(x, "../testdata/geben.html")
    x <- verbformen(html_file = "../testdata/geben.html")
    res <- x$table %>% dplyr::filter(tempus == "Imperativ")
    expect_equal(res$wort, c("gib", "geben", "gebt", "geben"))    
})

test_that("keep_dot, issue #4", {
    x <- verbformen(html_file = "../testdata/aufgeben.html", keep_dot = TRUE)
    expect_equal("auf\u00b7geben", x$grundform)
    x <- verbformen(html_file = "../testdata/aufgeben.html", keep_dot = FALSE)
    expect_equal("aufgeben", x$grundform)
    ## default behavior
    x <- verbformen(html_file = "../testdata/aufgeben.html")
    expect_equal("auf\u00b7geben", x$grundform)
    ## No effect on untrennbare Verben
    x <- verbformen(html_file = "../testdata/geben.html", keep_dot = TRUE)
    expect_equal("geben", x$grundform)
    x <- verbformen(html_file = "../testdata/geben.html", keep_dot = FALSE)
    expect_equal("geben", x$grundform)    
})

