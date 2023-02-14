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
(*
 * This Unit is the Original Java to FreePascal translation from
 *
 * http://www.greenfoot.org/scenarios/7997
 *
 *
 * Changelog : ver. 0.01 = 1:1 Translation
 *             ver. 0.02 = Minor Changes
 *
 *)
Unit uprimesnake;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  classes,
  ugreenfoot, OpenGLContext;

Type

  { TLocation }

  TLocation = Class
  private
    fx, fy: integer;
  public
    Constructor create(x, y: integer);
    Function getx(): integer;
    Function gety(): integer;
    Procedure Setxy(x, y: integer);
  End;

  TLocationList = Array Of TLocation;

  { TFood }

  TFood = Class(TActor)
  private
    flash: boolean;
  public
    Constructor create(); override;
    Procedure Act(); override;
  End;

  { TFood2 }

  TFood2 = Class(TActor)
  private
    flash: boolean;
  public
    Constructor create(); override;
    Procedure Act(); override;
  End;

  { TWall }

  TWall = Class(TActor)
  private
  public
    Constructor create(); override;
  End;

  { TNum }

  TNum = Class(TActor)
  private
    flash: Boolean;
  public
    Constructor create(); override;
    Destructor destroy; override;
    Procedure Act(); override;
  End;

  { TSnake }

  TSnake = Class(TActor) // Müsste fertig sein.
  private
    locations: TLocationList;
    direction: integer;
    dead: boolean;
    Procedure ShowNote(st: String);
    Procedure DeadSnake();
  public
    Constructor create(); override;
    Constructor create(locations_: TLocationList);
    Destructor destroy(); override;
    Procedure Act(); override;
  End;

  { TSnakeBody }

  TSnakeBody = Class(TActor)
  private
    x, y: integer;
    number: integer;
    locations: TLocationList;
    dead: Boolean;
  public
    Constructor create(); override;
    Constructor create(locations_: TLocationList; number_: integer);
    Destructor destroy(); override;
    Procedure Act(); override;
  End;

  { TSnakeWorld }

  TSnakeWorld = Class(TWorld) // Müsste fertig sein.
  private
    SnakeLength: integer;
    LocationLen: integer;
    Locations: TLocationList;
    bodyPos: Array[0..25, 0..19] Of integer;
    num: TNum;
    food: TFood;
    food2: TFood2;
    level: integer;
    //step: Integer;
    Procedure StartLocation();
    Procedure Shuffle();
    Procedure increaseSnakeLength();
  public
    Constructor create(Parent: TOpenGLControl);
    Destructor destroy(); override;
  End;

Const
  primes: Array[0..24] Of integer = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97);
  nonPrimes: Array[0..24] Of integer = (1, 1, 27, 9, 15, 39, 39, 49, 49, 51, 51, 51, 51, 57, 57, 57, 63, 69, 81, 87, 87, 87, 91, 93, 95);

Implementation

{ TFood2 }

Constructor TFood2.create;
Begin
  Inherited create;
End;

Procedure TFood2.Act;
Var
  P: integer;
  image: TGreenfootImage;
  sp: String;
Begin
  If Not (flash) Then Begin
    p := nonPrimes[TSnakeWorld(getWorld()).level - 1];
    image := GreenFootGraphicEngine.FindImage('prime' + IntToStr(p));
    If Not assigned(image) Then Begin
      image := TGreenfootImage.Create(25, 25);
      image.BeginUpdate();
      image.clear();
      image.SetColor(magenta);
      image.fillRect(0, 0, 25, 25);
      image.SetColor(black);
      image.FontSize := 16;
      If p < 10 Then
        sp := ' ' + inttostr(p)
      Else
        sp := IntToStr(p);
      image.drawString(sp, 2, 18);
      image.EndUpdate();
    End;
    setImage(image);
    flash := true;
  End;
End;

{ TNum }

Constructor TNum.create;
Begin
  Inherited create;
  flash := false;
End;

Destructor TNum.destroy;
Var
  img: TGreenfootImage;
Begin
  img := getImage();
  If assigned(img) Then
    img.free;
  Inherited destroy;
End;

Procedure TNum.Act;
Var
  myImage: TGreenfootImage;
  text: String;
  th: integer;
