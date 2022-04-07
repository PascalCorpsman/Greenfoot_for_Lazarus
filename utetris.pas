(*
 * Quelle: https://www.greenfoot.org/scenarios/335
 *)

Unit utetris;

{$MODE ObjFPC}{$H+}

Interface

Uses
  SysUtils, ugreenfoot, OpenGLContext;


Const
  // possible directions of a tetromino
  NORTH = 0;
  WEST = 1;
  SOUTH = 2;
  EAST = 3;

Type

  TTetrisWorld = Class;

  { TWall }

  TWall = Class(TActor)
  private
  public
    Constructor create(); override;
  End;

  { TBlock }

  TBlock = Class(TActor) // -- Fertig
  private
  public
    Constructor Create(aColor: String); virtual; reintroduce;
  End;

  { TTetromino }

  TTetromino = Class(TActor)
  private

    b: Array Of TBlock; // each tetromino consists of four blocks

    direction: integer; // direction of the tetromino

    dead: Boolean; // is the tetromino dead?

    counter: Integer; // internal counter

    Function Left(): Boolean;
    Function leftOccupied(): boolean;
    Function Right(): Boolean;
    Function rightOccupied(): Boolean;
    Function turnLeft(): Boolean;
    Function oneDown(): Boolean;
    Procedure Down();
    Function blockFree(index: integer): boolean;
    Procedure CheckRows();
    Procedure clearRow(row: integer);
    Procedure landslide(row: integer);
    Procedure Die();
    Function CheckEnd(tetro: tTetromino): Boolean;
    Function genDirection(): integer;
    Function Length(Number: integer): Integer;
  protected

    // changes the direction of a tetromino; the current direction is stored in
    // attribute direction
    Procedure setDirection(); virtual; abstract;
    Function leftMost(): TBlock; virtual; abstract;
    Function rightMost(): TBlock; virtual; abstract;
    Function turnPossible(): boolean; virtual; abstract;

  public
    Constructor Create(aColor: String; aOwner: TTetrisWorld); virtual; reintroduce;

    Procedure act(); override;
    Procedure Delete();
  End;

  { TITetromino }

  TITetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TZTetromino }

  TZTetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TJTetromino }

  TJTetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TLTetromino }

  TLTetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TOTetromino }

  TOTetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TTTetromino }

  TTTetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TSTetromino }

  TSTetromino = Class(TTetromino)
  private

  protected
    Procedure addedToWorld(Const World: TWorld); override;
    Function genStartX(): integer;

    Procedure setDirection(); override;
    Function leftMost(): TBlock; override;
    Function rightMost(): TBlock; override;
    Function turnPossible(): boolean; override;

  public
    Constructor Create(AOwner: TTetrisWorld); reintroduce;
  End;

  { TCounter }

  TCounter = Class(TActor) // -- Fertig
  private
    textColor: TGreenFootColor;
    value: integer;
    text: String;
    Procedure updateImage();

  protected
    Procedure addedToWorld(Const World: TWorld); override;

  public
    Constructor Create(prefix: String); virtual; reintroduce;

    Procedure Add(apoints: integer);
    Procedure Subtract(apoints: integer);
    Function GetValue(): integer;
  End;

  { TPoints }

  TPoints = Class // -- Fertig
  private
    counter: TCounter;
  public
    Constructor Create(aOwner: TTetrisWorld);
    Procedure Add(apoints: integer);
    Function getPoints(): integer;
  End;

  { TScoreBoard }

  TScoreBoard = Class(TActor)
  private
    Score: integer;
    Procedure MakeImage(Title, Prefix: String; aScore: integer);
  protected
    Procedure addedToWorld(Const World: TWorld); override;

  public
    Constructor Create(aScore: integer); reintroduce;
  End;

  { TTetrisWorld }

  TTetrisWorld = Class(TWorld)
  private
    world: TTetrisWorld;

    pointView: TPoints;

    currentTetromino: TTetromino;

    numberOfTetrominos: integer;

    speed: integer;
  public
    Constructor create(Parent: TOpenGLControl);
    Destructor destroy(); override;
    Function GetWorld: TWorld;
    Function genTetromino(): TTetromino;
    Function getCurrentTetromino(): TTetromino;
    Procedure setCurrentTetromino(t: TTetromino);
    Procedure newPoints(rows: integer);
    Procedure NewTilePlaced(); // Add some points for Tile placing
    Function getPoints(): integer;
    Procedure GameOver();
  End;


