# R Class and Package for Generating Crosswords
Peter Meissner  
01 July 2017  




## Usage


```r
library(crossword)
cw <- Crossword$new(rows = 4, columns = 4)
cw$add_words(c("back", "nasa", "kick", "nuk", "ic", "sic"))
```

```
## #BACK# / 5 / 1 / right / 
## 
## #NASA# / 1 / 3 / down / 
## 
## #KICK# / 1 / 5 / down / 
## 
## #NUK# / 2 / 2 / right / 
## 
## #IC# / 3 / 4 / down / 
## 
## #SIC# / 4 / 2 / right /
```

## Usage 


```r
cw
```

```
## . 1 2 3 4 5 6
## 1 # # # # # #
## 2 # # N U K #
## 3 # . A # I #
## 4 # # S I C #
## 5 # B A C K #
## 6 # # # # # #
```



## Data


```r
cw$letters
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6]
## [1,] "#"  "#"  "#"  "#"  "#"  "#" 
## [2,] "#"  "#"  "N"  "U"  "K"  "#" 
## [3,] "#"  "."  "A"  "#"  "I"  "#" 
## [4,] "#"  "#"  "S"  "I"  "C"  "#" 
## [5,] "#"  "B"  "A"  "C"  "K"  "#" 
## [6,] "#"  "#"  "#"  "#"  "#"  "#"
```

## Data


```r
cw$words
```

```
## # A tibble: 6 x 6
##     row   col length direction  clue  word
##   <int> <int>  <int>     <chr> <chr> <chr>
## 1     5     1      4     right        BACK
## 2     1     3      4      down        NASA
## 3     1     5      4      down        KICK
## 4     2     2      3     right         NUK
## 5     3     4      2      down          IC
## 6     4     2      3     right         SIC
```


## Technicalities

- OOP:
    * not a fan of OOP ... but!
    * multiple pieces of data that only make sense together
    * easier to iterate on data and functions at the same time
    * state is important - adding words depends on the grid state
    * R6 (easy to use classes for traditional OOP)

## Technicalities

- data fields: 
    * `rows` (integer)
    * `columns` (integer)
    * `letters` (matrix)
    * `words` (data.frame)
    * [`restrictions_right`, `restrictions_down` (data.frame)]
    
## Technicalities

- methods: 
    * `initialize()` (row, columns)
    * `add_words()` (words, clues)
    * `density()` 
    * [`put_word_on_grid()`, `add_words()`, `update_grid_data()`, `print()`]


## Algorithm?

- quite dumb 
- loop over words
- data on cells: 
    * space (right/down)
    * letters already placed
- adding word
    * which cells have enough space
    * which cell's regex match the word
- placing based on weighting of cells 
    * balance right and down
    * try to put in the center of grid
    * try to cross as many letters on grid as possible




## End

- Peter Meissner
    * `twitter  <- "marvin_dpr"`
    * `homepage <- "pmeissner.com"`
    *  `Github   <- "petermeissner"`
    
    

- crossword
    * `status <- "work in progress"` 
    * `url <- "https://github.com/petermeissner/crossword"`



