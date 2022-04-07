(*
 * This Unit is the Original Java to FreePascal translation from
 *
 * http://www.greenfoot.org/scenarios/486
 *
 *
 * Changelog : ver. 0.01 = 1:1 Translation
 *             ver. 0.02 = Minor Changes (e.g. Bugfix Creating a Leaf over a Stone )
 *
 *)
Unit uwombat;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  ugreenfoot, OpenGLContext;

Const
  EAST = 0;
  WEST = 1;
  NORTH = 2;
  SOUTH = 3;

Type

  { TRock }

  TRock = Class(TActor) // Müsste fertig sein.
  private
  public
    Constructor create(); override;
    Destructor destroy(); override;
  End;

  { TWombat }

  TWombat = Class(TActor) // Müsste fertig sein.
  private
    direction: integer;
    leavesEaten: integer;
    wombatRight: TGreenfootImage;
    wombatLeft: TGreenfootImage;
  public
    Constructor Create(); override;
    Function foundLeaf(): Boolean;
    Procedure EatLeaf(); virtual;
    Function canMove(): Boolean;
    Procedure Move();
    Procedure Act(); override;
    Procedure TurnRandom();
    Procedure TurnLeft();
    Procedure SetDirection(direction_: integer);
    Function gotSheep(): Boolean;
    Function getLeavesEaten(): integer;
  End;

  { TLeaf }

  TLeaf = Class(TActor) // Müsste fertig sein.
  private
  public
    Constructor create(); override;
    Function isIntersecting: Boolean;
  End;

  { TSheep }

  TSheep = Class(TWombat) // Müsste fertig sein.
  private
    Procedure getDirection();
  public
    Constructor create(); override;
    Procedure act(); override;
    Procedure Move();
    Procedure EatLeaf(); override;
  End;

  { TCounter }

  TCounter = Class(TActor) // Müsste fertig sein.
  private
    value: integer;
    target: integer;
    text: String;
    Procedure updateImage();
  public
    Constructor Create(); override;
    Constructor Create(prefix: String);
    Destructor destroy(); override;
    Procedure Add(Score: integer);
    Procedure Subtract(Score: integer);
    Function getValue(): integer;
    Procedure Act(); override;
  End;

  { TScoreBoard }

  TScoreBoard = Class(TActor) // Müsste fertig sein.
  private
    Font_Size: integer;
    width: integer;
    height: Integer;
    Procedure makeImage(Title, Prefix: String; Score: integer);
    Procedure maketxt(txt: String);
  public
    Constructor Create(); override;
    Constructor Create(score: integer);
    Constructor Create(txt: String);
    Destructor destroy(); override;
  End;

  { TWombatWorld }

  TWombatWorld = Class(TWorld) // Müsste fertig sein.
  private
    isnewLevel: Boolean;
    level: integer;
    Sheep: TSheep;
    Counter: TCounter;
  public
    Constructor create(Parent: TOpenGLControl);
    Procedure Populate();
    Procedure randomLeaves(howMany: integer);
    Procedure countLeaves();
    Procedure gameOver();
    Procedure nextLevel();
    Procedure checkLevel();
  End;

Implementation

{ TWombat }

Constructor TWombat.Create;
Begin
  Inherited Create;
  If GreenFootGraphicEngine.FindImage('WombatLeft') = Nil Then Begin
    setimage('images' + PathDelim + 'wombat.png');
    wombatRight := getImage();
    wombatLeft := TGreenfootImage.Create(getImage());
    wombatLeft.mirrorHorizontally();
    GreenFootGraphicEngine.AddImage(wombatLeft, 'WombatLeft');
    GreenFootGraphicEngine.AddImage(wombatRight, 'WombatRight');
  End
  Else Begin
    wombatLeft := GreenFootGraphicEngine.FindImage('WombatLeft');
    wombatRight := GreenFootGraphicEngine.FindImage('WombatRight');
  End;
  SetDirection(EAST);
  leavesEaten := 0;
