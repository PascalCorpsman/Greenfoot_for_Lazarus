(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of Greenfoot for Lazarus                                 *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit upacman;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, ugreenfoot, OpenGLContext;

Type

  { Buttons }

  Buttons = Class(TActor)
  private
    ID: Integer;
    selected: Boolean;
    //public boolean muteS = false;
    //public boolean musicS = false;
    imageName: String;
    Procedure checkMouse();
    Procedure checkClicked();
  public
    Constructor Create(State: integer); reintroduce;
    Procedure Act(); override;
  End;

  { Player }

  Player = Class(TActor)
  private
  public
    playerIsDead: Boolean;
    paused: Boolean;
    Constructor create(); override;
  End;

  { Player2 }

  Player2 = Class(TActor)
    playerIsDead: Boolean;
    Constructor create(); override;
  End;

  Ready = Class(TActor)

  End;

  Life = Class(TActor)

  End;

  { Food1 }

  Food1 = Class(TActor)
  public
    Procedure Act(); override;
    Function hasPlayer(): Boolean;

  End;

  Food2 = Class(TActor)

  End;

  { Menu }

  Menu = Class(TActor) // Fertig.
  private
    Procedure makeImage(title, prefix: String);
  public
    Constructor Create(id: integer); reintroduce;
  End;

  { Ghost }

  Ghost = Class(TActor)
  private
    left: Boolean;
    right: Boolean;
    up: Boolean;
    down: Boolean;
    out_: Boolean;
    eatable: Boolean;
    dead: Boolean;
    exitCounter: integer;
    moveCounter: integer;
    dangerCounter: integer;
    setImage_: integer;
    //public int playerScore=0;
    //public int player2Score=0;
    ID: integer;
    //protected GreenfootSound eaten = new GreenfootSound("Ghost-eaten-sound.mp3");
    Procedure MotionSet();
    Procedure eatenPill();
    Procedure dangerCount();
    Procedure begin_;
    Procedure dangerSettings;
    Procedure followPlayerAI;
    Procedure MoveOut;
    Procedure MoveSet;
    Procedure eatableMove;
    Procedure eatPlayer;
    Procedure DeadMoveAI;
    Procedure Port;
    Procedure PlayerDied;
    Procedure Move;
    Procedure MotionMove;
    Procedure MotionImage;
    Function getPlayerDeath(): player;
    Function getPlayerDeath2(): player2;
    Function getCurrentFood: Food1;
    Function paused(): Player;
    Function canMove(x, y: integer): Boolean;
  public
    playerDie: Boolean;
    Constructor Create(ghostID: integer); reintroduce;
    Function getGhostSubimage(subimage: String): TGreenfootImage;
    Procedure Act(); override;

  End;

  { Wall }

  Wall = Class(TActor)
  public
    Procedure setImageRotation(angle: integer; imageString: String);
    Constructor Create(map: integer); reintroduce;
  End;

  { TPacmanField }

  TPacmanField = Class(TWorld)
  private
    Procedure Menu();
    Procedure mapReader(map, x, y: integer);
  public
    type_: integer;
    p1Left: String;
    p1Right: String;
    p1Up: String;
    p1Down: String;
    p2Left: String;
    p2Right: String;
    p2Up: String;
    p2Down: String;
    Pause: String;
    Constructor create(Parent: TOpenGLControl);
    Destructor destroy(); override;
    Procedure Act(); override;
    Procedure singleplayer();
  End;

Implementation

Const
  map: Array[0..40, 0..42] Of integer = (
    (13, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 14),
    (8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10),
    (8, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 16, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 16, 0, 2, 3, 0, 17, 0, 2, 4, 3, 0, 17, 0, 7, 0, 17, 0, 18, 11, 11, 11, 20, 0, 17, 0, 7, 0, 17, 0, 2, 4, 3, 0, 17, 0, 2, 3, 0, 16, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 10, 0, 0, 0, 8, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 21, 9, 9, 9, 19, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 17, 0, 2, 3, 0, 17, 0, 6, 0, 17, 0, 2, 4, 3, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 2, 4, 3, 0, 17, 0, 6, 0, 17, 0, 2, 3, 0, 17, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 17, 17, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 0, 18, 11, 11, 20, 0, 17, 0, 18, 11, 11, 20, 0, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 17, 17, 0, 10),
    (8, 0, 0, 0, 0, 0, 0, 17, 0, 5, 0, 0, 0, 0, 17, 0, 10, 0, 0, 8, 0, 17, 0, 10, 0, 0, 8, 0, 17, 0, 0, 0, 0, 5, 0, 17, 0, 0, 0, 0, 0, 0, 10),
    (0, 11, 11, 11, 11, 20, 0, 17, 0, 10, 4, 4, 3, 0, 17, 0, 21, 9, 9, 19, 0, 17, 0, 21, 9, 9, 19, 0, 17, 0, 2, 4, 4, 8, 0, 17, 0, 18, 11, 11, 11, 11, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 5, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 5, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 7, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 7, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 17, 17, 17, 17, 0, 6, 0, 0, 0, 6, 22, 22, 22, 22, 22, 22, 22, 6, 0, 0, 0, 6, 0, 17, 17, 17, 17, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 0, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (9, 9, 9, 9, 9, 19, 0, 17, 0, 2, 4, 4, 4, 19, 0, 0, 0, 5, 0, 23, 0, 0, 0, 24, 0, 5, 0, 0, 0, 21, 4, 4, 4, 3, 0, 17, 0, 21, 9, 9, 9, 9, 9),
    (0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 27, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0),
    (11, 11, 11, 11, 11, 20, 0, 17, 0, 2, 4, 4, 4, 20, 0, 0, 0, 5, 0, 25, 0, 0, 0, 26, 0, 5, 0, 0, 0, 18, 4, 4, 4, 3, 0, 17, 0, 18, 11, 11, 11, 11, 11),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 0, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 17, 17, 17, 17, 0, 7, 0, 0, 0, 21, 4, 4, 4, 4, 4, 4, 4, 19, 0, 0, 0, 7, 0, 17, 17, 17, 17, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 6, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 1, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 6, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 8, 0, 17, 0, 5, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 5, 0, 17, 0, 10, 0, 0, 0, 0, 0),
    (0, 9, 9, 9, 9, 19, 0, 17, 0, 10, 4, 4, 3, 0, 17, 0, 18, 11, 11, 20, 0, 17, 0, 18, 11, 11, 20, 0, 17, 0, 2, 4, 4, 8, 0, 17, 0, 21, 9, 9, 9, 9, 0),
    (8, 0, 0, 0, 0, 0, 0, 17, 0, 5, 0, 0, 0, 0, 17, 0, 10, 0, 0, 8, 0, 17, 0, 10, 0, 0, 8, 0, 17, 0, 0, 0, 0, 5, 0, 17, 0, 0, 0, 0, 0, 0, 10),
    (8, 0, 17, 17, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 0, 21, 9, 9, 19, 0, 17, 0, 21, 9, 9, 19, 0, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 17, 17, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 17, 0, 2, 3, 0, 17, 0, 7, 0, 17, 0, 2, 4, 3, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 2, 4, 3, 0, 17, 0, 7, 0, 17, 0, 2, 3, 0, 17, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 18, 11, 11, 11, 20, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 17, 0, 10, 0, 0, 0, 8, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 16, 0, 2, 3, 0, 17, 0, 2, 4, 3, 0, 17, 0, 6, 0, 17, 0, 21, 9, 9, 9, 19, 0, 17, 0, 6, 0, 17, 0, 2, 4, 3, 0, 17, 0, 2, 3, 0, 16, 0, 10),
    (8, 0, 17, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 0, 0, 0, 17, 0, 5, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 17, 0, 10),
    (8, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 16, 17, 17, 17, 17, 0, 5, 0, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 0, 10),
    (8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10),
    (12, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 0, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 0, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 15)
    );

  { Food1 }

Procedure Food1.Act;
Begin
  Inherited Act;
End;

Function Food1.hasPlayer: Boolean;
Begin
  result := ((getObjectsInRange(7, Player) <> Nil) Or (getObjectsInRange(7, Player2) <> Nil));
End;

{ Player }

Constructor Player.create;
Begin
  Inherited create;
  playerIsDead := false;
  paused := false;
End;

{ Player2 }

Constructor Player2.create;
Begin
  Inherited create;
  playerIsDead := false;
End;

{ Menu }

Procedure Menu.makeImage(title, prefix: String);
Var
  image: TGreenfootImage;
Begin
  image := TGreenfootImage.create(730, 700);
  image.setColor(Color(0, 0, 0, 128));
  image.fillRect(0, 0, 730, 700);
  image.FontSize := 72;
  image.setColor(WHITE);
  image.drawString(title, 200, 200);
  image.drawString(prefix, 100, 300);
  setImage(image);
End;

Constructor Menu.Create(id: integer);
Begin
  Case id Of
    1: setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'help pacman.png'));
    2: setImage(tGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'help ghost.png'));
    3: setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'help food.png'));
    4: setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'About page.png'));
    6: setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'pause menu.png'));
    7: makeImage('You Lost!', ' Your score Is : ');
  End;