Implementation

Const
  Cols = 10;
  Rows = 24;

  { TScoreBoard }

Procedure TScoreBoard.MakeImage(Title, Prefix: String; aScore: integer);
Var
  w: Integer;
  h: integer;
  image: TGreenfootImage;
Begin
  w := (getWorld().getWidth() - 1) * getWorld().getCellSize();
  h := w;
  image := getImage();
  If Not assigned(image) Then Begin
    image := TGreenfootImage.Create(w, h);
  End;

  image.SetColor(Color(0, 0, 0, 160));
  image.fillRect(0, 0, w, h);
  image.setColor(Color(255, 255, 255, 100));
  image.fillRect(5, 5, w - 10, h - 10);
  image.FontSize := 24;
  //      Font font = image.getFont();
  //      font = font.deriveFont(FONT_SIZE);
  //      image.setFont(font);
  image.setColor(WHITE); // Weise Schrift
  image.drawString(title, w Div 10, h Div 3);
  image.drawString(prefix + inttostr(ascore), w Div 10, (2 * h) Div 3);
  setImage(image);
End;

Procedure TScoreBoard.addedToWorld(Const World: TWorld);
Begin
  Inherited addedToWorld(World);
  makeImage('Game Over', 'Score: ', score);
End;

Constructor TScoreBoard.Create(aScore: integer);
Begin
  Inherited Create;
  score := aScore;
End;

{ TSTetromino }

Constructor TSTetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited create('green', AOwner);
End;

Procedure TSTetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
Begin
  Inherited addedToWorld(World);
  direction := genDirection();
  start := genStartX();
  getWorld().addObject(b[0], start, 1);
  getWorld().addObject(b[1], start + 1, 1);
  getWorld().addObject(b[2], start + 1, 0);
  getWorld().addObject(b[3], start + 2, 0);
  setDirection();
End;

Function TSTetromino.genStartX(): integer;
Begin
  result := random(getWorld().getWidth() - 2);
End;

Procedure TSTetromino.setDirection();
Begin
  Case (direction) Of
    NORTH,
      SOUTH: Begin
        b[0].setLocation(b[1].getX() - 1, b[1].getY());
        b[2].setLocation(b[1].getX(), b[1].getY() - 1);
        b[3].setLocation(b[1].getX() + 1, b[1].getY() - 1);

      End;
    WEST,
      EAST: Begin
        b[0].setLocation(b[1].getX(), b[1].getY() + 1);
        b[2].setLocation(b[1].getX() - 1, b[1].getY());
        b[3].setLocation(b[1].getX() - 1, b[1].getY() - 1);
      End;
  End;
End;

Function TSTetromino.leftMost(): TBlock;
Begin
  Case (direction) Of
    NORTH,
      SOUTH: result := b[0];
  Else
    result := b[2]; // WEST, EAST
  End;
End;

Function TSTetromino.rightMost(): TBlock;
Begin
  Case (direction) Of
    NORTH,
      SOUTH: result := b[3];
  Else
    result := b[1]; // WEST, EAST
  End;
End;

Function TSTetromino.turnPossible(): boolean;
Begin
  Case (direction) Of
    NORTH,
      SOUTH:
      result := b[0].getY() < getWorld.getHeight() - 3;
  Else // WEST, EAST
    result := b[1].getX() < getWorld.getWidth() - 1;
  End;
End;

{ TTTetromino }

Constructor TTTetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited Create('brown', AOwner);
End;

Procedure TTTetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
Begin
  Inherited addedToWorld(World);
  direction := genDirection();
  start := genStartX();
  getWorld().addObject(b[0], start + 1, 0);
  getWorld().addObject(b[1], start, 1);
  getWorld().addObject(b[2], start + 1, 1);
  getWorld().addObject(b[3], start + 2, 1);
  setDirection();
End;

Function TTTetromino.genStartX(): integer;
Begin
  result := random(getWorld().getWidth() - 2);
End;

