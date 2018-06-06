# Mines

Mines 0.5.2

Current version is not optimized. Expect script size to decrease as development progresses.


How to use:

	1: Reading the grid:
		- #'s are empty squares. Since they do not contain any number you can assume that no mines
		  are nearby and that all neighbouring squares also are safe
		- numbers 1 - 8: The numbers indicate how many mines are neighbouring the revealed square.
		- *'s are mines. If you have revealed a square containing this character, you've lost.
		- X's are flags. Flag squares that you suspect contain mines.
	
	2: Controls:
		Select a square by entering its X and Y coordinates. X is horizontal, Y is vertical.
		Toggle the flag tool by entering 0 in either the X or Y coordinate prompt.
		Note: This method of selecting a position is prone to being changed or deprecated later,
		      depending on which concepts work out the best.

		When prompted for coordinates, you may also enter the following commands:
			END	Ends the game.
			SAVE	Saves your progress.
			LOAD	Loads a previously saved game.
			SCAN	Changes the way bombs are counted, so that already flagged squares do not
				count towards the mine count
		
		If the game has crashed (A continous message reading "GAME CRASHED!"), type "minesweeper" to restart the game.
	
	3: Settings:
		You can edit settings either through the settings.cfg file found within the data folder,
		or through the menu in the program.

		UI mode (ui_mode) changes the way the grid is drawn. There are two options:
			- fast     (Faster draw speed, but is more difficult to read)
			- pretty   (Slower draw speed, but is easier to read)
		
		When running in "pretty" mode, the different characters on the grid will have different
		colors which makes them easier to separate from eachother.
		Even though the grid is in the process of refreshing, you may still enter coordinates or
		toggle the flag tool and it'll register the input.

		Colors:
			SETTING NAME		CONFIG NAME		VALID VALUES
			Main foreground 	(color_mainFG)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Main background 	(color_mainBG)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Bomb foreground 	(color_bombFG)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Bomb background 	(color_bombBG)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Flag foreground 	(color_flagFG)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Flag background 	(color_flagBG)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Ones			(color_1)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Twos			(color_2)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Threes			(color_3)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Fours			(color_4)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Fives			(color_5)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Sixes			(color_6)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Sevens			(color_7)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
			Eights			(color_8)		0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
		Note: Be aware that you cannot have the same color as background and foreground.
		E.g. a color_mainBG value of 0 and a color_1 value of 0 will produce an error.


Known bugs:
- Sometimes the "Flagging enabled" message will display twice.
- Game may skip safe squares when "flood revealing" empty squares.
- "Flood revealing" on large grids with few mines may cause a stack overflow and crash the game.


Changelog:
0.5.2 (0.5a2)
- Improved draw speed in "pretty" mode.
- Improved overall calculation speeds.
- Improved save compatibility checking.

0.5.1 (0.5a1)
- Fixed error and warning messages not displaying.

0.5.0 (0.5a0)
- Added support for embedding into the Windows Command line.
- Added additional number rows and columns to make finding the coordinates easier. Improvements to this
  will be made in the future.
- Under-the-hood optimizations.
- Improved save file detection.
- Improved help section.
- Fixed bug which caused small grid sizes to mess up the UI.
- Hopefully fixed bug which caused flood revealing to reveal too many squares.

0.4.6 (0.4a6)
- Added error messages for missing files.
- Game now displays an error and crashes if it detects that it hasn't been unzipped before launching.
- Small improvements to the grid creation process. Starting a new game should now take slightly less time.
- Fixed bug where "Mines left" would become a negative number after loading an autosave or a user save.

0.4.5 (0.4a5)
- Added option to delete save.
- Improved text message when saving.
- Entering blank in coordinate prompts will now refresh the board.
- Changed colors of save related options in main menu.
- Fixed missing text from menu.
- Fixed bug where the SAVE command wouldn't work if entered in the Y-axis coordinate prompt.
- Fixed bug that could cause the program to change the window resolution while loading a game.

0.4.1 (0.4a1)
- Added scan cheat. Enter "scan" when prompted for x or y coordinates to redo the bomb counting.
  The new count will take into account that you've flagged mines and will consider those as 
  non-bomb squares. Meaning you can see how many bombs you have left around one square.
- Added ability to save and load games.
- Added autosaving. Automatically resumes game on startup if a game has been left unfinished.
- Fixed bug which caused the menu to not register input.

0.3.2 (0.3a2)
- Added ability to change color settings. Options can be found under "Colors" in the settings menu.
- Window resolution now scales depending on grid size.
- More colors added to different characters in "pretty" UI mode.
- Greatly improved draw speed while using the "pretty" UI mode.
- Fixed bug which caused "Missing operand" to display on screen while flood revealing.
- Fixed bug which caused the game to count remaining mines and flags incorrectly.
- Fixed bug which caused flagging to work even though the player had no flags left.
- Fixed bug which caused the game to reveal a position if it was flagged then unflagged.
- Fixed bug which enabled the player to check if a position contains a bomb or not.
- Fixed bug which caused the game to not end if a mine that was previously flagged was revealed.