End;

{ Ghost }

Procedure Ghost.MotionSet;
Var
  x, y: integer;
Begin
  x := getX();
  y := getY();
  If (y = 345) Then Begin
    left := true;
    right := false;
  End;
  If (y = 475) Then Begin
    left := false;
    right := true;
  End;
  If (x = 0) And (y = 345) Then setLocation(3, 475);
  If (x = 331) And (y = 475) Then setLocation(644, 345);
  motionMove();
  motionImage();
End;

Procedure Ghost.eatenPill;
Var
  eating: Food1;
Begin
  eating := getCurrentFood();
  If (eating <> Nil) Then Begin
    eatable := true;
    dangerCounter := 2;
  End;
End;

Procedure Ghost.dangerCount;
Begin
  If (dangerCounter > 0) And (dangerCounter < 1800) Then Begin
    dangerCounter := dangerCounter + 2;
  End;
End;

Procedure Ghost.begin_;
Begin
  If (getRandomNumber(1000) > 995) Then Begin
    setImage(getGhostSubimage('L'));
  End
  Else
    If (getRandomNumber(1000) > 995) Then Begin
      setImage(getGhostSubimage('R'));

    End
    Else
      If (getRandomNumber(1000) > 995) Then Begin
        setImage(getGhostSubimage('U'));
      End
      Else
        If (getRandomNumber(1000) > 995) Then Begin
          setImage(getGhostSubimage('D'));
        End
        Else
          If (getRandomNumber(1000) > 995) Then Begin
            setImage(getGhostSubimage(''));
          End;
