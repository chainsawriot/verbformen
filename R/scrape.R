
#' Query verbformen
#'
#' This function queries the website verbformen.de for information of a word.
#'
#' @param input string, the word to be quried. Please note that verbformen.de accepts only verb, adjective, and noun. Other word types, e.g. adverb, are not supported. It is case-insensitive, i.e. "elefant" and "Elefant" are going to generate the same result.
#' @param tidy logical, whether to return a tidy tibble only
#' @param pos string, query for which pos of the input, possible values are "verb" (verb), "adj" (adjective), "sub" (noun) and "ukn" (unknown). This is useful for `input` that can be functioned as multiple POSs, e.g. "(r)adikal" can be both noun and adjective.
#' @param sleep numeric, sleep time after query. Please set it at least to 1 to prevent abuse.
#' @return an S3 object of the type of 'verbformenobj' or a tibble, depending on the parameter `tidy`
#' @author Chung-hong Chan <chainsawtiney@@gmail.com>
#' @export
verbformen <- function(input, tidy = FALSE, pos = "ukn", sleep = 1) {
    src <- .request(input, sleep = sleep, pos = pos)
    result <- .detect_word(src)
    if (is.na(result)) {
        return(NA)
    } else if (result == "verb") {
        res <- .parse_verb(src)
        res$input <- input
    } else if (result == "adj") {
        res <- .parse_adj(src)
        res$input <- input
    } else if (result == "noun") {
        res <- .parse_sub(src)
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

.request <- function(input, sleep = 1, pos = "ukn") {
    if (pos == "verb") {
        base_url <- "https://www.verbformen.de/konjugation/?w="
    } else if (pos == "adj") {
        base_url <- "https://www.verbformen.de/deklination/adjektive/?w="
    } else if (pos == "sub") {
        base_url <- "https://www.verbformen.de/deklination/substantive/?w="
    } else {
        base_url <- "https://www.verbformen.de/?w="
    }
    src <- rvest::read_html(paste0(base_url, input))
    Sys.sleep(sleep)
    return(src)
}


.clean_text <- function(x, dot = FALSE) {
    ## clean up all non-german characters
    if (dot) {
        rex <- "[^a-zA-Z \u00e4\u00f6\u00fc\u00c4\u00d6\u00dc\u00df\u00b7]"
    } else {
        rex <- "[^a-zA-Z \u00e4\u00f6\u00fc\u00c4\u00d6\u00dc\u00df]"
    }
    stringr::str_replace_all(x, rex, "")
}

#' @importFrom rlang .data
#' @importFrom rlang :=
.parse_vt <- function(vt) {
    vt %>% rvest::html_element("h2") %>% rvest::html_text() -> tempus
    vt %>% rvest::html_element("table") %>% rvest::html_table() -> konj
    if (ncol(konj) == 3) {
        ## trennbar
        if (tempus != "Imperativ") {
            konj %>% dplyr::mutate("X2" := paste(.data$X2, .data$X3)) -> konj
        } else {
            konj %>% dplyr::mutate("X1" := paste(.data$X1, .data$X3)) -> konj            
        }
    }
    if (tempus == "Imperativ") {
        tab <- tibble::tibble(person = konj$X2, tempus = tempus, wort = konj$X1) %>% dplyr::filter(!is.na(.data$person))
    } else if (tempus %in% c("Infinitiv", "Partizip")) {
        tab <- tibble::tibble(person = NA, tempus = tempus, wort = konj$X1)
    } else {
        tab <- tibble::tibble(person = konj$X1, tempus = tempus, wort = konj$X2)
    }
    tab$wort <- .clean_text(tab$wort)
    return(tab)
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
    allp[[1]] %>% .squish_text %>% stringr::str_split("[ \u00b7]+") %>% unlist -> verbbasicinfo
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

.p <- function(y) {
    if (length(y) >= 1) {
        return(TRUE)
    }
    if (is.null(y)) {
        return(FALSE)
    }
    if (identical(y, character(0))) {
        return(FALSE)
    }
    if (is.na(y)) {
        return(FALSE)
    }
    return(TRUE)
}

.d <- function(x, y) {
    if (.p(y)) {
        cat(cli::style_bold(x), y, "\n")
    }
}

#' @method print verbformenobj
#' @export
print.verbformenobj <- function(x, ...) {
    cli::cli_h1(x$input)
    .d("POS:", x$pos)
    .d("Grundform:", x$grundform)
    .d("Komparation:", x$comparativ)
    .d("Stammformen:", x$stammformen)
    .d("Info:", x$basicinfo)
    .d("Bedeutung:", x$bedeutung)
    .d("Englisch:", x$eng)
    .d("Pr\u00e4positionen:", x$praep)
    if (x$pos == "verb") {
        title <- "Konjugation"
    } else {
        title <- "Deklination"
    }
    cli::cli_h1(title)
    print(x$table)
}

#' tidy up verbformenobj to tibble
#'
#' This function converts the object generated by verbformen to a tidy tibble.
#' @param x, an S3 object of the type "verformenobj"
#' @param ..., other parameters
#' @return a tibble
#' @export
tidy <- function(x, ...) {
    UseMethod("tidy", x)
}

#' @method tidy verbformenobj
#' @rdname tidy
#' @export
tidy.verbformenobj <- function(x, ...) {
    dplyr::bind_cols(tibble::tibble(input = x$input, grundform = x$grundform, pos = x$pos), x$table)
}

.parse_adjt <- function(vt, deklination = "starke") {
    vt %>% rvest::html_element("h2") %>% rvest::html_text() -> genush2
    vt %>% rvest::html_element("h3") %>% rvest::html_text() -> genush3
    purrr::discard(c(genush3, genush2), is.na) -> genus
    vt %>% rvest::html_element("table") %>% rvest::html_table() -> konj
    if (ncol(konj) == 3) {
        konj %>% dplyr::mutate("X2" := paste(.data$X2, .data$X3)) -> konj
    }
    if (any(stringr::str_detect(konj$X2, "/"))) {
        ## kill all alternative spellings, issue #2
        konj$X2 <- stringr::str_replace(konj$X2, "/.+", "")
    }
    tab <- tibble::tibble(deklination = deklination, genus = genus, kasus = konj$X1, wort = konj$X2)
    tab$wort <- .clean_text(tab$wort)
    return(tab)
}


.parse_adjt_all <- function(rbox, deklination) {
    rbox %>% rvest::html_elements("div.vTbl") %>% purrr::map_dfr(.parse_adjt, deklination = deklination)
}

.parse_adj <- function(src) {
    .extract_rbox(src) -> rbox
    rbox[[1]] %>% rvest::html_elements("p") -> allp
    allp[[1]] %>% .squish_text %>% stringr::str_split("[ \u00b7]+") %>% unlist -> grundform
    allp[[2]] %>% .squish_text -> comparativ
    rbox[[1]] %>% rvest::html_element("header") %>% .squish_text() -> info
    purrr::map2_dfr(rbox[2:4], c("starke", "schwache", "gemischte"), .parse_adjt_all) -> adj_table
    prad <- tibble::tibble(deklination = "Pr\u00e4dikativ", genus = NA, kasus = NA, wort = grundform)
    adj_table <- dplyr::bind_rows(prad, adj_table)
    res <- list(pos = "Adjektiv", "basicinfo" = info, "grundform" = grundform, "comparativ" = comparativ, "table" = adj_table)
    class(res) <- append(class(res), "verbformenobj")
    return(res)
}

.parse_sub <- function(src) {
    .extract_rbox(src) -> rbox
    rbox[[1]] %>% rvest::html_elements("p") -> allp
    rbox[[1]] %>% rvest::html_element("p.vGrnd") %>% .squish_text() -> grundform
    rbox[[1]] %>% rvest::html_element("p.vStm") %>% .squish_text() %>% .clean_text(dot = TRUE) -> stammformen
    allp[[1]] %>% .squish_text %>% stringr::str_split("[ \u00b7]+") %>% unlist -> info
    rbox[[1]] %>% rvest::html_element("span[lang='en']") %>% .squish_text -> eng
    rbox[[1]] %>% rvest::html_element("p.rInf.r1Zeile") %>% rvest::html_element("i") %>% .squish_text -> meaning
    rbox %>% rvest::html_elements("div.vTbl") %>% purrr::map_dfr(.parse_subt) -> sub_table
    res <- list(pos = "Substantiv", "basicinfo" = info, "grundform" = grundform, "stammformen" = stammformen, "englisch" = eng, "bedeutung" = meaning,  "table" = sub_table)
    class(res) <- append(class(res), "verbformenobj")
    return(res)
}


.parse_subt <- function(vt) {
    vt %>% rvest::html_element("h2") %>% rvest::html_text() -> genush2
    vt %>% rvest::html_element("h3") %>% rvest::html_text() -> genush3
    purrr::discard(c(genush3, genush2), is.na) -> numerus
    vt %>% rvest::html_element("table") %>% rvest::html_table() -> konj
    tab <- tibble::tibble(numerus = numerus, kasus = konj$X1, artikel = konj$X2, wort = konj$X3)
    tab$wort <- .clean_text(tab$wort)
    return(tab)
}