Begin
  If Not flash Then Begin
    myImage := getImage();
    If assigned(myImage) Then myImage.free;
    text := inttostr(TSnakeWorld(getWorld()).level);
    th := 25; // die Angestrebte Fontsize
    myImage := TGreenfootImage.Create(round((length(text) + 1) * 8 * th / 12), 42);
    myImage.BeginUpdate();
    myImage.SetColor(color(249, 222, 167));
    myImage.fillRect(0, 0, myImage.GetWidth - 1, myImage.GetHeight - 1);
    myImage.SetColor(magenta);
    myImage.FontSize := th;
    myImage.drawString(text, 3, 23);
    myImage.EndUpdate();
    setImage(myImage);
    flash := true;
  End;
End;

{ TFood }

Constructor TFood.create;
Begin
  Inherited create;
  flash := false;
End;

Procedure TFood.Act;
Var
  P: integer;
  image: TGreenfootImage;
  sp: String;
Begin
  If Not (flash) Then Begin
    p := primes[TSnakeWorld(getWorld()).level - 1];
    image := GreenFootGraphicEngine.FindImage('prime' + IntToStr(p));
    If Not assigned(image) Then Begin
      image := TGreenfootImage.Create(25, 25);
      image.BeginUpdate();
      image.clear();
      image.SetColor(magenta);
      image.fillRect(0, 0, 25, 25);
      image.SetColor(black);
      image.FontSize := 16;
      If p < 10 Then
        sp := ' ' + inttostr(p)
      Else
        sp := IntToStr(p);
      image.drawString(sp, 2, 18);
      image.EndUpdate();
    End;
    setImage(image);
    flash := true;
  End;
End;

{ TWall }

Constructor TWall.create;
Var
  image: TGreenfootImage;
Begin
  Inherited create;
  image := GreenFootGraphicEngine.FindImage('swall.png');
  If Not assigned(image) Then Begin
    image := TGreenfootImage.Create('images' + PathDelim + 'swall.png');
    GreenFootGraphicEngine.AddImage(image, 'swall.png');
  End;
  setImage(image);
End;

{ TSnakeBody }

Constructor TSnakeBody.create;
Begin
  create(Nil, 0);
End;

Constructor TSnakeBody.create(locations_: TLocationList; number_: integer);
Var
  image: TGreenfootImage;
Begin
  Inherited create;
  locations := locations_;
  number := number_;
  image := GreenFootGraphicEngine.FindImage('sskin0.png');
  If Not assigned(image) Then Begin
    image := TGreenfootImage.Create('images' + PathDelim + 'sskin0.png');
    GreenFootGraphicEngine.AddImage(image, 'sskin0.png');
  End;
  setImage(image);
  dead := false;
End;

Destructor TSnakeBody.destroy;
Begin
  Inherited destroy;
End;

Procedure TSnakeBody.Act;
Begin
  x := locations[number].getX();
  y := locations[number].getY();
  (*if (number == 0) {
      GreenfootImage myImage = getImage();
      GreenfootImage textImage = new GreenfootImage("Ｐ", 32, Color.BLACK, Color.lightGray);
      myImage.drawImage(textImage, 0, 0);
      MyWorld.bodyPos[y][x] = 0 ;
  }*)
  setLocation(x, y);
  //System.out.println(number + " : " +x+" , "+y) ;
  If (dead) Then Begin
    //World w = getWorld() ;
    //SnakeBody body = w.getObjects(locations.get(0));
    setImage('head0e.png');
  End;
End;

{ TLocation }

Constructor TLocation.create(x, y: integer);
Begin
  Inherited create;
  Setxy(x, y);
End;

Function TLocation.getx: integer;
Begin
  result := fx;
End;

Function TLocation.gety: integer;
Begin
  result := fy;
End;

Procedure TLocation.Setxy(x, y: integer);
Begin
  fx := x;
  fy := y;
End;

{ TSnake }

Procedure TSnake.ShowNote(st: String);
Var
  w: Tworld;
  bg: TGreenfootImage;
Begin
  w := getWorld();
  bg := w.getBackground();
  //        float fontSize = 36.0f;
  //        Font font = bg.getFont();   //改用36點字
  //        font = font.deriveFont(fontSize);
  //        bg.setFont(font);
  bg.FontSize := 36;
  bg.BeginUpdate();
  bg.drawString('You', 655, 170);
  bg.drawString(st, 655, 210);
  bg.EndUpdate();