End;

Procedure Ghost.dangerSettings;
Begin

End;

Procedure Ghost.followPlayerAI;
Begin
    //hier gehts weiter
      //     int player1X = playerGetPosition(1, "x"); int player1Y = playerGetPosition(1, "y");
    //     int player2X = playerGetPosition(2, "x"); int player2Y = playerGetPosition(2, "y");
    //     int posX = getX(); int posY = getY();
    //     if(left) {
    //         if((player1X<posX || player2X<posX) && (player1Y==posY || player2Y==posY) && (canMove(posX-23, posY) && canMove(posX-23, posY-22) && canMove(posX-23, posY+22) && canMove(posX-23, posY-6) && canMove(posX-23, posY+6) && canMove(posX-23, posY-12) && canMove(posX-23, posY+12))) left=true;
    //         else if((player1Y<posY || player2Y<posY) && (canMove(posX, posY-23) && canMove(posX-22, posY-23) && canMove(posX+22, posY-23) && canMove(posX-6, posY-23) && canMove(posX+6, posY-23) && canMove(posX-12, posY-23) && canMove(posX+12, posY-23))) {
    //             left=false;
    //             if(!eatable) up=true;
    //             else down=true;
    //         }
    //         else if((player1Y>posY || player2Y>posY) && (canMove(posX, posY+23) && canMove(posX-22, posY+23) && canMove(posX+22, posY+23) && canMove(posX-6, posY+23) && canMove(posX+6, posY+23) && canMove(posX-12, posY+23) && canMove(posX+12, posY+23))) {
    //             left=false;
    //             if(!eatable) down=true;
    //             else up=true;
    //         }
    //         else if(!canMove(posX-23, posY) && !canMove(posX, posY-23)) {
    //             left=false;
    //             if(!eatable) down=true;
    //             else up=true;
    //         }
    //         else if(!canMove(posX-23, posY) && !canMove(posX, posY+23)) {
    //             left=false;
    //             if(!eatable) up=true;
    //             else down=true;
    //         }
    //     }
    //     else if(right) {
    //         if((player1X>posX || player2X>posX) && (player1Y==posY || player2Y==posY) && (canMove(posX+23, posY) && canMove(posX+23, posY-22) && canMove(posX+23, posY+22) && canMove(posX+23, posY-6) && canMove(posX+23, posY+6) && canMove(posX+23, posY-12) && canMove(posX+23, posY+12))) right=true;
    //         else if((player1Y<posY || player2Y<posY) && (canMove(posX, posY-23) && canMove(posX-22, posY-23) && canMove(posX+22, posY-23) && canMove(posX-6, posY-23) && canMove(posX+6, posY-23) && canMove(posX-12, posY-23) && canMove(posX+12, posY-23))) {
    //             right=false;
    //             if(!eatable) up=true;
    //             else down=true;
    //         }
    //         else if((player1Y>posY || player2Y>posY) && (canMove(posX, posY+23) && canMove(posX-22, posY+23) && canMove(posX+22, posY+23) && canMove(posX-6, posY+23) && canMove(posX+6, posY+23) && canMove(posX-12, posY+23) && canMove(posX+12, posY+23))) {
    //             right=false;
    //             if(!eatable) down=true;
    //             else up=true;
    //         }
    //         else if(!canMove(posX+23, posY) && !canMove(posX, posY-23)) {
    //             right=false;
    //             if(!eatable) down=true;
    //             else up=true;
    //         }
    //         else if(!canMove(posX+23, posY) && !canMove(posX, posY+23)) {
    //             left=false;
    //             if(!eatable) up=true;
    //             else down=true;
    //         }
    //     }
    //     else if(up) {
    //         if((player1Y<posY || player2Y<posY) && (player1X==posX || player2X==posX) && (canMove(posX, posY-23) && canMove(posX-22, posY-23) && canMove(posX+22, posY-23) && canMove(posX-6, posY-23) && canMove(posX+6, posY-23) && canMove(posX-12, posY-23) && canMove(posX+12, posY-23))) up=true;
    //         else if((player1X<posX || player2X<posX) && (canMove(posX-23, posY) && canMove(posX-23, posY-22) && canMove(posX-23, posY+22) && canMove(posX-23, posY-6) && canMove(posX-23, posY+6) && canMove(posX-23, posY-12) && canMove(posX-23, posY+12))) {
    //             up=false;
    //             if(!eatable) left=true;
    //             else right=true;
    //         }
    //         else if((player1X>posX || player2X>posX) && (canMove(posX+23, posY) && canMove(posX+23, posY-22) && canMove(posX+23, posY+22) && canMove(posX+23, posY-6) && canMove(posX+23, posY+6) && canMove(posX+23, posY-12) && canMove(posX+23, posY+12))) {
    //             up=false;
    //             if(!eatable) right=true;
    //             else left=true;
    //         }
    //         else if(!canMove(posX, posY-23) && !canMove(posX-23, posY)) {
    //             up=false;
    //             if(!eatable) right=true;
    //             else left=true;
    //         }
    //         else if(!canMove(posX, posY-23) && !canMove(posX+23, posY)) {
    //             up=false;
    //             if(!eatable) left=true;
    //             else right=true;
    //         }
    //     }
    //     else if(down) {
    //         if((player1Y>posY || player2Y>posY) && (player1X==posX || player2X==posX) && (canMove(getX(), getY()+23) && canMove(getX()-22, getY()+23) && canMove(getX()+22, getY()+23) && canMove(getX()-6, getY()+23) && canMove(getX()+6, getY()+23) && canMove(getX()-12, getY()+23) && canMove(getX()+12, getY()+23))) down=true;
    //         else if((player1X<posX || player2X<posX) && (canMove(posX-23, posY) && canMove(posX-23, posY-22) && canMove(posX-23, posY+22) && canMove(posX-23, posY-6) && canMove(posX-23, posY+6) && canMove(posX-23, posY-12) && canMove(posX-23, posY+12))) {
    //             down=false;
    //             if(!eatable) left=true;
    //             else right=true;
    //         }
    //         else if((player1X>posX || player2X>posX) && (canMove(posX+23, posY) && canMove(posX+23, posY-22) && canMove(posX+23, posY+22) && canMove(posX+23, posY-6) && canMove(posX+23, posY+6) && canMove(posX+23, posY-12) && canMove(posX+23, posY+12))) {
    //             down=false;
    //             if(!eatable) right=true;
    //             else left=true;
    //         }
    //         else if(!canMove(posX, posY+23) && !canMove(posX-23, posY)) {
    //             up=false;
    //             if(!eatable) right=true;
    //             else left=true;
    //         }
    //         else if(!canMove(posX, posY+23) && !canMove(posX+23, posY)) {
    //             up=false;
    //             if(!eatable) left=true;
    //             else right=true;
    //         }
    //     }
