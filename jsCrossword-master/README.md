jsCrossword
===========

Nice JavaScript Crossword puzzle.
- Nice UI
- Interaction between grid and clues
- Navigation with cursor and keyboard

#History

1. [Jesse Weisbeck](http://www.jesseweisbeck.com/) has built this crossword puzzle to provide an enhanced, more intuitive user experience with javascript.
1. [Ash Kyd](http://ash.ms/) did bug fixes and added cool features (e.g. the "reveal a random letter" cheat).
1. [The Dod](http://thedod.github.io) added rot13 (against accidental peeking) and an example puzzle that uses it (EFF's [Xmas 2013 NSA puzzle](https://www.eff.org/deeplinks/2013/12/crossword-what-did-we-learn-about-nsa-year)).

Your turn :)

#About puzzleData or entryData

The data used to generate the crossword is the main input and is located in js/script.js file.

For particular purposes I use [HartasCuerdas/puzzleData-generator](https://github.com/HartasCuerdas/puzzleData-generator). This generator uses the output produced by [HartasCuerdas/binarify](https://github.com/HartasCuerdas/xwbinarify) that extracts dark and light squares and numbers (clue references) from a digital image of a crossword.
