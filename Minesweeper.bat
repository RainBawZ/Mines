@echo off
setlocal enabledelayedexpansion
set version=0.4.5
cd "%~dp0"
color 0F
if "%~1"=="" (
	prompt $_GAME CRASHED^^!
	start /w /b "" "%~f0" _
	color 0C
	echo.
	echo Launching Mines v!version!...
	exit
)
title Mines v!version!
for /f "tokens=1,2 delims=#" %%A in ('"prompt #$H#$E# & echo on & for %%B in (1) do rem"') do (
	set "DEL=%%A"
)
<nul > X set /p ".=."
if not exist saves (
	mkdir saves
)
:reload
for /f "tokens=1,* delims==" %%A in (data\settings.cfg) do (
	set %%A=%%B
)
for /f "tokens=*" %%A in (data\data.dat) do (
	if not defined %%A (
		call :error %%A
		exit /b
	)
)
for /f "tokens=1,* delims==" %%A in (data\scoreboard.dat) do (
	set %%A=%%B
)
set "MSG= "
set "MSG2= "
set FLAG=0
set USETEMP=
set GRID=0
set GRID_BOMBS=0
set GRID_X=0
set GRID_Y=0
set uncovered=0
set functions=MakeGrid,CountBombs,DrawGrid,CheckPos,Flood,ChangeResolution
for %%A in (!functions!) do (
	call :ClearVars %%A
)
for /f "tokens=1 delims==" %%A in ('set gpos_') do (
	set %%A=
)
call :CheckColors
color !color_mainBG!!color_mainFG!
set debug=0


:menu
call :Clearvars all
if !debug!==0 mode con cols=56 lines=30
if exist "saves\autosave.dat" (
	call :LoadGame autosave.dat
	call :ChangeResolution !GRID_X! !GRID_Y!
	if !debug!==0 cls
	goto :gameloop
)
if !debug!==0 cls
echo.
call :ctxt 0C "     0.4a5" n
echo  ______________________________________________________
echo       ___     ___                             
echo      ^|   \   /   ^|  _   __    _   ______   ______
echo      ^| ^|\ \_/ /^| ^| ^|_^| ^|  \  ^| ^| ^|  ____^| ^|  ____^|
echo      ^| ^| \___/ ^| ^|  _  ^|   \ ^| ^| ^| ^|___   ^| ^|____
echo      ^| ^|       ^| ^| ^| ^| ^| ^|\ \^| ^| ^|  ___^|  ^|____  ^| 
echo      ^| ^|       ^| ^| ^| ^| ^| ^| \   ^| ^| ^|____   ____^| ^|
echo      ^|_^|       ^|_^| ^|_^| ^|_^|  \__^| ^|______^| ^|______^|
call :ctxt 0C "                         (A bad Minesweeper clone)" n
echo  ______________________________________________________
call :ctxt 0C "                                         By FoddEx" n
echo.
call :ctxt 0A "                  M A I N   M E N U" n
echo.
call :ctxt 0B "                   Q:         Help" n
call :ctxt 0B "                   W:     Settings" n
if exist "saves\usersave.dat" (
	echo.
	call :ctxt 0D "                   E:    Load save" n
	call :ctxt 0D "                   R:  Delete save" n
)
echo.
call :ctxt 0A "                   1:         Easy" n
call :ctxt 0A "                   2: Intermediate" n
call :ctxt 0A "                   3:       Expert" n
call :ctxt 0A "                   4:       Custom" n
echo.
call :ctxt 0C "                   9:         Exit" n
echo.

choice /n /c 12349QWER > nul
if !errorlevel!==1 (
	goto :easy
)
if !errorlevel!==2 (
	goto :intermediate
)
if !errorlevel!==3 (
	goto :expert
)
if !errorlevel!==4 (
	goto :custom
)
if !errorlevel!==5 (
	goto :end
)
if !errorlevel!==6 (
	goto :help
)
if !errorlevel!==7 (
	goto :settings
)
if !errorlevel!==8 (
	if exist "saves\usersave.dat" (
		call :LoadGame usersave.dat
		call :ChangeResolution !GRID_X! !GRID_Y!
		if !debug!==0 cls
		goto :gameloop
	)
)
if !errorlevel!==9 (
	if exist "saves\usersave.dat" (
		del /q "saves\usersave.dat" > nul
	)
)
goto :menu