End;

Procedure Ghost.MoveOut;
Var
  y: integer;
Begin
  y := getY();
  If (y = 260) Then Begin
    out_ := true;
  End
  Else Begin
    left := false;
    right := false;
    up := true;
    down := false;
    If (Not eatable) Then Begin
      move();
    End
    Else Begin
      eatableMove();
    End;
  End;
End;

Procedure Ghost.MoveSet;
Begin
  If (moveCounter = 0) Then Begin
    If (getObjectsInRange(99, Player) = Nil) And (getObjectsInRange(99, Player2) = Nil) Then Begin
      If (left) Then Begin
        If (canMove(getX(), getY() - 23) And canMove(getX() - 22, getY() - 23) And canMove(getX() + 22, getY() - 23) And canMove(getX() - 6, getY() - 23) And canMove(getX() + 6, getY() - 23) And canMove(getX() - 12, getY() - 23) And canMove(getX() + 12, getY() - 23) And (getRandomNumber(1000) > 800)) Then Begin
          up := true;
          left := false;
        End
        Else
          If (canMove(getX(), getY() + 23) And canMove(getX() - 22, getY() + 23) And canMove(getX() + 22, getY() + 23) And canMove(getX() - 6, getY() + 23) And canMove(getX() + 6, getY() + 23) And canMove(getX() - 12, getY() + 23) And canMove(getX() + 12, getY() + 23) And (getRandomNumber(1000) > 750)) Then Begin
            down := true;
            left := false;
          End
          Else
            If (Not canMove(getX() - 23, getY()) And (getRandomNumber(1000) > 990)) Then Begin
              right := true;
              left := false;
            End;
      End
      Else
        If (right) Then Begin
          If (canMove(getX(), getY() - 23) And canMove(getX() - 22, getY() - 23) And canMove(getX() + 22, getY() - 23) And canMove(getX() - 6, getY() - 23) And canMove(getX() + 6, getY() - 23) And canMove(getX() - 12, getY() - 23) And canMove(getX() + 12, getY() - 23) And (getRandomNumber(1000) > 800)) Then Begin
            up := true;
            right := false;
          End
          Else
            If (canMove(getX(), getY() + 23) And canMove(getX() - 22, getY() + 23) And canMove(getX() + 22, getY() + 23) And canMove(getX() - 6, getY() + 23) And canMove(getX() + 6, getY() + 23) And canMove(getX() - 12, getY() + 23) And canMove(getX() + 12, getY() + 23) And (getRandomNumber(1000) > 750)) Then Begin
              down := true;
              right := false;
            End
            Else
              If (Not canMove(getX() + 23, getY()) And (getRandomNumber(1000) > 990)) Then Begin
                left := true;
                right := false;
              End
        End
        Else
          If (up) Then Begin
            If (canMove(getX() - 23, getY()) And canMove(getX() - 23, getY() - 22) And canMove(getX() - 23, getY() + 22) And canMove(getX() - 23, getY() - 6) And canMove(getX() - 23, getY() + 6) And canMove(getX() - 23, getY() - 12) And canMove(getX() - 23, getY() + 12) And (getRandomNumber(1000) > 800)) Then Begin
              left := true;
              up := false;
            End
            Else
              If (canMove(getX() + 23, getY()) And canMove(getX() + 23, getY() - 22) And canMove(getX() + 23, getY() + 22) And canMove(getX() + 23, getY() - 6) And canMove(getX() + 23, getY() + 6) And canMove(getX() + 23, getY() - 12) And canMove(getX() + 23, getY() + 12) And (getRandomNumber(1000) > 750)) Then Begin
                right := true;
                up := false;
              End
              Else
                If (Not canMove(getX(), getY() - 23) And (getRandomNumber(1000) > 990)) Then Begin
                  down := true;
                  up := false;
                End
          End
          Else
            If (down) Then Begin
              If (canMove(getX() - 23, getY()) And canMove(getX() - 23, getY() - 22) And canMove(getX() - 23, getY() + 22) And canMove(getX() - 23, getY() - 6) And canMove(getX() - 23, getY() + 6) And canMove(getX() - 23, getY() - 12) And canMove(getX() - 23, getY() + 12) And (getRandomNumber(1000) > 800)) Then Begin
                left := true;
                down := false;
              End
              Else
                If (canMove(getX() + 23, getY()) And canMove(getX() + 23, getY() - 22) And canMove(getX() + 23, getY() + 22) And canMove(getX() + 23, getY() - 6) And canMove(getX() + 23, getY() + 6) And canMove(getX() + 23, getY() - 12) And canMove(getX() + 23, getY() + 12) And (getRandomNumber(1000) > 750)) Then Begin
                  right := true;
                  down := false;
                End
                Else
                  If (Not canMove(getX(), getY() + 23) And (getRandomNumber(1000) > 990)) Then Begin
                    up := true;
                    down := false;
                  End
            End;
    End
    Else
      followPlayerAI();
    If (Not eatable) Then Begin
      move();
    End
    Else Begin
      eatableMove();
    End;
  End
  Else Begin
    eatableMove();
  End;
  eatPlayer();
