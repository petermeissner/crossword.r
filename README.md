
# Generating Crosswords from Word Lists

**Status**

<a href="https://travis-ci.org/petermeissner/crossword">
<img src="https://api.travis-ci.org/petermeissner/crossword.svg?branch=master">
<a/> <a href="https://cran.r-project.org/package=crossword">
<img src="http://www.r-pkg.org/badges/version/crossword"> </a>
<a href="">
<img src="https://codecov.io/gh/petermeissner/crossword/branch/master/graph/badge.svg">
</a> <a href="">
<img src="http://cranlogs.r-pkg.org/badges/grand-total/crossword"> </a>
<a href=""> <img src="http://cranlogs.r-pkg.org/badges/crossword"> </a>

*lines of R code:* 625, *lines of test code:* 0

**Youtube video of Hamburg UseR Meetup presentation**

<https://youtu.be/56qrwa4bzK8>

**Development version**

0.3.2 - 2018-01-07 / 08:15:34

**Description**

Generate crosswords from a list of words.

**License**

MIT + file LICENSE <br>Peter Meissner

**Citation**

``` r
citation("crossword")
```

**BibTex for citing**

``` r
toBibtex(citation("crossword"))
```

**Installation**

Stable version from CRAN:

``` r
install.packages("crossword")
```

Latest development version from Github:

``` r
devtools::install_github("petermeissner/crossword")
```

# Usage

``` r
# load the library
library(crossword)

# set seed for pseudo random number generator
set.seed(123)

# create a new 4 by 4 crossword
cw       <- Crossword$new(rows = 10, columns = 10)
cw_words <- cw_wordlist_animal_en[sample(nrow(cw_wordlist_animal_en)),]

cw$add_words(
  words = cw_words$words,
  clues = cw_words$clues
)
```

``` r
# use the default print method to have a look
cw
## . . 1 2 3 4 5 6 7 8 9 0 1
## . # # # # # # # # # # # #
## 1 # S P I D E R # . . S #
## 2 # # . # G O R I L L A #
## 3 # T . . # J A C K A L #
## 4 # O X # H # A P E # M #
## 5 # R # K A N G A R O O #
## 6 # T # C R A B # . . N #
## 7 # O # T E R M I T E # #
## 8 # I . . # W E A S E L #
## 9 # S N A I L # # B E E #
## 0 # E E L # M I N N O W #
## 1 # # # # # # # # # # # #
```

``` r
# access to letters on the grid
cw$letters
##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12]
##  [1,] "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"   "#"   "#"  
##  [2,] "#"  "S"  "P"  "I"  "D"  "E"  "R"  "#"  "."  "."   "S"   "#"  
##  [3,] "#"  "#"  "."  "#"  "G"  "O"  "R"  "I"  "L"  "L"   "A"   "#"  
##  [4,] "#"  "T"  "."  "."  "#"  "J"  "A"  "C"  "K"  "A"   "L"   "#"  
##  [5,] "#"  "O"  "X"  "#"  "H"  "#"  "A"  "P"  "E"  "#"   "M"   "#"  
##  [6,] "#"  "R"  "#"  "K"  "A"  "N"  "G"  "A"  "R"  "O"   "O"   "#"  
##  [7,] "#"  "T"  "#"  "C"  "R"  "A"  "B"  "#"  "."  "."   "N"   "#"  
##  [8,] "#"  "O"  "#"  "T"  "E"  "R"  "M"  "I"  "T"  "E"   "#"   "#"  
##  [9,] "#"  "I"  "."  "."  "#"  "W"  "E"  "A"  "S"  "E"   "L"   "#"  
## [10,] "#"  "S"  "N"  "A"  "I"  "L"  "#"  "#"  "B"  "E"   "E"   "#"  
## [11,] "#"  "E"  "E"  "L"  "#"  "M"  "I"  "N"  "N"  "O"   "W"   "#"  
## [12,] "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"   "#"   "#"

# access to words placed on the grid, their co-ordinates and so on
cw$words
## # A tibble: 16 x 6
##      row   col length direction clue                           word    
##    <int> <int>  <int> <chr>     <fctr>                         <chr>   
##  1    11     1      3 right     Elongated fish                 EEL     
##  2     1    11      6 down      Strong swimmer and jumper      SALMON  
##  3     3     4      7 right     Largest primate                GORILLA 
##  4     2     1      6 right     Eight legged                   SPIDER  
##  5     3     2      8 down      Armored reptile                TORTOISE
##  6     4     5      6 right     Medium-sized omnivorous mammal JACKAL  
##  7    10     1      5 right     Slow but armored               SNAIL   
##  8     6     3      8 right     Australian original            KANGAROO
##  9     4     5      4 down      Fast runner with long ears     HARE    
## 10     8     3      7 right     Living in colonies             TERMITE 
## 11    11     5      6 right     Bait fish                      MINNOW  
## 12     9     5      6 right     Small, slender predator        WEASEL  
## 13    10     8      3 right     Striped but no predator        BEE     
## 14     7     3      4 right     clawed and armored sidewalker  CRAB    
## 15     5     6      3 right     Tailless humanlike primate     APE     
## 16     5     1      2 right     Castrated adult male cattle    OX
```
