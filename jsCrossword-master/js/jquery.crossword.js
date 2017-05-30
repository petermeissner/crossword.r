/**
* Crossword Puzzle by Jesse Weisbeck (@jlweisbeck)
* Various tweaks by Ash Kyd (@AshKyd)
* Rot13 tweak and nsa.js content option by The Dod (@TheRealDod)
*
*/
(function($){
	$.fn.crossword = function(opts) {
			/*
				Qurossword Puzzle: a javascript + jQuery crossword puzzle
				"light" refers to a white box - or an input

				DEV NOTES:
				- activePosition and activeClueIndex are the primary vars that set the ui whenever there's an interaction
				- 'Entry' is a puzzler term used to describe the group of letter inputs representing a word solution
				- This puzzle isn't designed to securely hide answerers. A user can see answerers in the js source
					- The Dod added an options for rot13 (against *accidental* disclosure. Not against cheating).
					- An xhr provision can be added later to hit an endpoint on keyup to check the answerer
				- The ordering of the array of problems doesn't matter. The position & orientation properties is enough information
				- Puzzle authors must provide a starting x,y coordinates for each entry
				- Entry orientation must be provided in lieu of provided ending x,y coordinates (script could be adjust to use ending x,y coords)
				- Answers are best provided in lower-case, and can NOT have spaces - will add support for that later
			*/

			var puzz = {}; // put data array in object literal to namespace it into safety
			puzz.data = opts.entryData;
			puzz.successCallback = opts.successCallback;

			// append clues markup after puzzle wrapper div
			// This should be moved into a configuration object
			this.wrap( "<div class='crossword-container'></div>" );
			this.after('<div style="clear:both"></div>');
			this.after('<div id="puzzle-clues"><div class="across"><h2>' +croswordMessages.Across + '</h2><ul></ul></div><div class="down"><h2>' + croswordMessages.Down + '</h2><ul></ul></div></div>');


			// initialize some variables
			var message = '<p>'+croswordMessages.Completed+'</p>';
			var $complete = $('<div class="overlay"><h1>' +croswordMessages.Congratulations + '</h1><div class="message">'+ message +'</div></div>');


			var tbl = ['<table id="puzzle" class="crossword">'];
			var puzzEl = this;
			var clues = $('#puzzle-clues');
			var clueLiEls;
			var coords;
			var entryCount = puzz.data.length;
			var entries = [];
			var rows = [];
			var cols = [];
			var tabindex;
			var $actives;
			var activePosition = 0;
			var activeClueIndex = 0;
			var hintsRemaining = 10;
			var currOri;
			var targetInput;
			var mode = 'interacting';
			var z = 0;
			var showAnswers=opts.showAnswers || false;
			var GAME_DELIM='-';
			var LOCALSTORAGE_KEY='crossword-';
			var COOKIE_EXPIRY=21; //days
			var HINT_CAPTION = croswordMessages.HintCaption;


			/**
			 * Name for our savegame cookie.
			 * @type {String}
			 */
			var cookieName = LOCALSTORAGE_KEY+opts.id;

			var puzInit = {

				init: function() {
					puzz.data = util.calculateCluePositions(puzz.data);
					currOri = 'across'; // app's init orientation could move to config object
					// Set keyup handlers for the 'entry' inputs that will be added presently
					puzzEl.delegate('input', 'keydown', function(e){
						// Ignore modifier keys
						var modifierKeys = [16, 17, 18, 91, 224];
						if ($.inArray(e.which, modifierKeys) >-1) {
							return;
						}

						mode = 'interacting';

						// need to figure out orientation up front, before we attempt to highlight an entry
						switch(e.which) {
							case 39:
							case 37:
								currOri = 'across';
								break;
							case 38:
							case 40:
								currOri = 'down';
								break;
							default:
								break;
						}

						if (e.keyCode === 9) {
							return false;
						}
						else if (e.keyCode === 8 || e.keyCode === 46) {
							e.target.value = '';
							if(currOri === 'across'){
								nav.nextPrevNav(e, 37);
							}
							else {
								nav.nextPrevNav(e, 38);
							}
							return true;
						}
						else if (
							e.keyCode === 37 ||
							e.keyCode === 38 ||
							e.keyCode === 39 ||
							e.keyCode === 40
						) {
							nav.nextPrevNav(e);
						}
						else {
							e.target.value = e.originalEvent.key;
							var solved = puzInit.checkAnswer(e);
							if (solved) {
								// If current word is solved, move on to next word
								nav.updateByEntry(null, true);
							}
							else if(currOri === 'across'){
								nav.nextPrevNav(e, 39);
							}
							else {
								nav.nextPrevNav(e, 40);
							}
						}

						e.preventDefault();
						return false;
					});

					// tab navigation handler setup
					puzzEl.delegate('input', 'keydown', function(e) {
						if ( e.keyCode === 9) {

							mode = "setting ui";
							puzInit.checkAnswer(e)
							nav.updateByEntry(e);

						} else {
							return true;
						}

						e.preventDefault();

					});

					// tab navigation handler setup
					puzzEl.delegate('input', 'click', function(e) {
						mode = "setting ui";
						nav.updateByEntry(e);
						e.preventDefault();
					});


					// click/tab clues 'navigation' handler setup
					clues.delegate('li', 'click', function(e) {
						mode = 'setting ui';
						if (!e.keyCode) {
							nav.updateByNav(e);
						}
						e.preventDefault();
					});


					// highlight the letter in selected 'light' - better ux than making user highlight letter with second action
					puzzEl.delegate('#puzzle', 'click', function(e) {
						$(e.target).focus();
						$(e.target).select();
					});

					// DELETE FOR BG
					puzInit.calcCoords();

					// Puzzle clues added to DOM in calcCoords(), so now immediately put mouse focus on first clue
					clueLiEls = $('#puzzle-clues li');
					$('.' + currOri + ' li' ).eq(0).addClass('clues-active').focus();

					// DELETE FOR BG
					puzInit.buildTable();
					puzInit.buildEntries();
					puzInit.buildResetButton();
					puzInit.buildHintButton();
					puzInit.adjustDims();
					puzInit.loadGame();

				},

				/*
					- Given beginning coordinates, calculate all coordinates for entries, puts them into entries array
					- Builds clue markup and puts screen focus on the first one
				*/
				calcCoords: function() {
					/*
						Calculate all puzzle entry coordinates, put into entries array
					*/
					for (var i = 0, p = entryCount; i < p; ++i) {
						// set up array of coordinates for each problem
						entries.push(i);
						entries[i] = [];
						thisPuzz = puzz.data[i];

						for (var x=0, j = thisPuzz.answer.length; x < j; ++x) {
							entries[i].push(x);
							coords = thisPuzz.orientation === 'across' ? "" + thisPuzz.startx++ + "," + thisPuzz.starty + "" : "" + thisPuzz.startx + "," + thisPuzz.starty++ + "" ;
							entries[i][x] = coords;
						}

						// while we're in here, add clues to DOM!
						$('.' + thisPuzz.orientation + ' ul').append(
							$('<li tabindex="1" data-position="' + i + '"></li>')
								.text(thisPuzz.clue)
								.prepend($('<span class="words">').text(thisPuzz.words ? thisPuzz.words : thisPuzz.answer.length + ' ' + croswordMessages.Characters))
								.prepend('<span class="position">'+thisPuzz.position+'</span> ')
						);
					}

					// Calculate rows/cols by finding max coords of each entry, then picking the highest
					for (var i = 0, p = entryCount; i < p; ++i) {
						for (var x=0; x < entries[i].length; x++) {
							cols.push(entries[i][x].split(',')[0]);
							rows.push(entries[i][x].split(',')[1]);
						};
					}

					rows = Math.max.apply(Math, rows) + "";
					cols = Math.max.apply(Math, cols) + "";

				},

				/*
					Build the table markup
					- adds [data-coords] to each <td> cell
				*/
				buildTable: function() {
					for (var i=1; i <= rows; ++i) {
						tbl.push("<tr>");
							for (var x=1; x <= cols; ++x) {
								tbl.push('<td data-coords="' + x + ',' + i + '"></td>');
							};
						tbl.push("</tr>");
					};

					tbl.push("</table>");
					puzzEl.append(tbl.join(''));
				},

				/*
					Builds entries into table
					- Adds entry class(es) to <td> cells
					- Adds tabindexes to <inputs>
				*/
				buildEntries: function() {
					var puzzCells = $('#puzzle td'),
						light,
						$groupedLights,
						hasOffset = false,
						positionOffset = entryCount - puzz.data[puzz.data.length-1].position; // diff. between total ENTRIES and highest POSITIONS

					for (var x=1, p = entryCount; x <= p; ++x) {
						var letters = (puzz.data[x-1].rot13 ? util.rot13(puzz.data[x-1].answer) : puzz.data[x-1].answer).split('');

						for (var i=0; i < entries[x-1].length; ++i) {
							var thisPuzz = puzz.data[x-1];
							light = $('[data-coords="' + entries[x-1][i] + '"]');

							// check if POSITION property of the entry on current go-round is same as previous.
							// If so, it means there's an across & down entry for the position.
							// Therefore you need to subtract the offset when applying the entry class.
							if(x > 1 ){
								if (thisPuzz.position === puzz.data[x-2].position) {
									hasOffset = true;
								};
							}

							if(light.is(':empty')){
								var $container = $('<div>');
								var $input = $('<input maxlength="1" val="" type="text" tabindex="-1" />');
								if(showAnswers){
									$input.val(letters[i]);
								}
								$container.append($input);

								light
									.addClass('light')
									.append($container);
							}

							var cells = light.data('cells') || [];

							cells.push({
								position : x-1,
								entry: x,
								letter : i,
								data : thisPuzz,
								el : light
							});
							light.data('cells',cells);

							// Add the number to the first letter of each word.
							if(i==0){
								light.find('div').append('<span>'+puzz.data[x-1].position+'</span>');
							}

							light
								.addClass('position-' + (x-1))
								.addClass('entry-' + (hasOffset ? x - positionOffset : x));
						};

					};

					util.highlightEntry();
					util.highlightClue();
					$('.active').eq(0).focus();
					$('.active').eq(0).select();

				},


				updateHintsRemaining : function(remaining){
					clues.find('.reveal').text(HINT_CAPTION.replace('%',remaining));
				},
				buildHintButton: function(){
					var _this = this;
					var $button = $('<a class="btn reveal"></a>');

					$button.click(function(){
						if(hintsRemaining < 1){
							return;
						}

						var data = puzz.data[activePosition];
						var $entries = $('.position-'+(activePosition)+' input');
						var possibleCells = [];

						// filter out entries which have already been filled.
						$entries.each(function(i){
							if($(this).val() == ''){
								possibleCells.push(i);
							}
						});

						if(possibleCells.length == 0){
							// You've already solved this word.
							return;
						}
						var random = Math.round(Math.random()*(possibleCells.length-1));
						var $entry = $entries.eq(possibleCells[random]);

						var clue = data.answer.substr(possibleCells[random],1);
						if (data.rot13) clue = util.rot13(clue);
						$entry.val(clue);

						_this.updateHintsRemaining(--hintsRemaining);

						_this.saveGame();
					});
					clues.prepend($button);
					this.updateHintsRemaining(hintsRemaining);
				},

				buildResetButton: function() {
					var _this = this;
					var $button = $('<a class="btn reset">Reset Puzzle</a>');

					$button.click(function(){
						if (confirm('Are you sure you want to reset the puzzle?')) {
							Cookies.remove(cookieName);
							location.reload();
						}
					});
					clues.prepend($button);
				},

				adjustDims : function(){
					var onResize = function(){
						var $table = $(puzzEl).find('table');

						var w = $table.width();
						$table.height(w);
						$table.css('font-size',w/400+'em');

						var cellHeight = Math.ceil($table.find('input').width());
						$table.find('input').height(cellHeight);
						var tdwidth= $table.find('td:eq(0)').width();

						$table.height(rows *tdwidth);
						$table.find('td').height(tdwidth);

					};
					$(window).resize(onResize);
					onResize();

					// Sometimes this gets fired before time, so fire it again
					// on window load when the DOM's presumably settled.
					$(window).load(function(){
						onResize();
					})
				},


				/*
					- Checks current entry input group value against answer
					- If not complete, auto-selects next input for user
				*/
				checkAnswer: function(e) {
					var valToCheck, currVal, cells;
					cells = $(e.target).closest('td').data('cells');

					util.getActivePositionFromClassGroup($(e.target));

					valToCheck = puzz.data[activePosition].answer.toLowerCase();
					if (puzz.data[activePosition].rot13) valToCheck = util.rot13(valToCheck);
					currVal = $('.position-' + activePosition + ' input')
						.map(function() {
							return $(this)
								.val()
								.toLowerCase();
						})
						.get()
						.join('');

					if(valToCheck === currVal){
						$('.active')
							.addClass('done')
							.removeClass('active');

						$('.clues-active').addClass('clue-done');
						puzz.data[activePosition].solved = true;
					} else {
						$('.active')
							.removeClass('done')
							.addClass('active');

						$('.clues-active').removeClass('clue-done');
						puzz.data[activePosition].solved = false;
					}

					var gameComplete = true;
					for(var i=0; i<puzz.data.length; i++){
						if(!puzz.data[i].solved){
							gameComplete = false;
							break;
						}
					}
					if(gameComplete){
						this.triggerGameWon();
					}

					this.saveGame();

					return puzz.data[activePosition].solved;
				},
				triggerGameWon : function(){
					if(puzz.won)return;
					puzz.won = true;
					clues.append($complete);
					if(puzz.successCallback!=undefined){
						puzz.successCallback();
					}

				},

				/**
				 * Save the game to a cookie, specified up there ^^ with our
				 * game settings.
				 */
				saveGame : function(){
					var gameString = '';
					puzzEl.find('input').each(function(){
						gameString += ($(this).val() || GAME_DELIM);
					});
					gameString += hintsRemaining;

					// Set the cookie using js-cookie if it exists.
					// https://github.com/js-cookie/js-cookie
					Cookies && Cookies.set(cookieName, gameString, {
						expires: COOKIE_EXPIRY
					});
				},
				/**
				 * Load a game from a savegame string. Note that this will only
				 * work for games with precisely the right layout, otherwise the
				 * game code will be scrambled.
				 * @param  {String} gameString Game string representing the user's savegame.
				 */
				loadGame : function(gameString){
					var _this = this;
					var $inputs = puzzEl.find('input');

					if(!gameString){
						gameString = Cookies && Cookies.get(cookieName);
					}

					if(!gameString || gameString.length < $inputs.length){
						return;
					}

					$inputs.each(function(i){
						var chr = gameString.substr(i,1);
						$(this).val(chr == GAME_DELIM ? '' : chr);
					});

					var hintsSaved = gameString.substr($inputs.length);
					if(hintsSaved){
						hintsRemaining = hintsSaved;
						_this.updateHintsRemaining(hintsRemaining);
					}
				}


			}; // end puzInit object


			var nav = {

				nextPrevNav: function(e, override) {
					var len = $actives.length,
						struck = override ? override : e.which,
						el = $(e.target),
						p = el.closest('td'),
						ps = el.closest('tr'),
						selector;

					util.getActivePositionFromClassGroup(el);
					util.highlightEntry();
					util.highlightClue();

					$('.current').removeClass('current');
					selector = '.position-' + activePosition + ' input';
					// move input focus/select to 'next' input
					switch(struck) {
						case 39:
							p
								.next()
								.find('input')
								.addClass('current')
								.select();

							break;

						case 37:
							p
								.prev()
								.find('input')
								.addClass('current')
								.select();

							break;

						case 40:
							ps
								.next()
								.find(selector)
								.addClass('current')
								.select();

							break;

						case 38:
							ps
								.prev()
								.find(selector)
								.addClass('current')
								.select();

							break;

						default:
						break;
					}

				},

				updateByNav: function(e) {
					var target;
					$('.clues-active').removeClass('clues-active');
					$('.active').removeClass('active');
					$('.current').removeClass('current');
					currIndex = 0;

					target = e.target;
					activePosition = $(e.target).data('position');

					util.highlightEntry();
					util.highlightClue();

					$('.active').eq(0).focus();
					$('.active').eq(0).select();
					$('.active').eq(0).addClass('current');

					activeClueIndex = $(clueLiEls).index(e.target);

				},

				// Sets activePosition var and adds active class to current entry
				updateByEntry: function(e, next) {
					var classes, clue, e1Ori, e2Ori, e1Cell, e2Cell;

					if(next || e.keyCode === 9){
						// handle tabbing through problems, which keys off clues and requires different handling
						if (e && e.shiftKey) {
							// Shift+Tab goes backwards through problems
							activeClueIndex = activeClueIndex === 0 ? clueLiEls.length-1 : --activeClueIndex;

							$('.clues-active').removeClass('.clues-active');

							if(--activePosition < 0){
								activePosition = puzz.data.length-1;
							}
						}
						else {
							activeClueIndex = activeClueIndex === clueLiEls.length-1 ? 0 : ++activeClueIndex;

							$('.clues-active').removeClass('.clues-active');

							if(++activePosition >= puzz.data.length){
								activePosition = 0;
							}
						}
					} else {
						activeClueIndex = activeClueIndex === clueLiEls.length-1 ? 0 : ++activeClueIndex;

						util.getActivePositionFromClassGroup(e.target);

						activeClueIndex = $(clueLiEls).index(clue);

					}

					currOri = puzz.data[activePosition].orientation;
					clue = $('[data-position=' + activePosition + ']');

					util.highlightEntry();
					util.highlightClue();
				}

			}; // end nav object


			var util = {
				calculateCluePositions : function(clues){

					for(var i=0; i<puzz.data.length; i++){
						puzz.data[i].position = (puzz.data[i].startx + puzz.data[i].starty*100);
					}

					// Reorder the problems array ascending by POSITION
					puzz.data.sort(function(a,b) {
						return a.position - b.position;
					});

					var index = 0;
					var lastIndex = false;
					for(var i=0; i<puzz.data.length; i++){
						if(puzz.data[i].position != lastIndex){
							index++;
						}
						lastIndex = puzz.data[i].position;
						puzz.data[i].position = index;
					}

					return clues;
				},

				highlightEntry: function() {
					// this routine needs to be smarter because it doesn't need to fire every time, only
					// when activePosition changes
					$actives = $('.active');
					$actives.removeClass('active');
					$actives = $('.position-' + activePosition + ' input').addClass('active');
					$actives.eq(0).focus();
					$actives.eq(0).select();
				},

				highlightClue: function() {
					var clue;
					$('.clues-active').removeClass('clues-active');
					$('[data-position=' + activePosition + ']').addClass('clues-active');

					if (mode === 'interacting') {
						clue = $('[data-position=' + activePosition + ']');
						activeClueIndex = $(clueLiEls).index(clue);
					};
				},

				getActivePositionFromClassGroup: function(el){
					var cells = $(el).closest('td').data('cells');
					if(cells.length > 1){

						for(var i=0;i<cells.length;i++){
							if(cells[i].data.orientation == currOri){
								activePosition = cells[i].position
							}
						}

					} else {
						activePosition = cells[0].position;
					}

				},
				/*
					Rot13 hides answers from *accidental* disclosure. Cheaters can still cheat :)
				*/
				rot13: function(s) {
					return (s ? s : this).split('').map(function(_)
					{
						 if (!_.match(/[A-za-z]/)) return _;
						 c = Math.floor(_.charCodeAt(0) / 97);
						 k = (_.toLowerCase().charCodeAt(0) - 83) % 26 || 26;
						 return String.fromCharCode(k + ((c == 0) ? 64 : 96));
					}).join('');
				},

				getSkips: function(position) {
					if ($(clueLiEls[position]).hasClass('clue-done')){
						activeClueIndex = position === clueLiEls.length-1 ? 0 : ++activeClueIndex;
						util.getSkips(activeClueIndex);
					} else {
						return false;
					}
				}

			}; // end util object


			puzInit.init();


	}

})(jQuery);