End;

Procedure Ghost.eatableMove;
Begin

End;

Procedure Ghost.eatPlayer;
Begin

End;

Procedure Ghost.DeadMoveAI;
Begin

End;

Procedure Ghost.Port;
Begin

End;

Procedure Ghost.PlayerDied;
Var
  death: Player;
  death2: Player2;
Begin
  death := getPlayerDeath();
  death2 := getPlayerDeath2();
  If (death <> Nil) Or (death2 <> Nil) Then Begin
    playerDie := true;
    setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'pacman6.png'));
  End;
End;

Procedure Ghost.Move;
Begin

End;

Procedure Ghost.MotionMove;
Begin
  If (left) Then Begin
    setLocation(getX() - 2, getY());
  End
  Else Begin
    If (right) Then Begin
      setLocation(getX() + 2, getY());
    End;
  End;
End;

Procedure Ghost.MotionImage;
Var
  y: integer;
Begin
  y := getY();
  If (moveCounter = 10) Then Begin
    If (y = 345) Then Begin
      If (setImage_ = 1) Then Begin
        setImage(getGhostSubimage('L2'));
        setImage_ := 2;
      End
      Else Begin
        setImage(getGhostSubimage('L'));
        setImage_ := 1;
      End;
    End;
    If (y = 475) Then Begin
      If (setImage_ = 1) Then Begin
        setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'GhostEatable.png'));
        setImage_ := 2;
      End
      Else Begin
        setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'GhostEatable3.png'));
        setImage_ := 1;
      End;
    End;
    moveCounter := 0;
  End
  Else
    moveCounter := moveCounter + 1;
End;

Function Ghost.getPlayerDeath: player;
Var
  i: integer;
  list: TActorList;
Begin
  result := Nil;
  list := getWorld().getObjects(Player);
  For i := 0 To high(list) Do Begin
    If (list[i] As player).playerIsDead Then Begin
      result := list[i] As player;
      exit;
    End;
  End;
End;

Function Ghost.getPlayerDeath2: player2;
Var
  i: integer;
  list: TActorList;
Begin
  result := Nil;
  list := getWorld().getObjects(Player2);
  For i := 0 To high(list) Do Begin
    If (list[i] As Player2).playerIsDead Then Begin
      result := list[i] As player2;
      exit;
    End;
  End;
End;

Function Ghost.getCurrentFood: Food1;
Var
  i: integer;
  list: TActorList;
Begin
  result := Nil;
  list := getWorld().getObjects(Food1);
  For i := 0 To high(list) Do Begin
    //for (Object obj : getWorld().getObjects(Food1.class)) {
    If (list[i] As food1).hasPlayer() Then Begin
      result := list[i] As food1;
      exit;
    End;
  End;
End;

Function Ghost.paused: Player;
Var
  list: TActorList;
  i: integer;
Begin
  result := Nil;
  list := getWorld().getObjects(player);
  For i := 0 To high(list) Do Begin
    If (list[i] As player).paused Then Begin
      result := list[i] As player;
      exit;
    End;
  End;

End;

Function Ghost.canMove(x, y: integer): Boolean;
Begin

End;