End;

Procedure TSnake.DeadSnake;
//Var
//  world: TWorld;
//  x, y: integer;
Begin
  setImage('images' + PathDelim + 'shead0dead.png');
  playSound('sounds' + PathDelim + 'fail.wav');
  dead := true;
  //world := getWorld();
  //x := getX();
  //y := getY();

  //  world.removeObject(self);
  //  world.addObject(TSnake.create(), x, y);

  showNote('Lost');
  stop();
End;

Constructor TSnake.create;
Begin
  create(Nil);
End;

Constructor TSnake.create(locations_: TLocationList);
Begin
  Inherited create();
  locations := locations_;
  setimage('images' + PathDelim + 'shead0.png');
  dead := false;
End;

Destructor TSnake.destroy;
Begin
  Inherited destroy;
End;

Procedure TSnake.Act;
Var
  x: Integer;
  y: Integer;
  i: Integer;
  snakeBody_, wall_, food_, food2_: TActor;
  myWorld: TSnakeWorld;
Begin
  If dead Then exit;
  If (isKeyDown('up') And (direction <> 3)) Then Begin
    direction := 1;
    setRotation(-90);
  End;
  If (isKeyDown('down') And (direction <> 1)) Then Begin
    direction := 3;
    setRotation(90);
  End;
  If (isKeyDown('right') And (direction <> 2)) Then Begin
    direction := 0;
    setRotation(0);
  End;
  If (isKeyDown('left') And (direction <> 0)) Then Begin
    direction := 2;
    setRotation(180);
  End;
  myWorld := TSnakeWorld(getWorld());
  // locations.remove(0);
  For i := 1 To myWorld.LocationLen - 1 Do Begin
    locations[i - 1].Setxy(locations[i].getx(), locations[i].gety());
  End;
  x := getX();
  y := getY();
  //        locations.add(new Location(x,y));
  locations[myWorld.LocationLen - 1].Setxy(x, y);

  If (direction = 0) Then Begin
    setLocation(x + 1, y);
    MyWorld.bodyPos[y][x + 1] := 1;
  End
  Else Begin
    If (direction = 1) Then Begin
      setLocation(x, y - 1);
      MyWorld.bodyPos[y - 1][x] := 1;
    End
    Else Begin
      If (direction = 2) Then Begin
        setLocation(x - 1, y);
        MyWorld.bodyPos[y][x - 1] := 1;
      End
      Else Begin
        setLocation(x, y + 1);
        MyWorld.bodyPos[y + 1][x] := 1;
      End;
    End;
  End;
  food_ := getOneIntersectingObject(TFood);

  If assigned(food_) Then Begin
    playSound('sounds' + PathDelim + 'eat.wav');
    myWorld := TSnakeWorld(getWorld());

    //Diese Routine Killt alles

    myWorld.increaseSnakeLength();
    myWorld.increaseSnakeLength();
    //            World w = getWorld() ;
    MyWorld.bodyPos[y][x] := 0;
    myWorld.removeObject(food_);

    Repeat
      x := getRandomNumber(23) + 1;
      y := getRandomNumber(15) + 1;
    Until (MyWorld.bodyPos[y][x] <> 1);
    MyWorld.bodyPos[y][x] := 1;
    MyWorld.food := TFood.create();
    MyWorld.addObject(MyWorld.food, x, y);
    MyWorld.removeObjects(MyWorld.getObjects(TFood2)); // Die Nicht Primzahlen Löschen
    Repeat
      x := getRandomNumber(23) + 1;
      y := getRandomNumber(15) + 1;
    Until (MyWorld.bodyPos[y][x] <> 1);
    MyWorld.food2 := TFood2.create();
    MyWorld.addObject(MyWorld.food2, x, y);
    If (MyWorld.level = 25) Then Begin
      // playSound("cheers.wav");
      showNote('Win');
      stop();
    End;
    MyWorld.level := MyWorld.level + 1;
    MyWorld.Num.flash := false;
    MyWorld.Food.flash := false;
    MyWorld.Food2.flash := false;
  End;
  food2_ := getOneIntersectingObject(TFood2);
  wall_ := getOneIntersectingObject(TWall);
  snakeBody_ := getOneIntersectingObject(TSnakeBody);

  If assigned(snakeBody_) Or assigned(food2_) Or assigned(wall_) Then Begin
    deadSnake();

  End;
