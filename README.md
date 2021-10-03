
<!-- README.md is generated from README.Rmd. Please edit that file -->

# verbformen

<!-- badges: start -->

<!-- badges: end -->

The goal of verbformen is to query the website
[verbformen.de](https://www.verbformen.de/) for *Konjugationen*
(conjugations, derived forms of a verb) and *Deklinationen*
(declensions, different forms of a noun or an adjective) of a German
word. Additional data are also provided (e.g. whether the verb is
seperable). The data is provided with the [CC
BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) License. The
copyright holder of the data is Netzverb® Deutsch. Please share the data
with the same license and an appropriate attribution. More information
is available in the
[Nutzungsbedingungen](https://www.netzverb.de/impressum.htm) of the
website.

## Installation

You can install the GitHub version of verbformen with:

``` r
devtools::install_github("chainsawriot/verbformen")
```

## Example

Query verbformen.de. Please note that the query does not need to be in
the *Grundform*. For example, querying *bin* (no need to be *sein*):

``` r
library(verbformen)
verbformen("bin")
#> 
#> ── bin ─────────────────────────────────────────────────────────────────────────
#> POS: Verb 
#> Grundform: sein 
#> Stammformen: ist · war · ist gewesen 
#> Info: A1 unregelmäßig sein 
#> Bedeutung: sich in einem angegeben Zustand befinden; sich am genannten Ort befinden; existieren; darstellen; (etwas) darstellen; seine 
#> Englisch: be, exist, be (of) opinion, be in favour (of), be (against), be an opponent (of), be contrary (to), be opposed (to), oppose, object (to) 
#> Präpositionen: (Dat., Akk., Gen., gegen+A, für+A, von+D, bei+D, an+D, nach+D, in+D, aus+D, außer+D, als, wie)
#> 
#> ── Konjugation: ────────────────────────────────────────────────────────────────
#> # A tibble: 32 × 3
#>    person tempus     konjugation
#>    <chr>  <chr>      <chr>      
#>  1 ich    Präsens    bin        
#>  2 du     Präsens    bist       
#>  3 er     Präsens    ist        
#>  4 wir    Präsens    sind       
#>  5 ihr    Präsens    seid       
#>  6 sie    Präsens    sind       
#>  7 ich    Präteritum war        
#>  8 du     Präteritum warst      
#>  9 er     Präteritum war        
#> 10 wir    Präteritum waren      
#> # … with 22 more rows
```

If you don’t need those additional information, you can get a tibble in
the tidy format using the argument `tidy`.

``` r
verbformen("aufgegeben", tidy = TRUE)
#> # A tibble: 34 × 6
#>    input      grundform pos   person tempus     konjugation
#>    <chr>      <chr>     <chr> <chr>  <chr>      <chr>      
#>  1 aufgegeben auf·geben Verb  ich    Präsens    gebe auf   
#>  2 aufgegeben auf·geben Verb  du     Präsens    gibst auf  
#>  3 aufgegeben auf·geben Verb  er     Präsens    gibt auf   
#>  4 aufgegeben auf·geben Verb  wir    Präsens    geben auf  
#>  5 aufgegeben auf·geben Verb  ihr    Präsens    gebt auf   
#>  6 aufgegeben auf·geben Verb  sie    Präsens    geben auf  
#>  7 aufgegeben auf·geben Verb  ich    Präteritum gab auf    
#>  8 aufgegeben auf·geben Verb  du     Präteritum gabst auf  
#>  9 aufgegeben auf·geben Verb  er     Präteritum gab auf    
#> 10 aufgegeben auf·geben Verb  wir    Präteritum gaben auf  
#> # … with 24 more rows
```

You can also tidy the object after a query.

``` r
x <- verbformen("befinden")
x
#> 
#> ── befinden ────────────────────────────────────────────────────────────────────
#> POS: Verb 
#> Grundform: befinden 
#> Stammformen: befindet · befand · hat befunden 
#> Info: B1 unregelmäßig haben untrennbar 
#> Bedeutung: irgendwo aufhalten, gegenwärtig sein; etwas, jemanden einschätzen; aufhalten; entscheiden; existieren; beurteilen 
#> Englisch: be located, decide, find, determine, deem, adjudge, be arranged, reside, stand, be situated somewhere 
#> Präpositionen: (sich+A, Akk., auf+D, unter+D, über+D, für+A, über+A, in+D, als)
#> 
#> ── Konjugation: ────────────────────────────────────────────────────────────────
#> # A tibble: 32 × 3
#>    person tempus     konjugation
#>    <chr>  <chr>      <chr>      
#>  1 ich    Präsens    befinde    
#>  2 du     Präsens    befindest  
#>  3 er     Präsens    befindet   
#>  4 wir    Präsens    befinden   
#>  5 ihr    Präsens    befindet   
#>  6 sie    Präsens    befinden   
#>  7 ich    Präteritum befand     
#>  8 du     Präteritum befandest  
#>  9 er     Präteritum befand     
#> 10 wir    Präteritum befanden   
#> # … with 22 more rows
tidy(x)
#> # A tibble: 32 × 6
#>    input    grundform pos   person tempus     konjugation
#>    <chr>    <chr>     <chr> <chr>  <chr>      <chr>      
#>  1 befinden befinden  Verb  ich    Präsens    befinde    
#>  2 befinden befinden  Verb  du     Präsens    befindest  
#>  3 befinden befinden  Verb  er     Präsens    befindet   
#>  4 befinden befinden  Verb  wir    Präsens    befinden   
#>  5 befinden befinden  Verb  ihr    Präsens    befindet   
#>  6 befinden befinden  Verb  sie    Präsens    befinden   
#>  7 befinden befinden  Verb  ich    Präteritum befand     
#>  8 befinden befinden  Verb  du     Präteritum befandest  
#>  9 befinden befinden  Verb  er     Präteritum befand     
#> 10 befinden befinden  Verb  wir    Präteritum befanden   
#> # … with 22 more rows
```
