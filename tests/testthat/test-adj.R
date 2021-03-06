test_that("adj, issue #3", {
    ## x <- .request("gut", pos = "adj")
    ## xml2::write_xml(x, "../testdata/gut.html")
    res <- verbformen(html_file = "../testdata/gut.html")
    res$table %>% dplyr::filter(deklination == "schwache") %>% dplyr::pull(wort) -> x
    expect_true("gute" %in% x)
    res$table %>% dplyr::filter(deklination == "gemischte") %>% dplyr::pull(wort) -> x
    res$table %>% dplyr::filter(deklination == "gemischte") %>% dplyr::pull(artikel) -> y
    expect_true("guter" %in% x)
    expect_true("ein" %in% y)
})


test_that("No alternative spelling, issue #2", {
    ## x <- .request("tapfer", pos = "adj")
    ## xml2::write_xml(x, "../testdata/tapfer.html")
    res <- verbformen(html_file = "../testdata/tapfer.html")
    expect_true("tapferer" %in% res$table$wort)
    expect_false("tapferemtapfremtapferm" %in% res$table$wort)
    expect_true("tapfere" %in% res$table$wort)
    expect_true("ein" %in% res$table$artikel)
    expect_true("der" %in% res$table$artikel)
})
