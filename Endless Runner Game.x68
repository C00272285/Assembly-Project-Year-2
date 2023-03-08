  ORG    $1000
START: 


*NAME:LUKA BRENNAN
*STUDENTID: C00272285
*DATE CREATED: 16/02/23
*DESCRIPTION:
*THE CODE BELOW CREATES A VERY BASICE ENDLESS RUNNER GAME, USEING THE STARTER KIT.
*THERE WERE A FEW PROBLEMS WITH MOVEMENT, I WANTED MY CHARACTER TO BE ABLE TO MOVE FROM THE SIDE TO SIDE, HOWEVER THIS DID NOT WORK. I HAVE DIFFERENT CODE THAT ALLOWS THIS TO WORK HOWEVER IT DOES JOT WORK HERE.
*I WAS TRYING TO ADD ANOTHER NEW ENEMY BUT RAN INTO PROBLEMS WITH THEM NOT SPAWNING IN, THUS I LEFT IT OUT.

    

*--------------------------------
*Trap codes
*--------------------------------
    
Key_Pressed     EQU         19          ; Check for pressed keys
Dubble_Buffer   EQU         92          ; Double Buffer Screen Trap Code
SCREEN          EQU         33
SCREEN_SIZE     EQU         0
TC_CURSR_P      EQU         11          ; Trap code cursor position
TC_EXIT         EQU         09          ; Exit Trapcode




*--------------------------------
*SETTING UP THE CHARACTERS
*--------------------------------

PLAYER_HEIGHT   EQU     8
PLAYER_WIDTH    EQU     8

ENEMY_HEIGHT    EQU     8
ENEMY_WIDTH     EQU     8

GROUND_HEIGHT   EQU     5900 ; this make the yellow ground long, used to be an issue where it would disappear and then come back. having it at this value makes it so that it does not disappear.
GROUND_WIDTH    EQU     8

ENEMY_HEIGHT_2  EQU     8
ENEMY_WIDTH_2   EQU     8

PLYR_DFLT_V     EQU     2           ; Default Player Velocity
PLYR_JUMP_V     EQU    -18          ; Player Jump Velocity
PLYR_DFLT_G     EQU     0           ; Player Default Gravity

ON_GROUND_TRUE  EQU     1   
ON_GROUND_FALSE EQU     0


*--------------------------------
*SETTING UP POINTS
*--------------------------------
POINTS          EQU     1


*-------------------------------
*SETTING UP THE PLAYERS HEALTH
*-------------------------------
LIFE          EQU     3     ; does not work 

*--------------------------------
*KEYBOARD KEYS FOR GAME IN HEX
*--------------------------------
SPACEBAR        EQU     $20
ESCAPE          EQU     $1B
LEFT            EQU     $65
RIGHT           EQU     $68

*--------------------------------
*GAME INITIALISE
*--------------------------------
INITIALISE
    
 *SETTING UP THE SCREEN SIZE
    MOVE.B  #SCREEN, D0               ; access screen information
    MOVE.L  #SCREEN_SIZE, D1           ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                       ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H      ; place screen height in memory location
    SWAP    D1                        ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W      ; place screen width in memory location

    *SETTING UP THE POSITION OF THE PLAYER
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position
    
    *SETTING UP THE PLAYERS SCORE
    CLR.L   D1
    MOVE.L  #0,         D1
    MOVE.L  D1,          PLAYER_SCORE

    
    *SETTING UP PLAYERS GRAVITY FOR JUMP
    CLR.L   D1
    MOVE.B  #PLYR_DFLT_V,   D1
    MOVE.L  D1,         PLYR_GRAVITY
    
    *SETTING UP PLAYERS VELOCITY
    CLR.L   D1
    MOVE.B  #PLYR_DFLT_G,   D1
    MOVE.L  D1,         PLYR_VELOCITY
    
    *SETTING UP IF THE PLAYER IS ON THE GROUND OR NOT
    MOVE.L  #ON_GROUND_TRUE,    PLYR_ON_GND
    
    *SETTING UP THE POSITION FOR THE ENNEMY
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.B  D1,         ENEMY_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #2,         D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position
    
    
    *SETTING UP THE POSITION FOR THE SECOND ENEMY
    CLR.L   D2                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D2          ; Place Screen width in D1
    MOVE.L  D2,         ENEMY_TWO_X     ; Enemy X Position

    CLR.L   D2                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D2          ; Place Screen width in D1
    DIVU    #3,         D2          ; divide by 2 for center on Y Axis
    MOVE.L  D2,         ENEMY_TWO_Y     ; Enemy Y Position
    
    
    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #Dubble_Buffer,D0         ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P, D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)

    
    
    


    