Procedure TTTetromino.setDirection();
Begin
  Case direction Of
    NORTH: Begin
        b[0].setLocation(b[2].getX(), b[2].getY() - 1);
        b[1].setLocation(b[2].getX() - 1, b[2].getY());
        b[3].setLocation(b[2].getX() + 1, b[2].getY());
      End;
    WEST: Begin
        b[0].setLocation(b[2].getX() - 1, b[2].getY());
        b[1].setLocation(b[2].getX(), b[2].getY() + 1);
        b[3].setLocation(b[2].getX(), b[2].getY() - 1);

      End;
    SOUTH: Begin
        b[0].setLocation(b[2].getX(), b[2].getY() + 1);
        b[1].setLocation(b[2].getX() + 1, b[2].getY());
        b[3].setLocation(b[2].getX() - 1, b[2].getY());
      End;
    EAST: Begin
        b[0].setLocation(b[2].getX() + 1, b[2].getY());
        b[1].setLocation(b[2].getX(), b[2].getY() - 1);
        b[3].setLocation(b[2].getX(), b[2].getY() + 1);
      End;
  End;
End;

Function TTTetromino.leftMost(): TBlock;
Begin
  Case direction Of
    NORTH: result := b[1];
    WEST: result := b[0];
    SOUTH: result := b[3];
  Else // case EAST:
    result := b[2];
  End;
End;

Function TTTetromino.rightMost(): TBlock;
Begin
  Case direction Of
    NORTH: result := b[3];
    WEST: result := b[2];
    SOUTH: result := b[1];
  Else // case EAST:
    result := b[0];
  End;
End;

Function TTTetromino.turnPossible(): boolean;
Begin
  Case direction Of
    NORTH: result := b[2].getY() < getworld.getHeight() - 3;
    WEST: result := b[2].getX() < getworld.getWidth() - 1;
    SOUTH: result := true;
  Else // case EAST:
    result := b[2].getX() >= 1;
  End;
End;

{ TOTetromino }

Constructor TOTetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited create('blue', AOwner);
End;

Procedure TOTetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
Begin
  Inherited addedToWorld(World);
  direction := NORTH;
  start := genStartX();
  getWorld().addObject(b[0], start, 0);
  getWorld().addObject(b[1], start + 1, 0);
  getWorld().addObject(b[2], start, 1);
  getWorld().addObject(b[3], start + 1, 1);
End;

Function TOTetromino.genStartX(): integer;
Begin
  result := random(getWorld().getWidth() - 1);
End;

Procedure TOTetromino.setDirection();
Begin
  // Nichts
End;

Function TOTetromino.leftMost(): TBlock;
Begin
  result := b[0];
End;

Function TOTetromino.rightMost(): TBlock;
Begin
  result := b[1];
End;

Function TOTetromino.turnPossible(): boolean;
Begin
  result := false;
End;

{ TLTetromino }

Constructor TLTetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited Create('magenta', AOwner);
End;

Procedure TLTetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
Begin
  Inherited addedToWorld(World);
  direction := genDirection();
  start := genStartX();
  getWorld().addObject(b[0], start + 2, 0);
  getWorld().addObject(b[1], start + 2, 1);
  getWorld().addObject(b[2], start + 1, 1);
  getWorld().addObject(b[3], start, 1);
  setDirection();
End;

Function TLTetromino.genStartX(): integer;
Begin
  result := random(getWorld().getWidth() - 2);
End;

Procedure TLTetromino.setDirection();
Begin
  Case direction Of
    NORTH: Begin
        b[0].setLocation(b[2].getX() + 1, b[2].getY() + 1);
        b[1].setLocation(b[2].getX(), b[2].getY() + 1);
        b[3].setLocation(b[2].getX(), b[2].getY() - 1);
      End;
    WEST: Begin
        b[0].setLocation(b[2].getX() + 1, b[2].getY() - 1);
        b[1].setLocation(b[2].getX() + 1, b[2].getY());
        b[3].setLocation(b[2].getX() - 1, b[2].getY());
      End;
    SOUTH: Begin
        b[0].setLocation(b[2].getX() - 1, b[2].getY() - 1);
        b[1].setLocation(b[2].getX(), b[2].getY() - 1);
        b[3].setLocation(b[2].getX(), b[2].getY() + 1);

      End;
    EAST: Begin
        b[0].setLocation(b[2].getX() - 1, b[2].getY() + 1);
        b[1].setLocation(b[2].getX() - 1, b[2].getY());
        b[3].setLocation(b[2].getX() + 1, b[2].getY());
      End;
  End;
