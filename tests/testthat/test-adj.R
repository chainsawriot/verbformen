test_that("adj, issue #3", {
    ## x <- .request("gut", pos = "adj")
    ## xml2::write_xml(x, "../testdata/gut.html")
    src <- rvest::read_html("../testdata/gut.html")
    res <- .parse_adj(src)
    res$table %>% dplyr::filter(deklination == "schwache") %>% dplyr::pull(wort) -> x
    expect_true("der gute" %in% x)
    res$table %>% dplyr::filter(deklination == "gemischte") %>% dplyr::pull(wort) -> x
    expect_true("ein guter" %in% x)
})