*--------------------------------
*MAIN GAME AND GAME LOOPS
*--------------------------------
GAMELOOP:

    MOVEQ   #8,D0    ; get time in seconds
    TRAP    #15 ; perform action
    MOVE.l   D1,-(sp)    ; push time on stack 

    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene

    MOVE.L (sp)+,D7 ; take time off the stack;
WAIT:
    MOVEQ   #8,D0 ; get time in seconds
    TRAP    #15 ; perform action

    SUB.l   D7,D1 ; take away previous time from the current time
    CMP.B   #2,D1 ; add a wait for the charcter and this can also help to slow down the enemy

    BMI.S   WAIT ; if Branch if Minus go to WAIT 
    BRA     GAMELOOP  ; Loop back to GameLoop
*--------------------------------
*GAME INPUTS
*--------------------------------
INPUT
    CLR.L D1
    MOVE.B  #KEY_PRESSED,   D0
    TRAP    #15
    
    MOVE.B  D1,     D2
    CMP.B   #00,    D2              ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
  
    CMP.B   #$FF,   D1              ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine



*--------------------------------
*PROCESS THE USER INPUTS
*--------------------------------
PROCESS_INPUT
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    CMP.B   #65,        CURRENT_KEY ; to check is the keycode 65 is being pressed
    BEQ     MOV_RIGHT               ; if the key is pressed then go to MOV_RIGHT
    CMP.B   #68,        CURRENT_KEY ;to check is the keycode 68 is being pressed
    BEQ     MOVE_LEFT               ;if the key is pressed then go to MOV_LEFT
    RTS                             ; Return to subroutine

*--------------------------------
*UPDATE THE MAIN GAME LOOP FOR PLAYER AND ENEMY
*--------------------------------
UPDATE

    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ADD.L   D2,         D1          ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 


    ; MOVE ENEMY ONE
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  ENEMY_X,    D1          ; Move the Enemy X Position to D1
    CMP.L   #1,        D1
    BLE     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY              ; Move the Enemy
    RTS                             ; Return to subroutine 
    
    ; MOVE ENEMY TWO
    CLR.L   D2                     ; Clear contents of D2 (XOR is faster)
    MOVE.L  ENEMY_TWO_X,    D2          ; Move the Enemy X Position to D0
    CMP.L   #01,        D2
    BLE     RESET_ENEMY_TWO_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY_TWO              ; Move the Enemy
    RTS                             ; Return to subroutine
    
    

*--------------------------------
*MOVE THE ENEMY
*--------------------------------
MOVE_ENEMY
    SUB.L   #4,     ENEMY_X
    RTS
    
MOVE_ENEMY_TWO
    SUB.L   #4,     ENEMY_TWO_X
    RTS
    
*--------------------------------
*RESET THE ENEMY POSITION  
*--------------------------------   
RESET_ENEMY_POSITION
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    MOVE.W  SCREEN_W,   D2
    RTS
    
RESET_ENEMY_TWO_POSITION
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_TWO_X     ; Enemy X Position
    MOVE.W  SCREEN_W,   D2
    RTS