End;

Function TLTetromino.leftMost(): TBlock;
Begin
  Case direction Of
    NORTH: result := b[2];
    WEST: result := b[3];
    SOUTH: result := b[0];
  Else // case EAST:
    result := b[0];
  End;
End;

Function TLTetromino.rightMost(): TBlock;
Begin
  Case direction Of
    NORTH: result := b[0];
    WEST: result := b[0];
    SOUTH: result := b[1];
  Else // case EAST:
    result := b[3];
  End;
End;

Function TLTetromino.turnPossible(): boolean;
Begin
  Case direction Of
    NORTH: result := b[2].getX() >= 1;
    WEST: result := b[2].getY() < getworld.getHeight() - 3;
    SOUTH: result := b[2].getX() < getworld.getWidth() - 1;
  Else // case EAST:
    result := true;
  End;
End;

{ TJTetromino }

Constructor TJTetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited create('yellow', AOwner);
End;

Procedure TJTetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
Begin
  Inherited addedToWorld(World);
  direction := genDirection();
  start := genStartX();
  getWorld().addObject(b[0], start, 0);
  getWorld().addObject(b[1], start, 1);
  getWorld().addObject(b[2], start + 1, 1);
  getWorld().addObject(b[3], start + 2, 1);
  setDirection();
End;

Function TJTetromino.genStartX(): integer;
Begin
  result := random(getWorld().getWidth() - 3) + 1;
End;

Procedure TJTetromino.setDirection();
Begin
  Case direction Of
    NORTH: Begin
        b[0].setLocation(b[2].getX() - 1, b[2].getY() + 1);
        b[1].setLocation(b[2].getX(), b[2].getY() + 1);
        b[3].setLocation(b[2].getX(), b[2].getY() - 1);
      End;
    WEST: Begin
        b[0].setLocation(b[2].getX() + 1, b[2].getY() + 1);
        b[1].setLocation(b[2].getX() + 1, b[2].getY());
        b[3].setLocation(b[2].getX() - 1, b[2].getY());
      End;
    SOUTH: Begin
        b[0].setLocation(b[2].getX() + 1, b[2].getY() - 1);
        b[1].setLocation(b[2].getX(), b[2].getY() - 1);
        b[3].setLocation(b[2].getX(), b[2].getY() + 1);
      End;
    EAST: Begin
        b[0].setLocation(b[2].getX() - 1, b[2].getY() - 1);
        b[1].setLocation(b[2].getX() - 1, b[2].getY());
        b[3].setLocation(b[2].getX() + 1, b[2].getY());
      End;
  End;
End;

Function TJTetromino.leftMost(): TBlock;
Begin
  Case direction Of
    NORTH: result := b[0];
    WEST: result := b[3];
    SOUTH: result := b[1];
  Else // case EAST:
    result := b[1];
  End;
End;

Function TJTetromino.rightMost(): TBlock;
Begin
  Case direction Of
    NORTH: result := b[1];
    WEST: result := b[1];
    SOUTH: result := b[0];
  Else // case EAST:
    result := b[3];
  End;
End;

Function TJTetromino.turnPossible(): boolean;
Var
  world: TWorld;
Begin
  world := getWorld();
  Case direction Of
    NORTH: result := b[2].getX() < world.getWidth() - 1;
    WEST: result := true;
    SOUTH: result := b[2].getX() > 0;
  Else
    result := b[2].getY() < world.getHeight() - 3; // case EAST:
  End;
End;
{ TZTetromino }

Constructor TZTetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited Create('cyan', AOwner);
End;

Procedure TZTetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
Begin
  Inherited addedToWorld(World);

  direction := genDirection();
  start := genStartX();
  getWorld().addObject(b[0], start, 1);
  getWorld().addObject(b[1], start + 1, 1);
  getWorld().addObject(b[2], start + 1, 2);
  getWorld().addObject(b[3], start + 2, 2);
  setDirection();

