
Generating Crosswords from Word Lists
=====================================

**Status**

<a href="https://travis-ci.org/petermeissner/crossword.r"> <img src="https://api.travis-ci.org/petermeissner/crossword.r.svg?branch=master"> <a/> <a href="https://cran.r-project.org/package=crossword.r"> <img src="http://www.r-pkg.org/badges/version/crossword.r"> </a> <a href="https://codecov.io/gh/petermeissner/crossword.r/branch/master"> <img src="https://codecov.io/gh/petermeissner/crossword.r/branch/master/graph/badge.svg"> </a> <a href="https://r-pkg.org/maint/retep.meissner@gmail.com"> <img src="http://cranlogs.r-pkg.org/badges/grand-total/crossword.r"> </a> <a href="https://r-pkg.org/maint/retep.meissner@gmail.com"> <img src="http://cranlogs.r-pkg.org/badges/crossword.r"> </a>

*lines of R code:* 397, *lines of test code:* 50

**Youtube video of Hamburg UseR Meetup presentation**

<https://youtu.be/56qrwa4bzK8>

**Development version**

0.3.4 - 2018-01-18 / 21:12:57

**Description**

Generate crosswords from a list of words.

**License**

MIT + file LICENSE <br>Peter Meissner

**Citation**

``` r
citation("crossword.r")
```

**BibTex for citing**

``` r
toBibtex(citation("crossword.r"))
```

**Installation**

Stable version from CRAN:

``` r
install.packages("crossword.r")
```

Latest development version from Github:

``` r
devtools::install_github("petermeissner/crossword.r")
```

Usage
=====

``` r
# load the library
library(crossword.r)

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
## 1 # E E L # . # B . # S #
## 2 # T E R M I T E # G K #
## 3 # H A R E # O E W I U #
## 4 # O X # . G R # O R N #
## 5 # . . # A N T # M A K #
## 6 # F L Y # U O B B F # #
## 7 # # F O X # I A A F # #
## 8 # D U C K # S T T E D #
## 9 # # S N A K E # # # O #
## 0 # C O D # . # F R O G #
## 1 # # # # # # # # # # # #
```

``` r
# access to letters on the grid
cw$letters
##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12]
##  [1,] "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"   "#"   "#"  
##  [2,] "#"  "E"  "E"  "L"  "#"  "."  "#"  "B"  "."  "#"   "S"   "#"  
##  [3,] "#"  "T"  "E"  "R"  "M"  "I"  "T"  "E"  "#"  "G"   "K"   "#"  
##  [4,] "#"  "H"  "A"  "R"  "E"  "#"  "O"  "E"  "W"  "I"   "U"   "#"  
##  [5,] "#"  "O"  "X"  "#"  "."  "G"  "R"  "#"  "O"  "R"   "N"   "#"  
##  [6,] "#"  "."  "."  "#"  "A"  "N"  "T"  "#"  "M"  "A"   "K"   "#"  
##  [7,] "#"  "F"  "L"  "Y"  "#"  "U"  "O"  "B"  "B"  "F"   "#"   "#"  
##  [8,] "#"  "#"  "F"  "O"  "X"  "#"  "I"  "A"  "A"  "F"   "#"   "#"  
##  [9,] "#"  "D"  "U"  "C"  "K"  "#"  "S"  "T"  "T"  "E"   "D"   "#"  
## [10,] "#"  "#"  "S"  "N"  "A"  "K"  "E"  "#"  "#"  "#"   "O"   "#"  
## [11,] "#"  "C"  "O"  "D"  "#"  "."  "#"  "F"  "R"  "O"   "G"   "#"  
## [12,] "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"  "#"   "#"   "#"

# access to words placed on the grid, their co-ordinates and so on
cw$words
## # A tibble: 19 x 6
##      row   col length direction word     clue                                                                
##    <int> <int>  <int> <chr>     <chr>    <chr>                                                               
##  1    10     1      3 right     COD      Popular food fish with a mild flavour and a dense, flaky, white fle…
##  2     1    10      5 down      SKUNK    Animals known for its ability to spray strong unpleasant liquid     
##  3     1     1      3 right     EEL      Elongated fish                                                      
##  4     2     1      7 right     TERMITE  Living in colonies                                                  
##  5     2     6      8 down      TORTOISE Armored reptile                                                     
##  6     5     4      3 right     ANT      Small with mandibles and antenna                                    
##  7     2     9      7 down      GIRAFFE  One of the big africans                                             
##  8     9     2      5 right     SNAKE    Elongated, legless, carnivorous reptile                             
##  9     4     5      3 down      GNU      Also a licence                                                      
## 10     3     8      6 down      WOMBAT   Australian burrow digger                                            
## 11     8     1      4 right     DUCK     Water bird                                                          
## 12     3     1      4 right     HARE     Fast runner with long ears                                          
## 13    10     7      4 right     FROG     Tailless amphibian                                                  
## 14     1     7      3 down      BEE      Striped but no predator                                             
## 15     4     1      2 right     OX       Castrated adult male cattle                                         
## 16     6     1      3 right     FLY      Small insect                                                        
## 17     7     2      3 right     FOX      Upright triangular ears, a pointed, slightly upturned snout, and a …
## 18     6     7      3 down      BAT      Flying mammal                                                       
## 19     8    10      3 down      DOG      A man's best friend.
```