:easy
set score=0
set markedmines=0
set inmarked=0
set cormarked=0
call :MakeGrid !easy_bombs! !easy_x! !easy_y!
call :ChangeResolution !GRID_X! !GRID_Y!
goto :gameloop

:intermediate
set score=0
set markedmines=0
set inmarked=0
set cormarked=0
call :MakeGrid !inter_bombs! !inter_x! !inter_y!
call :ChangeResolution !GRID_X! !GRID_Y!
goto :gameloop

:expert
set score=0
set markedmines=0
set inmarked=0
set cormarked=0
call :MakeGrid !exp_bombs! !exp_x! !exp_y!
call :ChangeResolution !GRID_X! !GRID_Y!
goto :gameloop

:custom
if !debug!==0 cls
echo Custom mode
echo.
set /p custom_x="Enter grid width:  "
set /p custom_y="Enter grid height: "
set /p custom_bombs="Enter bomb amount: "
set score=0
set markedmines=0
set inmarked=0
set cormarked=0
call :MakeGrid !custom_bombs! !custom_x! !custom_y!
call :ChangeResolution !GRID_X! !GRID_Y!
goto :gameloop

:gameloop
call :SaveGame autosave
if !FLAG!==1 (
	if "!MSG!"==" " (
		set MSG=Flagging enabled
	) else (
		set MSG2=Flagging enabled
	)
)
call :DrawGrid
call :ResetContentValues
if !uncovered!==!GRID! (
	goto :gamewon
)
echo Enter 0 to toggle flagging.
echo.
set "X="
set "Y="
set /p X="X: "
if /i "!X!"=="0" (
	if !FLAG!==1 (
		set FLAG=0
	) else (
		set FLAG=1
	)
	goto :gameloop
)
if "!X!"=="" (
	goto :gameloop
)
if /i "!X!"=="scan" (
	call :ScanBombs
	goto :gameloop
)
if /i "!X!"=="save" (
	call :SaveGame usersave m
	goto :gameloop
)
if /i "!X!"=="load" (
	call :LoadGame usersave.dat
	call :ChangeResolution !GRID_X! !GRID_Y!
	goto :gameloop
)
if /i "!X!"=="end" (
	goto :gameover
)
set /p Y="Y: "
if /i "!Y!"=="0" (
	if !FLAG!==1 (
		set FLAG=0
	) else (
		set FLAG=1
	)
	goto :gameloop
)
if "!Y!"=="" (
	goto :gameloop
)
if /i "!Y!"=="scan" (
	call :ScanBombs
	goto :gameloop
)
if /i "!Y!"=="save" (
	call :SaveGame usersave m
	goto :gameloop
)
if /i "!Y!"=="load" (
	call :LoadGame usersave.dat
	call :ChangeResolution !GRID_X! !GRID_Y!
	goto :gameloop
)
if /i "!Y!"=="end" (
	goto :gameover
)
call :CheckPos !X! !Y!
goto :gameloop