End;

Function TZTetromino.genStartX(): integer;
Begin
  result := random(getworld.getWidth() - 2);
End;

Procedure TZTetromino.setDirection();
Begin
  Case direction Of
    NORTH, SOUTH: Begin
        b[0].setLocation(b[1].getX() - 1, b[1].getY());
        b[2].setLocation(b[1].getX(), b[1].getY() + 1);
        b[3].setLocation(b[1].getX() + 1, b[1].getY() + 1);
      End;

    WEST, EAST: Begin
        b[0].setLocation(b[1].getX(), b[1].getY() - 1);
        b[2].setLocation(b[1].getX() - 1, b[1].getY());
        b[3].setLocation(b[1].getX() - 1, b[1].getY() + 1);
      End;
  End;
End;

Function TZTetromino.leftMost(): TBlock;
Begin
  Case direction Of
    NORTH, SOUTH: result := b[0];
  Else // WEST, EAST
    result := b[2];
  End;
End;

Function TZTetromino.rightMost(): TBlock;
Begin
  Case direction Of
    NORTH, SOUTH: result := b[3];
  Else // WEST, EAST
    result := b[1];
  End;
End;

Function TZTetromino.turnPossible(): boolean;
Var
  world: TWorld;
Begin
  world := getWorld();
  Case direction Of
    NORTH, SOUTH: result := b[2].getY() < world.getHeight() - 3;
  Else // WEST, EAST
    result := b[1].getX() < world.getWidth() - 1;
  End;
End;

{ TCounter }


Constructor TCounter.Create(prefix: String);
Begin
  Inherited Create;
  value := 0;
  text := prefix;
  textColor := black;
End;

Procedure TCounter.updateImage();
Var
  image: TGreenfootImage;
Begin
  image := getImage();
  image.clear();
  image.SetColor(black);
  image.drawString(text + inttostr(value), 10, 20);
End;

Procedure TCounter.addedToWorld(Const World: TWorld);
Var
  image: TGreenfootImage;
Begin
  Inherited addedToWorld(World);
  image := getImage();
  If Not assigned(image) Then Begin
    image := TGreenfootImage.Create(world.getWidth() * world.getCellSize(), world.getCellSize() * 2);
  End;
  setImage(image);
  image.setColor(textColor);
  //        Font font = image.getFont();
  //        font = font.deriveFont(24.0f);
  //        image.setFont(font);
  image.FontSize := 24;
  updateImage();
End;

Procedure TCounter.Add(apoints: integer);
Begin
  value := value + apoints;
  updateImage();
End;

Procedure TCounter.Subtract(apoints: integer);
Begin
  value := value - apoints;
  updateImage();
End;

Function TCounter.GetValue(): integer;
Begin
  result := value;
End;

{ TPoints }

Constructor TPoints.Create(aOwner: TTetrisWorld);
Begin
  counter := TCounter.create('');
  aOwner.addObject(counter, aOwner.getWidth Div 2, aOwner.getHeight() - 1);
End;

Procedure TPoints.Add(apoints: integer);
Begin
  counter.add(aPoints);
End;

Function TPoints.getPoints(): integer;
Begin
  result := counter.GetValue;
End;

{ TITetromino }

Constructor TITetromino.Create(AOwner: TTetrisWorld);
Begin
  Inherited Create('red', AOwner);
End;

Procedure TITetromino.addedToWorld(Const World: TWorld);
Var
  Start: integer;
  i: integer;
Begin
  Inherited addedToWorld(World);
  direction := genDirection();
  start := genStartX();
  For i := 0 To 3 Do Begin
    getWorld().addObject(b[i], start + i, 2);
  End;
  setDirection();
End;

Procedure TITetromino.setDirection();
Var
  i: Integer;
Begin
  Case direction Of
    NORTH, SOUTH: Begin
        For i := 0 To 3 Do Begin
          If i = 1 Then Continue;
          b[i].setLocation(b[1].getX(), b[1].getY() + 1 - i);
        End;
      End;
    WEST, EAST: Begin
        For i := 0 To 3 Do Begin
          If (i = 1) Then Continue;
          b[i].setLocation(b[1].getX() - 1 + i, b[1].getY());
        End;
      End;
  End;