Constructor Ghost.Create(ghostID: integer);
Begin
  Inherited create;
  id := ghostID;
  exitCounter := 0;
  moveCounter := 0;
  dangerCounter := 0;
  setImage_ := 1;
  Case id Of
    1: setImage(tGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost1.png'));
    2: setImage(tGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost2.png'));
    3: setImage(tGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost3.png'));
    4: setImage(tGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost4.png'));
    5: setImage(tGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost5.png'));
  End;
End;

Function Ghost.getGhostSubimage(subimage: String): TGreenfootImage;
Begin
  result := TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost' + inttostr(id) + subimage + '.png');
End;

Procedure Ghost.Act;
Var
  pw: TPacmanField;
Begin
  Inherited Act;
  pw := TPacmanField(getWorld());
  If (pw.type_ = 0) Then Begin
    motionSet();
  End
  Else Begin
    If getWorld().getObjects(Ready) = Nil Then Begin //         if(!getWorld().getObjects(Ready.class).isEmpty()) {
      Case id Of
        1: Begin
            setLocation(335, 320);
            setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost1.png'));
          End;
        2: Begin
            setLocation(395, 320);
            setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost2.png'));
          End;
        3: Begin
            setLocation(365, 350);
            setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost3.png'));
          End;
        4: Begin
            setLocation(335, 380);
            setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost4.png'));
          End;
        5: Begin
            setLocation(395, 380);
            setImage(TGreenfootImage.create('images' + PathDelim + 'pacman' + PathDelim + 'Ghost5.png'));
          End;
      End;
      playerDie := false;
      setRotation(0);
      out_ := false;
      dead := false;
      eatable := false;
      dangerCounter := 0;
      exitCounter := 0;
      moveCounter := 0;
      setImage_ := 1;
    End;
    //         if(getWorld().getObjects(Menu.class).isEmpty() && getWorld().getObjects(Ready.class).isEmpty()) {
    If (getWorld().getObjects(Menu) = Nil) And (getWorld().getObjects(Ready) = Nil) Then Begin
      If (Not playerDie) Then Begin
        eatenPill();
        dangerCount();
        If (exitCounter <> 0) Then Begin
          If (Not eatable) Then Begin
            begin_();
          End
          Else Begin
            dangerSettings();
          End;
        End
        Else
          If (Not out_) Then Begin
            moveOut();
          End
          Else
            If (Not dead) Then Begin
              moveSet();
            End
            Else Begin
              deadMoveAI();
              move();
            End;
        port();
        playerDied();
      End;
    End;
  End;
End;

{ Wall }

Procedure Wall.setImageRotation(angle: integer; imageString: String);
Var
  image: TGreenfootImage;
Begin
  image := TGreenfootImage.Create(imageString);
  //image.rotate(angle); //-- ist im Framework nicht Vollständig Implementiert.
  setRotation(angle);
  setImage(image);
End;

Constructor Wall.Create(map: integer);
Begin
  Inherited create;
  If (map = 2) Then setImage('images' + PathDelim + 'pacman' + PathDelim + 'Wall1.png');
  If (map = 3) Then setImageRotation(180, 'images' + PathDelim + 'pacman' + PathDelim + 'Wall1.png');
  If (map = 4) Then setImage('images' + PathDelim + 'pacman' + PathDelim + 'WallEdge.png');
  If (map = 5) Then setImageRotation(90, 'images' + PathDelim + 'pacman' + PathDelim + 'WallEdge.png');
  If (map = 6) Then setImageRotation(90, 'images' + PathDelim + 'pacman' + PathDelim + 'Wall1.png');
  If (map = 7) Then setImageRotation(270, 'images' + PathDelim + 'pacman' + PathDelim + 'Wall1.png');
  If (map = 8) Then setImage('images' + PathDelim + 'pacman' + PathDelim + 'SWallEdge.png');
  If (map = 9) Then setImageRotation(90, 'images' + PathDelim + 'pacman' + PathDelim + 'SWallEdge.png');
  If (map = 10) Then setImageRotation(180, 'images' + PathDelim + 'pacman' + PathDelim + 'SWallEdge.png');
  If (map = 11) Then setImageRotation(270, 'images' + PathDelim + 'pacman' + PathDelim + 'SWallEdge.png');
  If (map = 12) Then setImage('images' + PathDelim + 'pacman' + PathDelim + 'Corner.png');
  If (map = 13) Then Begin
    setImage('images' + PathDelim + 'pacman' + PathDelim + 'Corner.png');
    setImageRotation(90, 'images' + PathDelim + 'pacman' + PathDelim + 'Corner.png');
  End;
  If (map = 14) Then setImageRotation(180, 'images' + PathDelim + 'pacman' + PathDelim + 'Corner.png');
  If (map = 15) Then setImageRotation(270, 'images' + PathDelim + 'pacman' + PathDelim + 'Corner.png');
  If (map = 18) Then setImage('images' + PathDelim + 'pacman' + PathDelim + 'RCorner.png');
  If (map = 19) Then setImageRotation(180, 'images' + PathDelim + 'pacman' + PathDelim + 'RCorner.png');
  If (map = 20) Then setImageRotation(90, 'images' + PathDelim + 'pacman' + PathDelim + 'RCorner.png');
  If (map = 21) Then setImageRotation(270, 'images' + PathDelim + 'pacman' + PathDelim + 'RCorner.png');
  If (map = 22) Then setImageRotation(0, 'images' + PathDelim + 'pacman' + PathDelim + 'Gate.png');
End;

{ Buttons }

Procedure Buttons.checkMouse;
Begin
  (* -- Die Animation mit Mouse Over --
  if (Greenfoot.mouseMoved(null)) {
             if (Greenfoot.mouseMoved(this) && !selected) {
                 switch(ID) {
                     case 1: setImage(new GreenfootImage("1 player selected.png"));
                     break;
                     case 2: setImage(new GreenfootImage("2 player selected.png"));
                     break;
                     case 3: setImage(new GreenfootImage("About selected.png"));
                     break;
                     case 4: setImage(new GreenfootImage("Help selected.png"));
                     break;
                     case 7: setImage(new GreenfootImage("resume selected.png"));
                     break;
                     case 8: setImage(new GreenfootImage("retry selected.png"));
                     break;
                 }
                 selected =true;
             }
             if (!Greenfoot.mouseMoved(this) && selected) {
                 switch(ID) {
                     case 1: setImage(new GreenfootImage("1 player.png"));
                     break;
                     case 2: setImage(new GreenfootImage("2 player.png"));
                     break;
                     case 3: setImage(new GreenfootImage("About.png"));
                     break;
                     case 4: setImage(new GreenfootImage("Help.png"));
                     break;
                     case 7: setImage(new GreenfootImage("resume.png"));
                     break;
                     case 8: setImage(new GreenfootImage("retry.png"));
                     break;
                 }
                 selected = false;
             }
         } *)
  checkClicked();
End;

Procedure Buttons.checkClicked;
Var
  info: TMouseInfo;
  clicked: TMouseButton;
  world: TWorld;
  pw: TPacmanField;
  all: TActorList;
Begin
  info := getMouseInfo();
  If assigned(info) Then Begin
    clicked := info.getButton();
    If mouseClicked(self) And (clicked = MB_Left) Then Begin
      world := getWorld();
      pw := getWorld() As TPacmanField;
      all := getWorld().getObjects(Nil);
      Case id Of
        1: Begin
            //            stop();
            getWorld().removeObjects(all);
            pw.singleplayer();
          End;
        //                   case 2: pw.begin.stop(); getWorld().removeObjects(all);
        //                           pw.multiplayer();
        //                   break;
        //                   case 3: getWorld().addObject(new Menu(4), 365, 350); getWorld().addObject(new ButtonsOverlay(2), 600, 55);
        //                   break;
        //                   case 4: getWorld().addObject(new Menu(1), 365, 350); getWorld().addObject(new ButtonsOverlay(1), 600, 55);
        //                           getWorld().addObject(new ButtonsOverlay(3), 80, 623); getWorld().addObject(new ButtonsOverlay(4), 245, 623); getWorld().addObject(new ButtonsOverlay(5), 163, 540); getWorld().addObject(new ButtonsOverlay(6), 163, 623);
        //                           getWorld().addObject(new ButtonsOverlay(7), 458, 623); getWorld().addObject(new ButtonsOverlay(8), 623, 623); getWorld().addObject(new ButtonsOverlay(9), 537, 543); getWorld().addObject(new ButtonsOverlay(10), 540, 623);
        //                           getWorld().addObject(new ButtonsOverlay(11), 160, 345);
        //                   break;
        //                   case 5: if(!pw.musicS) {
        //                               setImage(new GreenfootImage("music button 2.png")); pw.musicS=true;
        //                           }
        //                           else if(pw.musicS) {
        //                               setImage(new GreenfootImage("music button 1.png")); pw.musicS=false;
        //                           }
        //                           getImage().scale(30,30);
        //                   break;
        //                   case 6: if(!pw.muteS) {
        //                               setImage(new GreenfootImage("mute button 2.png")); pw.muteS=true;
        //                           }
        //                           else if(pw.muteS) {
        //                               setImage(new GreenfootImage("mute button 1.png")); pw.muteS=false;
        //                           }
        //                           getImage().scale(30,30);
        //                   break;
        //                   case 7: getWorld().removeObjects(getWorld().getObjects(Menu.class)); getWorld().removeObjects(getWorld().getObjects(ButtonsOverlay.class));
        //                           getWorld().removeObject(this);
        //                   break;
        //                   case 8: if(pw.type==1) {
        //                               getWorld().removeObjects(all); pw.singleplayer();
        //                           }
        //                           else {
        //                               getWorld().removeObjects(all); pw.multiplayer();
        //                           }
        //                   break;
      End;
    End;
  End;
End;

Constructor Buttons.Create(State: integer);
Begin
  Inherited create;
  ID := state;
  // if(ID==1) imageName="1 player";
  // else if(ID==2) imageName="2 player";
  // else if(ID==3) imageName="About";
  // else if(ID==4) imageName="Help";
  // else if(ID==5) imageName="music button 1";
  // else if(ID==6) imageName="mute button 1";
  // else if(ID==7) imageName="resume";
  // else imageName="retry";
  Case (ID) Of
    1: setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + '1 player.png'));
    2: setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + '2 player.png'));
    3: setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'About.png'));
    4: setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'Help.png'));
    5: Begin
        setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'music button 1. png'));
        getImage().scale(30, 30);
      End;
    6: Begin
        setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'mute button 1. png'));
        getImage().scale(30, 30);
      End;
    7: setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'resume.png'));

    8: setImage(TGreenfootImage.Create('images' + PathDelim + 'pacman' + PathDelim + 'retry.png'));
  End;