End;

Function TWombat.foundLeaf: Boolean;
Var
  leaf: TActor;
Begin
  leaf := getOneObjectAtOffset(0, 0, TLeaf);
  result := assigned(leaf);
End;

Procedure TWombat.EatLeaf;
Var
  leaf2: TLeaf;
  leaf: TActor;
  sheep: TActor;
  freePlaceFound: Boolean;
  x, y: integer;
Begin
  leaf := getOneObjectAtOffset(0, 0, TLeaf);
  sheep := getOneObjectAtOffset(0, 0, TSheep);
  freePlaceFound := false;
  If assigned(leaf) Then Begin
    // eat the leaf...
    getWorld().removeObject(leaf);
    leavesEaten := leavesEaten + 1;
    If assigned(sheep) Then Begin
      TWombatWorld(getWorld()).countLeaves();
    End;
  End;
  While (Not freePlaceFound) Do Begin
    leaf2 := tLeaf.create();
    x := getRandomNumber(10);
    y := getRandomNumber(10);
    getWorld().addObject(leaf2, x, y);
    If (Not leaf2.isIntersecting()) Then Begin
      freePlaceFound := true;
    End
    Else
      getWorld().removeObject(leaf2); // Im Original stand hier leaf, aber das würde ja gar keinen Sinn machen..
  End;
End;

(**
 * Test if we can move forward. Return true if we can, false otherwise.
 *)

Function TWombat.canMove: Boolean;
Var
  myWorld: TWorld;
  x, y: integer;
  rocks: TActorList;
Begin
  myWorld := getWorld();
  x := getX();
  y := getY();
  Case (direction) Of
    SOUTH: y := y + 1;
    EAST: x := x + 1;
    NORTH: y := y - 1;
    WEST: x := x - 1;
  End;
  // test for outside border
  If ((x >= myWorld.getWidth()) Or (y >= myWorld.getHeight())) Then Begin
    result := false;
    exit;
  End
  Else Begin
    If ((x < 0) Or (y < 0)) Then Begin
      result := false;
      exit;
    End;
    rocks := myWorld.getObjectsAt(x, y, TRock);
    result := Not assigned(rocks);
  End;
End;

(**
 * Move one cell forward in the current direction.
 *)

Procedure TWombat.Move;
Begin
  If Not canMove() Then exit;
  Case direction Of
    south: setLocation(getx(), gety() + 1);
    EAST: setLocation(getx() + 1, gety());
    NORTH: setLocation(getx(), gety() - 1);
    WEST: setLocation(getx() - 1, gety());
  End;
End;

Procedure TWombat.Act;
Begin
  gotSheep();
  If (foundLeaf()) Then Begin
    eatLeaf();
  End
  Else Begin
    If (canMove()) Then Begin
      move();
    End
    Else Begin
      turnRandom();
    End;
  End;
End;

(**
 * Turn in a random direction.
 *)

Procedure TWombat.TurnRandom;
Var
  turns, i: integer;
Begin
  // get a random number between 0 and 3...
  turns := getRandomNumber(4);

  // ...an turn left that many times.
  For i := 0 To turns - 1 Do Begin
    turnLeft();
  End;
End;

Procedure TWombat.TurnLeft;
Begin
  Case (direction) Of
    SOUTH: setDirection(EAST);
    EAST: setDirection(NORTH);
    NORTH: setDirection(WEST);
    WEST: setDirection(SOUTH);
  End;
End;

Procedure TWombat.SetDirection(direction_: integer);
Begin
  direction := direction_;
  Case (direction) Of
    SOUTH: Begin
        setImage(wombatRight);
        setRotation(90);
      End;
    EAST: Begin
        setImage(wombatRight);
        setRotation(0);
      End;
    NORTH: Begin
        setImage(wombatLeft);
        setRotation(90);
      End;
    WEST: Begin
        setImage(wombatLeft);
        setRotation(0);
      End;
  End;