End;

Function TITetromino.leftMost(): TBlock;
Begin
  result := b[0];
End;

Function TITetromino.rightMost(): TBlock;
Begin
  result := b[3];
End;

Function TITetromino.turnPossible(): boolean;
Begin
  Case direction Of
    NORTH, SOUTH: Begin
        result := (b[0].getx >= 1) And (b[3].getx() <= getWorld().getWidth() - 3);
      End
  Else Begin
      result := b[0].gety < getWorld().getHeight() - 3;
    End;
  End;
End;

Function TITetromino.genStartX(): integer;
Begin
  result := random(getWorld().getWidth() - 3);
End;

{ TTetromino }

Constructor TTetromino.Create(aColor: String; aOwner: TTetrisWorld);
Var
  i: integer;
Begin
  Inherited create();
  setImage('images' + PathDelim + 'tetris' + PathDelim + 'cell.png');
  setlength(B, 4);
  For i := 0 To 3 Do Begin
    b[i] := TBlock.Create(aColor);
  End;
  counter := 0;
  dead := false;
  aOwner.GetWorld.addObject(self, 0, aowner.getWorld().getHeight() - 1);
End;

// deletes the four blocks of a tetromino

Procedure TTetromino.Delete();
Var
  i: integer;
Begin
  // Todo: muss b[i] dann frei gegeben werden ?
  For i := 0 To 3 Do Begin
    getWorld().removeObject(b[i]);
  End;
  dead := true;
End;

// the current tetromino (more precisely its blocks) are falling down

Procedure TTetromino.act();
Var
  world: TTetrisWorld;
  keyAction: Boolean;
Begin
  Inherited act();

  world := getWorld() As TTetrisWorld;
  If (world.getCurrentTetromino() = Nil) Then Begin // game ended
    world.gameOver();
    exit
  End;

  If (dead) Then exit;

  // checking user interactions
  keyAction := false;
  If isKeyDown(key_left) And (counter < 4) Then Begin
    If (left()) Then Begin
      counter := counter + 1;
      keyAction := true;
    End;
  End;
  If isKeyDown(key_right) And (counter < 4) Then Begin
    If (Right()) Then Begin
      counter := counter + 1;
      keyAction := true;
    End;
  End;
  If isKeyDown(key_up) And (counter < 3) Then Begin
    If (turnLeft()) Then Begin
      counter := counter + 1;
      keyAction := true;
    End;
  End;
  If isKeyDown(key_down) Or isKeyDown(key_space) Then Begin
    down();
    exit;
  End;
  If keyAction Then exit;

  // one row down
  oneDown();
  counter := 0;
End;

// one column to the left

Function TTetromino.Left(): Boolean;
Var
  i: integer;
Begin
  If (leftOccupied()) Then exit(false);
  For i := 0 To 3 Do Begin
    b[i].setLocation(b[i].getX() - 1, b[i].getY());
  End;
  result := true;
End;

// left shift possible?

Function TTetromino.leftOccupied(): boolean;
Var
  world: TTetrisWorld;
  list: TActorList;
  i, j: Integer;
  a: TActor;
  blub: Boolean;
Begin
  If (leftMost().getX() = 0) Then Begin
    result := true;
    exit;
  End;
  world := getWorld() As TTetrisWorld;
  For i := 0 To 3 Do Begin
    list := world.getObjectsAt(b[i].getX() - 1, b[i].getY(), TBlock);
    If Not assigned(list) Then Begin
      continue;
    End;
    // then list.size() == 1
    a := list[0];
    blub := false;
    For j := 0 To 3 Do Begin
      If (i = j) Then Continue;
      If a = b[j] Then Begin
        blub := true;
        break;
      End;
    End;
    If blub Then Continue;
    exit(true);
  End;
  result := false;
End;

// one column to the right

Function TTetromino.Right(): Boolean;
Var
  i: Integer;
Begin
  If (rightOccupied()) Then exit(false);
  For i := 0 To 3 Do Begin
    b[i].setLocation(b[i].getX() + 1, b[i].getY());
  End;
  result := true;
End;

// right shif possible?