End;

Procedure Buttons.Act;
Begin
  checkMouse();
End;

{ TPacmanField }

Procedure TPacmanField.Menu;
Var
  i: integer;
Begin
  //addObject(new Cover(), 365, 350);
  addObject(Buttons.create(1), 560, 290); // 1 Player
  //addObject(new Buttons(2), 560, 377);  // 2 Player
  //addObject(new Buttons(3), 528, 455);  // About
  //addObject(new Buttons(4), 558, 543); // Help
  //      for (int i=0; i<25; i++) addObject(new Wall(),i*15 , 410);
  //
  //      addObject(new Player(), 375, 345);
  //      addObject(new Ghost(1), 420, 345);
  //      addObject(new Ghost(2), 465, 345);
  //      addObject(new Ghost(3), 510, 345);
  //      addObject(new Ghost(4), 555, 345);
  //      addObject(new Ghost(5), 600, 345);
  //      Buttons mute = new Buttons(6); // Mute
  //      if(muteS) mute.setImage("mute button 2.png");
  //      else mute.setImage("mute button 1.png");
  //      mute.getImage().scale(30,30);
  //
  //      Buttons music = new Buttons(5); // Musiv
  //      if(musicS) music.setImage("music button 2.png");
  //      else music.setImage("music button 1.png");
  //      music.getImage().scale(30,30);
  //
  //      addObject(mute, 465, 620);
  //      addObject(music, 510, 620);
  //      begin.setVolume(60);
  //      if(!musicS) begin.play();

  type_ := 0;
  setSpeed(50);
  //  setPaintOrder([TButtonsOverlay, TMenu, TButtons, TCover, TWall, TGhost, TPlayer, TFood]);
  //  setActOrder([TPlayer, TFood, TGhost]);