:settings
set settings_unsaved=0
:settings_1
if !debug!==0 cls
echo Game settings:
echo.
echo ^(See Readme.txt for valid setting values^)
echo.
echo #    Setting    Value
echo.
echo 1 -^> UI      -^> !ui_mode!
echo 2 -^> Colour
echo.
echo 0 -^> Return
echo.
choice /n /c 012 /m ">> "
if !errorlevel!==1 (
	if !settings_unsaved!==1 (
		echo.
		echo You have unsaved settings.
		echo 1 -^> Save changes
		echo 2 -^> Discard changes
		choice /n /c 12 /m ">> "
		if !errorlevel!==1 (
			call :SaveSettings
		)
		goto :reload
	) else (
		goto :menu
	)
)
set settings_unsaved=1
if !errorlevel!==2 (
	echo.
	set /p ui_mode="New value: "
	goto :settings_1
)
if !errorlevel!==3 (
	goto :settings.color
)
goto :settings_1
:settings.color
if !debug!==0 cls
set settings_choice=_
echo Color settings:
echo Enter 0 to return.
echo.
call :ctxt !color_mainBG!!color_mainFG! "#  SETTING        Current value" n
call :ctxt !color_mainBG!!color_mainFG! "1  color_mainFG   !color_mainFG!" n
call :ctxt !color_mainBG!!color_mainFG! "2  color_mainBG   !color_mainBG!" n
call :ctxt !color_bombBG!!color_bombFG! "3  color_bombBG   !color_bombBG!" n
call :ctxt !color_bombBG!!color_bombFG! "4  color_bombFG   !color_bombFG!" n
call :ctxt !color_flagBG!!color_flagFG! "5  color_flagBG   !color_flagBG!" n
call :ctxt !color_flagBG!!color_flagFG! "6  color_flagFG   !color_flagFG!" n
call :ctxt !color_mainBG!!color_empty! "7  color_empty    !color_empty!" n
call :ctxt !color_mainBG!!color_1! "8  color_1        !color_1!" n
call :ctxt !color_mainBG!!color_2! "9  color_2        !color_2!" n
call :ctxt !color_mainBG!!color_3! "Q  color_3        !color_3!" n
call :ctxt !color_mainBG!!color_4! "W  color_4        !color_4!" n
call :ctxt !color_mainBG!!color_5! "E  color_5        !color_5!" n
call :ctxt !color_mainBG!!color_6! "R  color_6        !color_6!" n
call :ctxt !color_mainBG!!color_7! "T  color_7        !color_7!" n
call :ctxt !color_mainBG!!color_8! "Y  color_8        !color_8!" n
echo.
echo Valid values are numbers 0 thru 9, and chars A thru F.
set /p settings_choice=">> "
if "!settings_choice!"=="0" (
	goto :settings
)
if "!settings_choice!"=="_" (
	goto :settings.color
)
if "!settings_choice!"=="1" (
	echo.
	set /p color_mainFG="Enter new value for color_mainFG: "
	call :ApplyColor
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="2" (
	echo.
	set /p color_mainBG="Enter new value for color_mainBG: "
	call :ApplyColor
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="3" (
	echo.
	set /p color_bombBG="Enter new value for color_bombBG: "
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="4" (
	echo.
	set /p color_bombFG="Enter new value for color_bombFG: "
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="5" (
	echo.
	set /p color_flagBG="Enter new value for color_flagBG: "
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="6" (
	echo.
	set /p color_flagFG="Enter new value for color_flagFG: "
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="7" (
	echo.
	set /p color_empty="Enter new value for color_empty: "
	set settings_unsaved=1
	goto :settings.color
)
if "!settings_choice!"=="8" (
	echo.
	set /p color_1="Enter new value for color_1: "
	set settings_unsaved=1
	goto settings.color
)
if "!settings_choice!"=="9 (
	echo.
	set /p color_2="Enter new value for color_2: "
	set settings_unsaved=1
	goto :settings.color
)
if /i "!settings_choice!"=="Q" (
	echo.
	set /p color_3="Enter new value for color_3: "
	set settings_unsaved=1
	goto :settings.color
)
if /i "!settings_choice!"=="W" (
	echo.
	set /p color_4="Enter new value for color_4: "
	set settings_unsaved=1
	goto :settings.color
)
if /i "!settings_choice!"=="E" (
	echo.
	set /p color_5="Enter new value for color_5: "
	set settings_unsaved=1
	goto :settings.color
)
if /i "!settings_choice!"=="R" (
	echo.
	set /p color_6="Enter new value for color_6: "
	set settings_unsaved=1
	goto :settings.color
)
if /i "!settings_choice!"=="T" (
	echo.
	set /p color_7="Enter new value for color_7: "
	set settings_unsaved=1
	goto :settings.color
)
if /i "!settings_choice!"=="Y" (
	echo.
	set /p color_8="Enter new value for color_8: "
	set settings_unsaved=1
	goto :settings.color
)
goto :settings.color


:end
exit

:MakeGrid <Bombs> <X size> <Y size>
Echo Loading...
set MakeGrid_Bombs=%~1
set MakeGrid_X=%~2
set MakeGrid_Y=%~3
set GRID_X=!MakeGrid_X!
set GRID_Y=!MakeGrid_Y!
set GRID_BOMBS=!MakeGrid_Bombs!
set /a GRID=!MakeGrid_Y!*!MakeGrid_X!
set MinesLeft=!GRID_BOMBS!
set "DrawGrid_line="
set "DrawGrid_line2="
for /l %%A in (1,1,!GRID_X!) do (
	set DrawGrid_line=!DrawGrid_line!____
)
for /l %%A in (1,1,!GRID_X!) do (
	set "DrawGrid_line2=!DrawGrid_line2!^|___"
)
Echo     Creating grid...
for /l %%A in (1,1,!MakeGrid_Y!) do (
	for /l %%B in (1,1,!MakeGrid_X!) do (
		set gpos_%%A_%%B_bomb=0
		set "gpos_%%A_%%B_cts= "
		set "gpos_%%A_%%B_true= "
		set gpos_%%A_%%B_hidden=1
		set gpos_%%A_%%B_checked=0
		set gpos_%%A_%%B_flagged=0
	)
)
Echo     Making bombs...
:MakeGrid.Bombs
if !MakeGrid_Bombs!==0 (
	goto :MakeGrid.cnt
)
set /a MakeGrid_xBombPos=!random! %% !MakeGrid_X! + 1
set /a MakeGrid_yBombPos=!random! %% !MakeGrid_Y! + 1
if !gpos_%MakeGrid_yBombPos%_%MakeGrid_xBombPos%_bomb!==0 (
	set gpos_!MakeGrid_yBombPos!_!MakeGrid_xBombPos!_bomb=1
	set gpos_!MakeGrid_yBombPos!_!MakeGrid_xBombPos!_cts=*
	set gpos_!MakeGrid_yBombpos!_!MakeGrid_xBombPos!_true=*
	set gpos_!MakeGrid_yBombPos!_!MakeGrid_xBombPos!_clr=!color_bombBG!!color_bombFG!
	set gpos_!MakeGrid_yBombPos!_!MakeGrid_xBombpos!_dclr=!color_bombBG!!color_bombFG!
	set /a MakeGrid_Bombs-=1
)
goto :MakeGrid.Bombs
:MakeGrid.cnt
echo     Calculating proximities...
for /l %%A in (1,1,!MakeGrid_Y!) do (
	for /l %%B in (1,1,!MakeGrid_X!) do (
		if !gpos_%%A_%%B_bomb!==0 (
			if not !gpos_%%A_%%B_bomb!==1 (
				call :CountBombs %%B %%A
			)
		)
	)
)
goto :eof

:CountBombs <X> <Y>
set CountBombs_counter=0
set CountBombs_current_x=%~1
set CountBombs_current_y=%~2
set /a CountBombs_above=!CountBombs_current_y! - 1
set /a CountBombs_below=!CountBombs_current_y! + 1
set /a CountBombs_left=!CountBombs_current_x! - 1
set /a CountBombs_right=!CountBombs_current_x! + 1
for /l %%A in (!CountBombs_above!,1,!CountBombs_below!) do (
	for /l %%B in (!CountBombs_left!,1,!CountBombs_right!) do (
		if !gpos_%%A_%%B_bomb!==1 (
			set /a CountBombs_counter+=1
		)
	)
)
if !CountBombs_counter! GTR 0 (
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_cts=!CountBombs_counter!
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_true=!CountBombs_counter!
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_clr=!color_%CountBombs_counter%!
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_dclr=!color_%CountBombs_counter%!
) else (
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_cts=0
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_true=0
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_clr=!color_empty!
	set gpos_!CountBombs_current_y!_!CountBombs_current_x!_dclr=!color_empty!
)
goto :eof

:ScanBombs
for /l %%A in (1,1,!GRID_Y!) do (
	set ScanBombs_current_y=%%A
	for /l %%B in (1,1,!GRID_X!) do (
		if !gpos_%%A_%%B_hidden!==0 (
			set ScanBombs_counter=0
			set ScanBombs_current_x=%%B
			set /a ScanBombs_above=!ScanBombs_current_y! - 1
			set /a ScanBombs_below=!ScanBombs_current_y! + 1
			set /a ScanBombs_left=!ScanBombs_current_x! - 1
			set /a ScanBombs_right=!ScanBombs_current_x! + 1
			for /l %%C in (!ScanBombs_above!,1,!ScanBombs_below!) do (
				for /l %%D in (!ScanBombs_left!,1,!ScanBombs_right!) do (
					if !gpos_%%C_%%D_bomb!==1 (
						if !gpos_%%C_%%D_flagged!==0 (
							set /a ScanBombs_counter+=1
						)
					)
				)
			)
			if !ScanBombs_counter! GTR 0 (
				set gpos_%%A_%%B_cts=!ScanBombs_counter!
				for /f "tokens=*" %%E in ("!ScanBombs_counter!") do (
					set gpos_!ScanBombs_current_y!_!ScanBombs_current_x!_dclr=!color_%%E!
				)
			) else (
				set gpos_%%A_%%B_cts=0
				set gpos_%%A_%%B_dclr=!color_empty!
			)
		)
	)
)
goto :eof

:ResetContentValues 
for /l %%A in (1,1,!GRID_Y!) do (
	for /l %%B in (1,1,!GRID_X!) do (
		set gpos_%%A_%%B_cts=!gpos_%%A_%%B_true!
		set gpos_%%A_%%B_dclr=!gpos_%%A_%%B_clr!
	)
)
goto :eof

:DrawGrid
if !ui_mode!==pretty (
	goto :DrawGrid.color
)
set uncovered=0
set "DrawGrid_xnums="
for /l %%A in (1,1,!GRID_X!) do (
	if %%A GEQ 10 (
		set "DrawGrid_xnums=!DrawGrid_xnums! %%A "
	) else (
		set "DrawGrid_xnums=!DrawGrid_xnums!  %%A "
	)
)
if !debug!==0 cls
echo Score: !score!	Mines left: !MinesLeft!
echo.!MSG!
echo.!MSG2!
echo !DrawGrid_xnums!
echo _!DrawGrid_line!
for /l %%A in (1,1,!GRID_Y!) do (
	set "DrawGrid_current=!DrawGrid_current!^|"
	for /l %%B in (1,1,!GRID_X!) do (
		if !gpos_%%A_%%B_flagged!==1 (
			if !gpos_%%A_%%B_bomb!==1 (
				set /a uncovered+=1
			)
			set "DrawGrid_current=!DrawGrid_current! X ^|"
		) else (
			if !gpos_%%A_%%B_hidden!==0 (
				set /a uncovered+=1
				if !gpos_%%A_%%B_cts!==0 (
					set "DrawGrid_current=!DrawGrid_current! # ^|"
				) else (
					set "DrawGrid_current=!DrawGrid_current! !gpos_%%A_%%B_cts%USETEMP%! ^|"
				)
			) else (
				set "DrawGrid_current=!DrawGrid_current!   ^|"
			)
		)
	)
	echo !DrawGrid_current! %%A
	echo !DrawGrid_line2!^|
	set "DrawGrid_current="
)
set "MSG= "
set "MSG2= "
goto :eof

:DrawGrid.color
set "DrawGrid_xnums="
set uncovered=0
for /l %%A in (1,1,!GRID_X!) do (
	if %%A GEQ 10 (
		set "DrawGrid_xnums=!DrawGrid_xnums! %%A "
	) else (
		set "DrawGrid_xnums=!DrawGrid_xnums!  %%A "
	)
)
if !debug!==0 cls
echo Score: !score!	Mines left: !MinesLeft!
call :ctxt 0C "!MSG!" n
call :ctxt 0C "!MSG2!" n
echo !DrawGrid_xnums!
echo _!DrawGrid_line!
for /l %%A in (1,1,!GRID_Y!) do (
	<nul set /p ="|"
	for /l %%B in (1,1,!GRID_X!) do (
		if !gpos_%%A_%%B_flagged!==1 (
			if !gpos_%%A_%%B_bomb!==1 (
				set /a uncovered+=1
			)
			call :ctxt !color_flagBG!!color_flagFG! " X "
		) else (
			if !gpos_%%A_%%B_hidden!==0 (
				set /a uncovered+=1
				if !gpos_%%A_%%B_bomb!==1 (
					call :ctxt !gpos_%%A_%%B_dclr! " * "
				) else (
					if !gpos_%%A_%%B_cts!==0 (
						call :ctxt !gpos_%%A_%%B_dclr! " # "
					) else (
						call :ctxt !gpos_%%A_%%B_dclr! " !gpos_%%A_%%B_cts! "						
					)
				)
			) else (
				<nul set /p dummy="^%DEL%   "
			)
		)
		<nul set /p ="|"
	)
	echo  %%A
	echo !DrawGrid_line2!^|
)
set "MSG= "
set "MSG2= "
goto :eof

:CheckPos <X> <Y>
set CheckPos_x=%~1
set CheckPos_y=%~2
if "!FLAG!"=="1" (
	if !gpos_%CheckPos_y%_%CheckPos_x%_hidden!==1 (
		if !gpos_%CheckPos_y%_%CheckPos_x%_flagged!==0 (
			if !markedmines! LSS !GRID_BOMBS! (
				set gpos_!CheckPos_y!_!CheckPos_x!_flagged=1
				set /a markedmines+=1
				set /a MinesLeft-=1
				if !gpos_%CheckPos_y%_%CheckPos_x%_bomb!==1 (
					set /a cormarked+=1
				) else (
					set /a inmarked+=1
				)
			) else (
				if "!MSG!"==" " (
					set MSG=No more flags left.
				) else (
					set MSG2=No more flags left.
				)
			)
		) else (
			set gpos_!CheckPos_y!_!Checkpos_x!_flagged=0
			set /a markedmines-=1
			set /a MinesLeft+=1
			if !gpos_%CheckPos_y%_%CheckPos_x%_bomb!==1 (
				set /a cormarked-=1
			) else (
				set /a inmarked-=1
			)
		)
	)
) else (
	if !gpos_%CheckPos_y%_%CheckPos_x%_flagged!==0 (
		if !gpos_%CheckPos_y%_%CheckPos_x%_bomb!==1 (
			call :RevealBombs
			goto :gameover
		)
		call :Flood !CheckPos_x! !CheckPos_y!		
	)
)
goto :eof

:RevealBombs
for /l %%A in (1,1,!GRID_Y!) do (
	for /l %%B in (1,1,!GRID_X!) do (
		if !gpos_%%A_%%B_bomb!==1 (
			set gpos_%%A_%%B_flagged=0
			set gpos_%%A_%%B_hidden=0
		)
	)
)
goto :eof

:Flood <X> <Y>
set Flood_x=%~1
set Flood_y=%~2
if !gpos_%Flood_y%_%Flood_x%_checked!==1 (
	goto :eof
)
set gpos_!Flood_y!_!Flood_x!_checked=1
set gpos_!Flood_y!_!Flood_x!_hidden=0
if not !gpos_%Flood_y%_%Flood_x%_true!==0 (
	if !gpos_%Flood_y%_%Flood_x%_bomb!==0 (
		set /a score+=!gpos_%Flood_y%_%Flood_x%_true!
	)
	goto :eof
)
set /a Flood_above=!Flood_y! - 1
set /a Flood_below=!Flood_y! + 1
set /a Flood_left=!Flood_x! - 1
set /a Flood_right=!Flood_x! + 1
for /l %%A in (!Flood_above!,1,!Flood_below!) do (
	for /l %%B in (!Flood_left!,1,!Flood_right!) do (
		if !gpos_%%A_%%B_flagged!==0 (
			set !gpos_%%A_%%B_checked!==1
			if !gpos_%%A_%%B_bomb!==0 (
				set gpos_%%A_%%B_hidden=0
				set /a score+=!gpos_%%A_%%B_true!
				if !gpos_%%A_%%B_true!==0 (
					call :Flood %%B %%A
				)
			)
		)
	)
)
goto :eof

:ClearVars <Varset>
set ClearVars_varset=%~1
if !ClearVars_varset!==all (
	for %%B in (!functions!) do (
		for /f "tokens=1 delims==" %%A in ('set %%B_ ^>nul 2^>^&1') do (
			set %%A=
		)
	)
) else (
	for /f "tokens=1 delims==" %%A in ('set !ClearVars_varset!_ ^>nul 2^>^&1') do (
		set %%A=
	)
)
goto :eof

:SaveSettings
(
	echo.# MINES SETTINGS CONFIG
	echo.
	echo.
	echo.# GAME SETTINGS
	echo.
	echo.#^(Vaild settings here are "fast" and "pretty"^)
	echo.#^("pretty" has a slow draw rate but is easy to read, "fast" has a fast draw rate but is harder to read.^)
	echo.ui_mode=!ui_mode!
	echo.color_mainFG=!color_mainFG!
	echo.color_mainBG=!color_mainBG!
	echo.color_bombBG=!color_bombBG!
	echo.color_bombFG=!color_bombFG!
	echo.color_flagBG=!color_flagBG!
	echo.color_flagFG=!color_flagFG!
	echo.color_empty=!color_empty!
	echo.color_1=!color_1!
	echo.color_2=!color_2!
	echo.color_3=!color_3!
	echo.color_4=!color_4!
	echo.color_5=!color_5!
	echo.color_6=!color_6!
	echo.color_7=!color_7!
	echo.color_8=!color_8!
	echo.
	echo.# EASY MODE
	echo.easy_bombs=!easy_bombs!
	echo.easy_x=!easy_x!
	echo.easy_y=!easy_y!
	echo.
	echo.# INTERMEDIATE MODE
	echo.inter_bombs=!inter_bombs!
	echo.inter_x=!inter_x!
	echo.inter_y=!inter_y!
	echo.
	echo.# EXPERT MODE
	echo.exp_bombs=!exp_bombs!
	echo.exp_x=!exp_x!
	echo.exp_y=!exp_y!
)>data\settings.cfg
goto :eof

:SaveStats
(
	echo.totalscore=!totalscore!
	echo.totalmarked=!totalmarked!
	echo.totalcormark=!totalcormark!
	echo.totalinmark=!totalinmark!
	echo.totalwins=!totalwins!
	echo.totallosses=!totallosses!
)>data\scoreboard.dat
goto :eof

:SaveGame <Savefile>
if "%~2"=="m" (
	echo.
	<nul set /p ="Saving... "
)
(
	echo @MINES SAVE
	echo SAVE_VERSION=!version!
	for /f "tokens=*" %%A in ('set GRID') do (
		echo %%A
	)
	echo DrawGrid_line=!DrawGrid_line!
	echo DrawGrid_line2=!DrawGrid_line2!
	for /f "tokens=*" %%A in ('set gpos') do (
		echo %%A
	)
	echo score=!score!
	echo markedmines=!markedmines!
	echo cormarked=!cormarked!
	echo inmarked=!inmarked!
)>saves\%~1.dat
if "%~2"=="m" (
	echo Saved.
	timeout /t 1 /nobreak > nul
)
goto :eof

:LoadGame <File>
echo.
echo Loading...
for /f "tokens=1,* delims==" %%A in (saves\%~1) do (
	set %%A=%%B
)
if not !SAVE_VERSION!==!version! (
	echo WARNING: This save file may not be compatible
	echo          with the current version of Mines.
	pause > nul
)
goto :eof

:ChangeResolution <X> <Y>
set ChangeResolution_x=%~1
set ChangeResolution_y=%~2
set /a ChangeResolution_x*=6
set /a ChangeResolution_x+=10
set /a ChangeResolution_y*=2
set /a ChangeResolution_y+=11
if !debug!==0 mode con cols=!ChangeResolution_x! lines=!ChangeResolution_y!
goto :eof

:CheckColors
color !color_mainBG!!color_mainFG!
goto :eof
for /f "tokens=1,2 delims==" %%A in ('set color_') do (
	set "CheckColors_items=%%A+%%B,!CheckColors_items!"
)
REM for %%A in (!CheckColors_items!) do (
	REM for /f "tokens=1,2 delims=+" %%B in ("%%A") do (
		REM if %%
	REM )
REM )
goto :eof

:ApplyColor
if not !color_mainBG!==!color_mainFG! (
	color !color_mainBG!!color_mainFG!
)
goto :eof

:gameover
del /q "saves\autosave.dat" > nul
call :DrawGrid
if !cormarked! GEQ 1 (
	set /a score*=!cormarked!
)
Echo.
Echo Game over
echo.
echo Your score:         !score!
echo Marked mines:       !markedmines!/!GRID_BOMBS!
echo Correctly marked:   !cormarked!
echo Incorrectly marked: !inmarked!
set /a totalscore+=!score!
set /a totalmarked+=!markedmines!
set /a totalcormark+=!cormarked!
set /a totalinmark+=!inmarked!
call :SaveStats
set /a totallosses+=1
pause > nul
goto :reload

:gamewon
del /q "saves\autosave.dat" > nul
call :DrawGrid
if !cormarked! GEQ 1 (
	set /a score*=!cormarked!
)
set /a score*=2
echo.
echo Congratulations^^!
echo.
echo Your score:         !score!
echo Marked mines:       !markedmines!/!GRID_BOMBS!
echo Correctly marked:   !cormarked!
echo Incorrectly marked: !inmarked!
set /a totalscore+=!score!
set /a totalmarked+=!markedmines!
set /a totalcormark+=!cormarked!
set /a totalinmark+=!inmarked!
set /a totalwins+=1
call :SaveStats
pause > nul
goto :reload


:help
if !debug!==0 cls
echo Help:
echo.
echo To reveal a square, first enter 
echo the X coordinate ^(horizontal^)
echo then enter the Y coordinate ^(vertical^)
echo.
echo To flag a suspected mine, enter "0" to toggle flagging
echo otherwise press 0 or any other number.
echo.
echo #   -^> Blank square, all neighbouring squares are safe.
echo 1-8 -^> Number of mines neighbouring the revealed square.
echo *   -^> Mine. If you reveal a square containing a mine,
echo        you lose.
echo X   -^> Flagged square. Flag a square if you suspect
echo        that it holds a mine.
echo.
pause > nul
goto :menu

:error <Data>
echo.
echo A FATAL ERROR OCCURRED WHILE PARSING:
echo "data\Settings.cfg"
echo.
echo GLOBAL VARIABLE "%~1" WAS NOT DEFINED.
echo data\Settings.cfg is corrupted or cannot be read.
echo.
echo Please re-download to repair.
exit /b

:ctxt
set "param=^%~2" !
set "param=!param:"=\"!"
findstr /p /A:%1 "." "!param!\..\X" nul
<nul set /p ".=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%"
if /i "%~3"=="n" echo.
goto :eof