Function TTetromino.rightOccupied(): Boolean;
Var
  World: TWorld;
  list: TActorList;
  a: TActor;
  blub: Boolean;
  i, j: Integer;
Begin
  If (rightMost().getX() = getWorld().getWidth() - 1) Then Begin
    exit(true);
  End;
  world := getWorld();
  For i := 0 To 3 Do Begin
    list := world.getObjectsAt(b[i].getX() + 1, b[i].getY(), TBlock);
    If Not assigned(list) Then Continue;
    // then list.size() == 1
    a := list[0];
    blub := false;
    For j := 0 To 3 Do Begin
      If (i = j) Then Continue;
      If (a = b[j]) Then Begin
        blub := true;
        break;
      End;
    End;
    If blub Then Continue;
    exit(true);
  End;
  result := false;
End;

// change the direction of the tetromino

Function TTetromino.turnLeft(): Boolean;
Var
  oldDir, i: integer;
  world: TWorld;
  list: TActorList;
Begin
  If (Not turnPossible()) Then Begin
    exit(false);
  End;
  oldDir := direction;
  direction := (direction + 1) Mod 4;
  setDirection();
  world := getWorld();
  For i := 0 To 3 Do Begin
    list := world.getObjectsAt(b[i].getX(), b[i].getY(), Nil);
    If system.length(list) > 1 Then Begin
      direction := oldDir;
      setDirection();
      exit(false);
    End;
  End;
  result := true;
End;

// tetromino slides one row down

Function TTetromino.oneDown(): Boolean;
Var
  i: Integer;
Begin
  // checks whether the tetromino is on the bottom row
  For i := 0 To 3 Do Begin
    If (Not blockFree(i)) Then Begin
      CheckRows();
      die();
      exit(false);
    End;
  End;

  // falling down
  For i := 0 To 3 Do Begin
    b[i].setLocation(b[i].getX(), b[i].getY() + 1);
  End;
  result := true;
End;

// the tetromino is sliding to the bottom row

Procedure TTetromino.Down();
Begin
  While (oneDown()) Do Begin
  End;
End;

// is the cell below the block free?

Function TTetromino.blockFree(index: integer): boolean;
Var
  World: TWorld;
  list: TActorList;
  a: TActor;
  i: Integer;
Begin
  world := getWorld();
  list := world.getObjectsAt(b[index].getX(), b[index].getY() + 1, Nil);
  If Not assigned(list) Then Begin
    exit(true);
  End;
  // then list.size() == 1
  a := list[0];
  For i := 0 To 3 Do Begin
    If i = index Then Continue;
    If a = b[i] Then exit(True);
  End;
  result := false;
End;

// checks whether there exists completed rows which can be removed

Procedure TTetromino.CheckRows();
Var
  c, r, noOfRows: integer;
  World: TWorld;
  blocks: TActorList;
  blub: Boolean;
Begin
  noOfRows := 0;
  world := getWorld();
  r := world.getHeight() - 3;
  While r >= 0 Do Begin
    blub := true;
    For c := 0 To World.getWidth() - 1 Do Begin
      blocks := World.getObjectsAt(c, r, TBlock);
      If Not assigned(blocks) Then Begin
        blub := false;
        r := r - 1;
        break; // next row
      End;
    End;
    // clear row
    If blub Then Begin
      clearRow(r);
      noOfRows := noOfRows + 1;
      landslide(r);
    End;
  End;
  If (noOfRows > 0) Then Begin
    (world As TTetrisWorld).newPoints(noOfRows);
  End;
End;

// removes the blocks of a row

Procedure TTetromino.clearRow(row: integer);
Var
  world: TWorld;
  c: Integer;
Begin
  world := getWorld();
  For c := 0 To world.getWidth() - 1 Do Begin
    world.removeObjects(world.getObjectsAt(c, row, TBlock));
  End;
End;

// performs a "landslide"

Procedure TTetromino.landslide(row: integer);
Var
  world: TWorld;
  r, c: Integer;
  blocks: TActorList;
  block: TBlock;
Begin
  world := getWorld();
  For r := row - 1 Downto 0 Do Begin
    For c := 0 To world.getWidth() - 1 Do Begin
      blocks := world.getObjectsAt(c, r, TBlock);
      If assigned(blocks) Then Begin
        block := blocks[0] As TBlock;
        block.setLocation(block.getx(), block.gety() + 1);
      End;
    End;
  End;
