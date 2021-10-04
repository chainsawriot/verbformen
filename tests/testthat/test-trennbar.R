## src needs to be serialized using xml2::write_xml


test_that("issue #1", {
    src <- rvest::read_html("../testdata/aufgeben.html")
    x <- verbformen:::.parse_verb(src)
    res <- x$table %>% dplyr::filter(tempus == "Imperativ")
    expect_equal(res$wort, c("gib auf", "geben auf", "gebt auf", "geben auf"))
})

test_that("Don't cause issue for untrennbare Verben", {
    ## x <- verbformen:::.request("geben")
    ## xml2::write_xml(x, "../testdata/geben.html")
    src <- rvest::read_html("../testdata/geben.html")
    x <- verbformen:::.parse_verb(src)
    res <- x$table %>% dplyr::filter(tempus == "Imperativ")
    expect_equal(res$wort, c("gib", "geben", "gebt", "geben"))    
})