End;

Procedure TPacmanField.mapReader(map, x, y: integer);
Begin
  If (map < 1) Then exit;
  If (map < 2) Then exit;
  If (map < 23) Then Begin
    If (map = 16) Then Begin
      addObject(Food1.create(), y * 15 + 50, x * 15 + 50);
      exit;
    End;
    If (map = 17) Then Begin
      addObject(Food2.create(), y * 15 + 50, x * 15 + 50);
      exit;
    End;
    addObject(Wall.create(map), y * 15 + 50, x * 15 + 50);
    exit;
  End;
  Case map Of
    23: addObject(Ghost.create(1), y * 15 + 50, x * 15 + 50);
    24: addObject(Ghost.create(2), y * 15 + 50, x * 15 + 50);
    25: addObject(Ghost.create(3), y * 15 + 50, x * 15 + 50);
    26: addObject(Ghost.create(4), y * 15 + 50, x * 15 + 50);
    27: addObject(Ghost.create(5), y * 15 + 50, x * 15 + 50);
  End;
End;

Constructor TPacmanField.create(Parent: TOpenGLControl);
Begin
  Inherited create(Parent, 731, 701, 1);

  p1Left := 'left';
  p1Right := 'right';
  p1Up := 'up';
  p1Down := 'down';
  p2Left := 'a';
  p2Right := 'd';
  p2Up := 'w';
  p2Down := 's';
  pause := 'p';

  menu();
  start();
End;

Destructor TPacmanField.destroy;
Begin
  Inherited destroy;
End;

Procedure TPacmanField.Act;
Begin
  Inherited Act;
  //if(type==0 && musicS) begin.setVolume(0);
  //else if(type==0) begin.setVolume(60);
End;

Procedure TPacmanField.singleplayer;
Var
  x, y, i: integer;
Begin
  For x := 0 To high(map) Do Begin
    For y := 0 To high(map[x]) Do Begin
      mapReader(map[x, y], x, y); //Greg v code
      If (map[x, y] = 1) Then addObject(Player.create(), y * 15 + 50, x * 15 + 50);
    End;
  End;

  addObject(Ready.create(), 365, 530);
  For i := 0 To 2 Do Begin
    addObject(Life.create(), 25, 475 + i * 50);
  End;
  addObject(Life.create(), 25, 270);
  //    Buttons mute = new Buttons(6); if(muteS) mute.setImage("mute button 2.png"); else mute.setImage("mute button 1.png"); mute.getImage().scale(30,30);
  //    Buttons music = new Buttons(5); if(musicS) music.setImage("music button 2.png"); else music.setImage("music button 1.png"); music.getImage().scale(30,30);
  //    addObject(mute, 345, 670); addObject(music, 390, 670);

  //    setPaintOrder([Buttons, Score, Menu, Wall, Ghost, Player, Fruit, Food]);
  //setActOrder([Food,Ghost,Player]);
  setSpeed(56);
  type_ := 1;
End;

End.