End;

(**
 * Check whether a wombat has got the sheep.
 *)

Function TWombat.gotSheep: Boolean;
Var
  found: Boolean;
  dx, dy: integer;
  sheep: Tactor;
Begin
  found := false;
  dx := 0;
  dy := 0;
  Case (direction) Of
    SOUTH: dy := 1;
    EAST: dx := 1;
    NORTH: dy := -1;
    WEST: dx := -1;
  End;
  sheep := getOneObjectAtOffset(dx, dy, TSheep);
  If assigned(sheep) Then Begin
    found := true;
  End
  Else
    sheep := getOneObjectAtOffset(0, 0, TSheep);
  If assigned(sheep) Then found := true;
  If (found) Then Begin
    getWorld().removeObject(sheep);
    //getWorld().addObject(new Explosion(), getX(), getY());
    TWombatWorld(getWorld()).gameOver();
  End;
  result := found;
End;

Function TWombat.getLeavesEaten: integer;
Begin
  result := leavesEaten;
End;

{ TRock }

Constructor TRock.create;
Begin
  Inherited create;
  setimage('images' + PathDelim + 'rock.png');
End;

Destructor TRock.destroy;
Begin
  getImage().free;
  Inherited destroy;
End;

{ TLeaf }

Constructor TLeaf.create;
Begin
  Inherited create;
  If GreenFootGraphicEngine.FindImage('Leaf') = Nil Then Begin
    setImage('images' + PathDelim + 'leaf.png');
    GreenFootGraphicEngine.AddImage(getImage(), 'Leaf');
  End
  Else Begin
    setImage(GreenFootGraphicEngine.FindImage('Leaf'));
  End;
End;

(*
 * Tells wheter there the leave is somewhere where ther is also a rock
 *)

Function TLeaf.isIntersecting: Boolean;
Var
  rock: TActor;
Begin
  rock := getOneObjectAtOffset(0, 0, TRock);
  result := assigned(rock);
End;

{ TSheep }

Constructor TSheep.create;
Begin
  Inherited create;
  setimage('images' + PathDelim + 'sheep.png');
  wombatRight := getImage();
  wombatLeft := TGreenfootImage.Create(getImage());
  wombatLeft.mirrorHorizontally();
  GreenFootGraphicEngine.AddImage(wombatLeft, 'Sheepleft');
  GreenFootGraphicEngine.AddImage(wombatRight, 'SheepRight');
End;

Procedure TSheep.act;
Var
  x, y: integer;
  leaf: TLeaf;
  b: boolean;
Begin
  If (foundLeaf()) Then Begin
    eatLeaf();
    b := true;
    While b Do Begin
      x := getRandomNumber(10);
      y := getRandomNumber(10);
      leaf := TLeaf.create();
      getWorld().addObject(leaf, x, y);
      If leaf.isIntersecting Then Begin
        getworld().removeObject(leaf);
      End
      Else Begin
        b := false;
      End;
    End;
  End
  Else Begin
    If (canMove()) Then Begin
      move();
    End
    Else Begin
      turnRandom();
    End;
  End;
  TWombatWorld(getWorld()).checkLevel();
End;

Procedure TSheep.Move;
Begin
  getDirection();
  setDirection(direction);
  If (Not canMove()) Then Begin
    exit;
  End
  Else Begin
    Case (direction) Of
      SOUTH: setLocation(getX(), getY() + 1);
      EAST: setLocation(getX() + 1, getY());
      NORTH: setLocation(getX(), getY() - 1);
      WEST: setLocation(getX() - 1, getY());
    End;
  End;
End;

Procedure TSheep.EatLeaf;
Var
  leaf: TActor;
