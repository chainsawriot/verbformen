#' @importFrom magrittr %>%

.clean_text <- function(x) {
    ## clean up all non-german characters
    stringr::str_replace_all(x, "[^a-zA-Z äöüÄÖÜß]", "")
}

.parse_vt <- function(vt) {
    vt %>% rvest::html_element("h2") %>% rvest::html_text() -> tempus
    vt %>% rvest::html_element("table") %>% rvest::html_table() -> konj
    if (ncol(konj) == 3) {
        ## trennbar
        konj %>% dplyr::mutate(X2 = paste(X2, X3)) -> konj
    }
    if (tempus == "Imperativ") {
        tab <- tibble::tibble(person = konj$X2, tempus = tempus, konjugation = konj$X1) %>% dplyr::filter(!is.na(person))
    } else if (tempus %in% c("Infinitiv", "Partizip")) {
        tab <- tibble::tibble(person = NA, tempus = tempus, konjugation = konj$X1)
    } else {
        tab <- tibble::tibble(person = konj$X1, tempus = tempus, konjugation = konj$X2)
    }
    tab$konjugation <- .clean_text(tab$konjugation)
    return(tab)
}

.request <- function(input, sleep) {
    src <- rvest::read_html(paste0("https://www.verbformen.de/?w=", input))
    Sys.sleep(sleep)
    return(src)
}

.extract_rbox <- function(src) {
    src %>% rvest::html_elements("section.rBoxWht")
}

.extract_verb_table <- function(src) {
    .extract_rbox(src) -> rbox
    rbox[[2]] %>% rvest::html_elements("div.vTbl") %>% purrr::map_dfr(.parse_vt)
}

.detect_word <- function(src) {
    src %>% rvest::html_element("div.rInfo") %>% rvest::html_elements("nav.rBoxWht") %>% rvest::html_element("h2") %>% rvest::html_text() -> right_res
    if (length(right_res) == 0) {
        ## not found
        return(NA)
    }
    if ("Adjektive" %in% right_res) {
        return("adj")  
    } else if ("Substantive" %in% right_res) {
        return("noun")
    } else {
        return("verb")
    }
}


.is_node <- function(p, css) {
    p %>% rvest::html_element(css) %>% is.na %>% `!`
}

.squish_text <- function(node) {
    node %>% rvest::html_text() %>% stringr::str_squish()
}

.parse_verb <- function(src) {
    .extract_rbox(src) -> rbox
    rbox[[1]] %>% rvest::html_elements("p") -> allp
    allp[[1]] %>% .squish_text %>% stringr::str_split("[ ·]+") %>% unlist -> verbbasicinfo
    rbox[[1]] %>% rvest::html_element("p#grundform") %>% .squish_text -> grundform
    rbox[[1]] %>% rvest::html_element("p#stammformen") %>% .squish_text -> stammformen
    purrr::keep(allp, .is_node, css = "span[lang='en']") %>% .squish_text -> eng
    purrr::keep(allp, .is_node, css = "span[title^='mit']") %>% .squish_text -> praep
    rbox[[1]] %>% rvest::html_element("p.rInf.r1Zeile") %>% rvest::html_element("i") %>% .squish_text -> meaning
    verb_table <- .extract_verb_table(src)
    res <- list(pos = "Verb", "basicinfo" = verbbasicinfo, "grundform" = grundform, "stammformen" = stammformen, "bedeutung" = meaning, "englisch" = eng, "praep" = praep, "table" = verb_table)
    class(res) <- append(class(res), "verbformenobj")
    return(res)
}

#' @export
verbformen <- function(input, tidy = FALSE, sleep = 1) {
    src <- .request(input, sleep = sleep)
    result <- .detect_word(src)
    if (is.na(result)) {
        return(NA)
    } else if (result == "verb") {
        res <- .parse_verb(src)
        res$input <- input
    } else {
        warning("Scraping ", result, " is not implemented")
        return(NA)
    }
    if (tidy) {
        return(tidy(res))
    }
    return(res)
}

.d <- function(x, y) {
    cat(cli::style_bold(x), y, "\n")
}

#' @method print verbformenobj
#' @export
print.verbformenobj <- function(obj, ...) {
    cli::cli_h1(obj$input)
    .d("POS:", obj$pos)
    .d("Grundform:", obj$grundform)
    .d("Stammformen:", obj$stammformen)
    .d("Info:", obj$basicinfo)
    .d("Bedeutung:", obj$bedeutung)
    .d("Englisch:", obj$eng)
    .d("Präpositionen:", obj$praep)
    cli::cli_h1("Konjugation:")
    print(obj$table)
}

#' @export
tidy <- function(x, ...) {
    UseMethod("tidy", x)
}

#' @method tidy verbformenobj
#' @export
tidy.verbformenobj <- function(obj, ...) {
    dplyr::bind_cols(tibble::tibble(input = obj$input, grundform = obj$grundform, pos = obj$pos), obj$table)
}
