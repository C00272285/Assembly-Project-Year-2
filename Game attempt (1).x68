*-----------------------------------------------------------
* Title      : Endless Runner Game
* Written by : Luka Brennan
* Date       : XX/XX/XXXX
* Description: ENDLESS RUNNER KIT
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    
    
*-----------------------------------------------------------
*SECTION :      MAIN MENU SCREEN
*DESCRIPTION:   A MAIN MENU FOR THE GAME
*-----------------------------------------------------------




*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         0           ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEY_CODE EQU         19          ; Check for pressed keys
TC_DBL_BUFF EQU         92          ; Double Buffer Screen Trap Code
TC_CURSOR   EQU         11          ; Trap code cursor position

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         8           ; Players initial Width
PLYR_H_INIT EQU         8           ; Players initial Height



RUN_INDEX   EQU         0           ; Player Run Sound Index  
JMP_INDEX   EQU         1           ; Player Jump Sound Index  
DOWN_INDEX  EQU         3           
OPPS_INDEX  EQU         2           ; Player Opps Sound Index

ENMY_W_INIT EQU         8           ; Enemy initial Width
ENMY_H_INIT EQU         8         ; Enemy initial Height

*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         1           ; Points added

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : UP,DOWN and Escape or two functioning keys
* UP to JUMP and Escape to Exit Game
* C is used for a crouch button allowing the player to move up and down
*-----------------------------------------------------------
UP          EQU         $20         ; UP ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode
RIGHT       EQU         $68         ;ASCII KEYCODE FOR RIGHT ARROW
LEFT        EQU         $65         ;ASCII KEYCODE FOR LEFT ARROW
ENTER       EQU         $13         ;ASCII KEYCODE FOR ENTER


*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory

    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #10,         D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #2,         D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position

    ; Initial Position for Enemy

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #2,         D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position
    
    


    ; Initialise Player Score
    MOVE.L  #0,         D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE

    ; Initialise Player Velocity
    MOVE.L  #1,         D1          ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    MOVE.B  #1,         D1          ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY
    

    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUFF,D0         ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)

*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #19,        D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #0,         D2          ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
    
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.B  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.B   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.B   #32,       CURRENT_KEY ; Is Current Key UP
    BEQ     JUMP                    ; Jump
    CMP.B   #68,        CURRENT_KEY
    BEQ     MOV_RIGHT  
    CMP.B   #65,        CURRENT_KEY
    BEQ     MOVE_LEFT
    BRA     IDLE                    ; Or Idle
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    ; Show Keys Pressed
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    ; Show Code
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$3001,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  D2,         D1          ; Move Key Pressed to D1
    MOVE.B  #3,         D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Update is Running
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$4001,     D1          ; Col 40, Row 2
    TRAP    #15                     ; Trap (Perform action)
    LEA     UPDATE_MSG, A1          ; Update
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Move the Enemy
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D0          ; Move the Enemy X Position to D0
    CMP.L   #0,         D0
    BLE     RESET_ENEMY_POSITION    ; Reset Enemyif off Screen
    BRA     MOVE_ENEMY              ; Move the Enemy
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #1,         ENEMY_X     ; Move enemy by X Value
    RTS
    
*-----------------------------------------------------------
*PLAYER MAX JUMP HEIGHT
*-----------------------------------------------------------

    

*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW:
    ; Show if Draw is Running
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$4001,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     DRAW_MSG,   A1          ; Draw
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; clear the screen
    MOVE.B	#TC_CURSOR, D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_SCORE              ; Draw Score and HUD
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Score
* Description   : Draw game score
*-----------------------------------------------------------
DRAW_SCORE:
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 2, Row 1
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #3,         D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
* Perform a Jump
JUMP:
    BSR     PLAY_JUMP               ; Play jump sound
    ADD.L   #-1,   PLAYER_Y         ; Subtract amount to jump - UP + DOWN
    RTS                             ; Return to subroutine
   

MOV_RIGHT: 
    ADD.L   #1, PLAYER_X 
    RTS
    
MOVE_LEFT:
    ADD.L   #-1,PLAYER_X
    RTS

                          

*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$4001,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     IDLE_MSG,   A1          ; Move Idle Message to A1
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    BSR     PLAY_RUN
    RTS

*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #GREEN,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
;PLAYER:
;    MOVE.B  #40,D0
;    TRAP #15
;    BSR PLAYER_ICON
;    RTS
    
    

*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,    D1          ; X
    MOVE.L  ENEMY_Y,    D2          ; Y
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_Y,    D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D3          ; Set Enemy width X + Width
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:     ; Check player is not  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
    
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Y to D2
    ADD.L   ENMY_H_INIT,D2          ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:     ; Less than or Equal ?
    ADD.L   PLYR_H_INIT,D1          ; Add Player Height to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
COLLISION_CHECK_DONE:               ; No Collision Update points
    ADD.L   #POINTS,    D1          ; Move points upgrade to D1
    ADD.L   PLAYER_SCORE,D1         ; Add to current player score
    MOVE.L  D1, PLAYER_SCORE        ; Update player score in memory
    RTS                             ; Return to subroutine
    
PLAYER_JUMP_MAX_HEIGHT
    MOVE.L  #40, D1
    MOVE.L  D1,PLAYER_Y
    

COLLISION:
    BSR     PLAY_OPPS               ; Play Opps Wav
    MOVE.L  #0, PLAYER_SCORE        ; Reset Player Scorr
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSOR, D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #9,         D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------
KEYCODE_MSG     DC.B    'KeyCode : ', 0
JUMP_MSG        DC.B    'Jump....', 0
IDLE_MSG        DC.B    'Idle....', 0

UPDATE_MSG      DC.B    'Update....', 0
DRAW_MSG        DC.B    'Draw....', 0

EXIT_MSG        DC.B    'Exiting....', 0

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
GREEN           EQU     $00FF00
RED             EQU     $000000FF

*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    1   ; Reserve Space for Screen Width
SCREEN_H        DS.W    1   ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.B    1   ; Reserve Space for Current Key Pressed
LAST_KEY        DS.B    1   ; Reserve Space for Last Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    1   ; Reserve Space for Player X Position
PLAYER_Y        DS.L    1   ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    1   ; Reserve Space for Player Score
PLYR_VELOCITY   DS.L    1   ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    1   ; Reserve Space for Player Gravity

ENEMY_X         DS.L    1   ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    1   ; Reserve Space for Enemy Y Position

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
KEEP_WAV        DC.B    'keep_it_up.wav',0  ; Encouragment Keep it Up 
WELL_WAV        DC.B    'well_done.wav',0   ; Encouragement Well Done
AVOID_WAV       DC.B    'avoid.wav',0       ; Avoid Warning
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps

MAINMENU        DC.B    'PRESS ENTER KEY TO PLAY OR PRESS Esc KEY TO EXIT',0

;PLAYER_ICON:
;    INCBIN  "PLAYER.bmp"
    
;PLAYER_JUMP:
;    INCBIN "PLAYER_JUMP.bmp"



    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