Begin
  leaf := getOneObjectAtOffset(0, 0, TLeaf);
  If assigned(leaf) Then Begin
    // eat the leaf...
    getWorld().removeObject(leaf);
    leavesEaten := leavesEaten + 1;
    TWombatWorld(getWorld()).countLeaves();
  End;
End;

Procedure TSheep.getDirection;
Begin
  If (isKeyDown('up')) Or (isKeyDown('w')) Then direction := NORTH;
  If (isKeyDown('down')) Or (isKeyDown('s')) Then direction := SOUTH;
  If (isKeyDown('right')) Or (isKeyDown('d')) Then direction := EAST;
  If (isKeyDown('left')) Or (isKeyDown('a')) Then direction := WEST;
End;

{ TScoreBoard }

Constructor TScoreBoard.Create;
Begin
  Create(100);
End;

Constructor TScoreBoard.Create(score: integer);
Begin
  Inherited Create;
  Font_Size := 48;
  width := 400;
  height := 300;
  makeImage('Game Over', 'Score: ', score);
End;

Constructor TScoreBoard.Create(txt: String);
Begin
  Inherited Create;
  Font_Size := 48;
  width := 400;
  height := 300;
  maketxt(txt);
End;

Destructor TScoreBoard.destroy;
Begin
  getimage().free;
  Inherited destroy;
End;

Procedure TScoreBoard.makeImage(Title, Prefix: String; Score: integer);
Var
  image: TGreenfootImage;
Begin
  image := TGreenfootImage.create(WIDTH, HEIGHT);
  image.setColor(Color(0, 0, 0, 160));
  image.fillRect(0, 0, WIDTH, HEIGHT);
  image.setColor(Color(255, 255, 255, 100));
  image.fillRect(5, 5, WIDTH - 10, HEIGHT - 10);
  image.FontSize := FONT_SIZE;
  image.setColor(Black);
  image.drawString(title, 60, 100);
  image.drawString(prefix + inttostr(score), 60, 200);
  setImage(image);
End;

Procedure TScoreBoard.maketxt(txt: String);
Var
  image: TGreenfootImage;
Begin
  image := tGreenfootImage.create(WIDTH, HEIGHT);
  image.setColor(Color(0, 0, 0, 160));
  image.fillRect(0, 0, WIDTH, HEIGHT);
  image.setColor(Color(255, 255, 255, 100));
  image.fillRect(5, 5, WIDTH - 10, HEIGHT - 10);
  image.FontSize := FONT_SIZE;
  image.setColor(WHITE);
  image.drawString(txt, 60, 100);
  setImage(image);
End;

{ TCounter }

Constructor TCounter.Create;
Begin
  Create('');
End;

Constructor TCounter.Create(prefix: String);
Var
  stringlength: integer;
  image: TGreenfootImage;
Begin
  Inherited Create;
  value := 0;
  target := 0;
  text := prefix;
  stringLength := (length(text) + 2) * round(8 * 16 / 12);
  image := TGreenfootImage.create(stringLength, 24);
  image.FontSize := 16;
  setImage(image);
  updateImage();
End;

Destructor TCounter.destroy;
Begin
  getimage().free;
  Inherited destroy;
End;

(**
 * Make the image
 *)

Procedure TCounter.updateImage;
Var
  image: TGreenfootImage;
Begin
  image := getImage();
  image.clear();
  image.SetColor(BLACK);
  image.drawString(text + inttostr(value), 1, 18);
End;

Procedure TCounter.Add(Score: integer);
Begin
  target := target + score;
End;

Procedure TCounter.Subtract(Score: integer);
Begin
  target := target - score;
End;

Function TCounter.getValue: integer;
Begin
  result := value;
End;

Procedure TCounter.Act;
Begin
  If (value < target) Then Begin
    value := value + 1;
    updateImage();
  End
  Else Begin
    If (value > target) Then Begin
      value := value - 1;
      updateImage();
    End;
  End;
End;

{ TWombatWorld }