End;

// kills the tetromino

Procedure TTetromino.Die();
Var
  world: TTetrisWorld;
  tetro: TTetromino;
Begin
  world := getWorld() As TTetrisWorld;
  world.removeObject(self);
  world.NewTilePlaced();
  dead := true;
  tetro := world.genTetromino();
  If (checkEnd(tetro)) Then Begin
    tetro.delete();
    world.setCurrentTetromino(Nil);
    world.gameOver();
  End
  Else Begin
    World.setCurrentTetromino(tetro);
  End;
End;

// checks whether the game has completed

Function TTetromino.CheckEnd(tetro: tTetromino): Boolean;
Var
  world: TWorld;
  list: TActorList;
  i: Integer;
Begin
  world := getWorld();
  For i := 0 To 3 Do Begin
    list := world.getObjectsAt(tetro.b[i].getx(), tetro.b[i].getY(), TBlock);
    If system.length(list) > 1 Then Begin
      result := true;
      exit;
    End;
  End;
  result := false;
End;

// generates a direction randomly

Function TTetromino.genDirection(): integer;
Begin
  result := random(4);
End;

// return the number of digits of a number

Function TTetromino.Length(Number: integer): Integer;
Begin
  result := system.length(inttostr(Number));
End;

{ TBlock }

Constructor TBlock.Create(aColor: String);
Begin
  Inherited create();
  setImage('images' + PathDelim + 'tetris' + PathDelim + aColor + '-block.png');
End;

{ TWall }

Constructor TWall.create();
Begin
  Inherited create();
  setImage('images' + PathDelim + 'tetris' + PathDelim + 'wall.png');
End;

{ TTetrisWorld }

Constructor TTetrisWorld.create(Parent: TOpenGLControl);
Var
  i: integer;
Begin
  Inherited Create(Parent, Cols, Rows + 2, 20, false);

  world := self;

  setBackground('images' + PathDelim + 'tetris' + PathDelim + 'cell.png');

  For i := 0 To cols - 1 Do Begin
    addObject(TWall.create(), i, rows);
  End;

  pointView := TPoints.Create(self);

  speed := 10;
  SetSpeed(speed, False);

  numberOfTetrominos := 0;
  currentTetromino := genTetromino();
End;

Destructor TTetrisWorld.destroy();
Begin
  pointView.Free;
  Inherited destroy();
End;

Function TTetrisWorld.GetWorld: TWorld;
Begin
  result := world;
End;

// returns the current tetromino or null if game terminated

Function TTetrisWorld.getCurrentTetromino(): TTetromino;
Begin
  result := currentTetromino;
End;

// changes the current tetromino

Procedure TTetrisWorld.setCurrentTetromino(t: TTetromino);
Begin
  currentTetromino := t;
End;

// creates randomly a new tetromino

Function TTetrisWorld.genTetromino(): TTetromino;
Begin
  numberOfTetrominos := numberOfTetrominos + 1;

  Case random(7) Of
    0: result := TITetromino.create(Self);
    1: result := TJTetromino.create(Self);
    2: result := TLTetromino.create(Self);
    3: result := TOTetromino.create(Self);
    4: result := TTTetromino.create(Self);
    5: result := TSTetromino.create(Self);
  Else
    result := TZTetromino.create(Self);
  End;
End;

// adds new points to the point view

Procedure TTetrisWorld.newPoints(rows: integer);
Var
  p: integer;
Begin
  p := 0;
  Case (rows) Of
    1: p := 40;
    2: p := 100;
    3: p := 300;
    4: p := 1200;
  End;
  pointView.add(p);
End;

Procedure TTetrisWorld.NewTilePlaced();
Begin
  pointView.add(5);
End;

// returns the current points of the player

Function TTetrisWorld.getPoints(): integer;
Begin
  result := pointView.getPoints();
End;

// game over

Procedure TTetrisWorld.GameOver();
Begin
  addObject(TScoreBoard.Create(getPoints()), getWidth() Div 2, getHeight() Div 2);
  stop();
End;

End.