End;

{ TSnakeWorld }

Procedure TSnakeWorld.StartLocation;
Var
  x, y: integer;
  i: Integer;
  bg: TGreenfootImage;
Begin
  x := getRandomNumber(10) + 7;
  y := getRandomNumber(5) + 6;
  Locations[0] := TLocation.create(x, y);
  Locations[1] := TLocation.create(x, y);
  LocationLen := 2;
  addObject(TSnake.create(Locations), x + 1, y);
  bodyPos[y][x + 1] := 1;
  SnakeLength := 3;
  For i := 0 To SnakeLength - 2 Do Begin
    addObject(TSnakeBody.create(locations, i), x - i, y);
    bodyPos[y][x - i] := 1;
  End;

  For i := 0 To 18 - 1 Do Begin
    addObject(tWall.create(), 25, i);
    addObject(TWall.create(), 0, i);
  End;
  For i := 1 To 26 - 1 Do Begin
    addObject(tWall.create(), i, 0);
    addObject(tWall.create(), i, 17);
  End;

  Repeat
    x := getRandomNumber(23) + 1;
    y := getRandomNumber(15) + 1;
  Until (bodyPos[y][x] <> 1);
  bodyPos[y][x] := 1;

  food := TFood.create();
  addObject(food, x, y);

  Repeat
    x := getRandomNumber(23) + 1;
    y := getRandomNumber(15) + 1;
  Until (bodyPos[y][x] <> 1);
  bodyPos[y][x] := 1;
  food2 := TFood2.create();
  addObject(Food2, x, y);

  shuffle();
  level := 1;
  Food.flash := false;
  Food2.flash := false;
  Num.flash := false;

  bg := getBackground();
  bg.setColor(BLACK);
  bg.FontSize := 11;
  bg.drawString('Eat number', 660, 40);
  bg.drawString('of primes :', 660, 60);
  addObject(num, 28, 3);
  bg.FontSize := 17;
  bg.setColor(RED);
  bg.drawString('Note:', 660, 290);
  bg.setColor(BLUE);
  bg.drawString('Snakes ', 660, 320);
  bg.drawString(' like', 660, 350);
  bg.drawString(' to eat', 660, 380);
  bg.drawString(' prime.', 660, 410);
End;

Procedure TSnakeWorld.Shuffle;
Var
  i, t, temp1: integer;
Begin
  For i := 0 To 25 - 1 Do Begin
    t := getRandomNumber(25);
    temp1 := primes[i];
    primes[i] := primes[t];
    primes[t] := temp1;
    t := getRandomNumber(25);
    temp1 := nonPrimes[i];
    nonPrimes[i] := nonPrimes[t];
    nonPrimes[t] := temp1;
  End;
End;

Procedure TSnakeWorld.increaseSnakeLength;
Var
  x, y: integer;
Begin
  SnakeLength := SnakeLength + 1;
  x := locations[LocationLen - 1].getX();
  y := locations[LocationLen - 1].gety();
  locations[LocationLen] := TLocation.create(x, y);
  LocationLen := LocationLen + 1;
  addObject(TSnakeBody.create(locations, SnakeLength - 2), x, y);
End;

Constructor TSnakeWorld.create(Parent: TOpenGLControl);
Var
  i, j: integer;
Begin
  Inherited create(Parent, 30, 18, 25);
  num := TNum.create();
  For i := Low(bodyPos) To high(bodyPos) Do
    For j := low(bodyPos[i]) To high(bodyPos[i]) Do Begin
      bodyPos[i, j] := 0;
    End;
  setBackground('images' + PathDelim + 'ssand.png');
  SetSpeed(10);
  LocationLen := 0;
  setPaintOrder([TSnake, TSnakeBody, TNum, TWall, TFood, TFood2]);
  setlength(Locations, 30 * 18);
  startLocation();
End;

Destructor TSnakeWorld.destroy;
Var
  i: Integer;
Begin
  For i := 0 To LocationLen - 1 Do Begin
    Locations[i].Free;
  End;
  setlength(Locations, 0);
  Inherited destroy;
End;

End.