*--------------------------------
*DRAWING UP THE SCREEN
*--------------------------------   
DRAW
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    BSR     GROUND_LINE
    BSR     DRAW_ENEMY_TWO
    RTS                             ; Return to subroutine
    
*--------------------------------   
*DRAW UP PLAYERS DATA, POSITION,SCORE,KEY PRESSED
*--------------------------------   
DRAW_PLYR_DATA 
    CLR.L   D1

    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0901,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3001,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)
    
        
*--------------------------------   
*CHECKING IF THE PLAYER IS ON THE GROUND
*--------------------------------   
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine
    
*--------------------------------   
*THE PLAYER IS ON GROUND
*--------------------------------   
SET_ON_GROUND
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Reset the Player Y Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Set Player Velocity
    MOVE.L  #ON_GROUND_TRUE,  PLYR_ON_GND ; Player is on Ground
    RTS
    
    
*--------------------------------   
*MAKING A LINE FOR THE GROUND
*--------------------------------   
GROUND_LINE
    
    ; Set Pixel Colors
    MOVE.L  #YELLOW,    D1          ; Set Background color
    MOVE.B  #80,        D0        ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; SETTING THE WIDTH AND HEIGHT OF THE LINE
    MOVE.L  GROUND_X,        D1     ;X
    ADD.L   #GROUND_WIDTH,   D2     ; Width
    ADD.L   #GROUND_HEIGHT,  D3     ; Height
    
    MOVE.W  SCREEN_H,   D0          ; Place Screen width in D1
    DIVU    #3,         D0          ; divide by 2 for center on Y Axis
    MOVE.L  D0,         GROUND_Y     ; Enemy Y Position
    
    ; Draw LINE
    MOVE.B  #88,        D0           ; Draw LINE
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
    
*--------------------------------   
*THE PLAYER IS OFF THE GROUND
*--------------------------------  
SET_OFF_GROUND
    MOVE.L  #ON_GROUND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine
    
*--------------------------------  
*movement
*--------------------------------  
JUMP:
    CMP.L   #ON_GROUND_TRUE,PLYR_ON_GND   ; Player is on the Ground ?
    BEQ     PERFORM_JUMP            ; Do Jump
    BRA     JUMP_DONE               ;
PERFORM_JUMP:
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY ; Set the players velocity to true
    RTS                             ; Return to subroutine
JUMP_DONE:
    RTS                             ; Return to subroutine
    
MOV_RIGHT: 
    ADD.L   #1, PLAYER_X            ;if the above statement is true then this is used
    RTS
    
MOVE_LEFT:
    ADD.L   #-1,PLAYER_X            ;if the above statement is true then this is used
    RTS

    
    

*--------------------------------  
*DRAW PLAYER
*--------------------------------  
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #GREEN,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLAYER_WIDTH,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLAYER_HEIGHT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
    
*--------------------------------  
*DRAW ENEMY
*--------------------------------  
DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,    D1          ; X
    MOVE.L  ENEMY_Y,    D2          ; Y
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENEMY_WIDTH,   D3      ; Width
    MOVE.L  ENEMY_Y,    D4 
    ADD.L   #ENEMY_HEIGHT,   D4      ; Height


    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
DRAW_ENEMY_TWO:
    ; Set Pixel Colors
    MOVE.L  #PURPLE,      D1          ; Set Background color
    MOVE.B  #80,          D1          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_TWO_X,    D1          ; X
    MOVE.L  ENEMY_TWO_Y,    D2          ; Y
    MOVE.L  ENEMY_TWO_X,    D3
    ADD.L   #ENEMY_WIDTH_2,   D3      ; Width
    MOVE.L  ENEMY_TWO_Y,    D4 
    ADD.L   #ENEMY_HEIGHT_2,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
*--------------------------------  
*CHECKING FOR COLLISION
*--------------------------------  
CHECK_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,       D1          ; Move Player X to D1
    MOVE.L  ENEMY_X,        D2          ; Move Enemy X to D2
    ADD.L   ENEMY_WIDTH,    D2          ; Set Enemy width X + Width
    CMP.L   D1,             D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
    