(**
 * Create a new world with 8x8 cells and
 * with a cell size of 60x60 pixels
 *)

Constructor TWombatWorld.create(Parent: TOpenGLControl);
Begin
  Inherited create(parent, 10, 10, 60);
  setBackground('images' + PathDelim + 'cell.png');
  isNewLevel := true;
  level := 0;
  sheep := TSheep.create;
  Counter := TCounter.Create('Score: ');
  populate();
  SetSpeed(4);
  setPaintOrder([TScoreBoard, TCounter, TSheep]);
End;

(**
 * Populate the world with a fixed scenario of wombats and leaves.
 *)

Procedure TWombatWorld.Populate;
Var
  x, y: integer;
  rock, rock2: TRock;
  Wombat: TWombat;
  l1: TLeaf;
Begin
  Repeat
    x := getRandomNumber(10);
    y := getRandomNumber(10);
    // Verhindern das Stein auf Stein, oder Wombat auf Stein erzeugt wird.
  Until Not (((x = 0) And (y = 1)) Or ((x = 0) And (y = 9)));
  rock := tRock.create();
  addObject(rock, 0, y);
  rock2 := tRock.create();
  addObject(rock2, x, 9);
  wombat := tWombat.create();
  addObject(wombat, x, 1);
  l1 := tLeaf.create();
  addObject(l1, 5, 3);
  addObject(counter, 8, 9);
  addObject(sheep, 2, 5);
End;

(**
 * Place a number of leaves into the world at random places.
 * The number of leaves can be specified.
 *)

Procedure TWombatWorld.randomLeaves(howMany: integer);
Var
  x, y, i: Integer;
  leaf: TLeaf;
Begin
  // Wird nie aufgerufen, braucht also auch nicht Gebugfixes werden.
  Raise exception.create('Fix mich, auf dass ich blätter erzeuge die nicht überlappen.');
  For i := 0 To howMany - 1 Do Begin
    leaf := TLeaf.create();
    x := getRandomNumber(getWidth());
    y := getRandomNumber(getHeight());
    addObject(leaf, x, y);
  End;
End;

(**
 * Count leaves eaten by sheep
 *)

Procedure TWombatWorld.countLeaves;
Begin
  Counter.add(1);
End;

(**
 * Called when game is up. Stop running and display score.
 *)

Procedure TWombatWorld.gameOver;
Begin
  addObject(TScoreBoard.create(counter.getValue()), getWidth() Div 2, getHeight() Div 2);
  playSound('sounds' + PathDelim + 'buzz.wav');
  Stop();
End;

(**
 * Called when next level ist reached.
 *)

Procedure TWombatWorld.nextLevel;
Begin
  level := level + 1;
End;

Procedure TWombatWorld.checkLevel;
Var
  x, y: integer;
  freePlaceFound: Boolean;
  leaf: TLEaf;
Begin
  If ((sheep.leavesEaten Mod 5 = 0) And (Not isNewLevel)) Then Begin
    If (sheep.leavesEaten Mod 15 = 0) Then Begin
      x := getRandomNumber(10);
      y := getRandomNumber(10);
      addObject(TWombat.create(), x, y);
    End;
    x := getRandomNumber(10);
    y := getRandomNumber(10);
    addObject(TRock.create(), x, y);
    If (sheep.leavesEaten Mod 5 = 0) Then Begin
      freePlaceFound := false;
      While (Not freePlaceFound) Do Begin
        leaf := tLeaf.create();
        x := getRandomNumber(10);
        y := getRandomNumber(10);
        addObject(leaf, x, y);
        If (Not leaf.isIntersecting()) Then Begin
          freePlaceFound := true;
        End
        Else Begin
          removeObject(leaf);
        End;
      End;
    End;
    nextLevel();
    isNewLevel := true;
  End;
  If (sheep.leavesEaten Mod 5 = 1) Then isNewLevel := false;
End;

End.