PLAYER_X_LTE_TO_ENEMY_TWO_X_PLUS_W    
    MOVE.L  PLAYER_X,       D1          ; Move Player X to D1
    MOVE.L  ENEMY_TWO_X,    D2          ; Move Enemy X to D2
    ADD.L   ENEMY_WIDTH_2,  D2          ; Set Enemy width X + Width
    CMP.L   D1,             D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_TWO_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:     ; Check player is not  
    ADD.L   PLAYER_WIDTH,   D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,        D2          ; Move Enemy X to D2
    CMP.L   D1,             D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision  
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_TWO_X  
    ADD.L   PLAYER_WIDTH,   D1          ; Move Player Width to D1
    MOVE.L  ENEMY_TWO_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,             D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_TWO_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision  
    
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,       D1          ; Move Player Y to D1
    MOVE.L  ENEMY_Y,        D2          ; Move Enemy Y to D2
    ADD.L   ENEMY_HEIGHT,   D2          ; Set Enemy Height to D2
    CMP.L   D1,             D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
    
PLAYER_Y_LTE_TO_ENEMY_TWO_Y_PLUS_H
    MOVE.L  PLAYER_Y,       D1          ; Move Player Y to D1
    MOVE.L  ENEMY_TWO_Y,    D2          ; Move Enemy Y to D2
    ADD.L   ENEMY_HEIGHT_2, D2          ; Set Enemy Height to D2
    CMP.L   D1,             D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_TWO_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision  
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:     ; Less than or Equal ?
    ADD.L   PLAYER_HEIGHT,  D1          ; Add Player Height to D1
    MOVE.L  ENEMY_Y,        D2          ; Move Enemy Height to D2  
    CMP.L   D1,             D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_TWO_Y
    ADD.L   PLAYER_HEIGHT,  D1          ; Add Player Height to D1
    MOVE.L  ENEMY_TWO_Y,        D2      ; Move Enemy Height to D2  
    CMP.L   D1,             D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
    
COLLISION_CHECK_DONE:               ; No Collision Update points
    ADD.B   #POINTS,        D0          ; Move points upgrade to D1
    ADD.L   PLAYER_SCORE,   D0         ; Add to current player score
    MOVE.L  D0, PLAYER_SCORE        ; Update player score in memory

    RTS                             ; Return to subroutine

COLLISION:

    MOVE.L  #0, PLAYER_SCORE       ; Reset Player Score
    RTS                             ; Return to subroutine
    
    
*--------------------------------  
*EXIT THE GAME
*--------------------------------  
EXIT
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    
*--------------------------------  
*IN GAME MESSAGES
*--------------------------------  
SCORE_MSG       DC.B    'Score : ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode : ', 0     ; Keycode Message
EXIT_MSG        DC.B    'Exiting....', 0    ; Exit Message


*--------------------------------  
*COLOR
*--------------------------------  
GREEN       EQU     $00008000   ;this is the green colour code
RED         EQU     $000000FF   ;This is the red colour code
YELLOW      EQU     $0000FFFF   ; This is the yellow colour code
PURPLE      EQU     $00800080   ; this is the purple colour code 

*--------------------------------  
*SET THE SCREEN SIZE
*--------------------------------  
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height


*--------------------------------  
*CURRENT KEY PRESSED
*--------------------------------  
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed


*--------------------------------  
*CHARACTERS POSITION MEMORY LOCATIONS
*--------------------------------  
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

GROUND_X        DS.L    01  
GROUND_Y        DS.L    01

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    01  ; Reserve Space for Enemy Y Position
ENEMY_TWO_X     DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_TWO_Y     DS.L    01  ; Reserve Space for Enemy Y Position



*--------------------------------  
*END
*--------------------------------  
    END    START        ; last line of source













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
