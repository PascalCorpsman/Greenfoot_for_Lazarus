Unit uballon;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  ugreenfoot, OpenGLContext;

Type

  { TCounter }

  TCounter = Class(TActor)
  private
    text: String;
    value: integer;
    Target: integer;
    Procedure updateImage();
  public
    Constructor create(); override;
    Constructor create(Prefix: String);
    Destructor destroy; override;
    Procedure Add(Score: integer);
    Function GetValue(): integer;
    Procedure Act; override;
    Procedure Substract(Score: integer);
  End;

  { TBallonWorld }

  TBallonWorld = Class(TWorld)
  private
    counter: TCounter;
    Procedure Populate();
  public
    Constructor create(Parent: TOpenGLControl);
    Procedure Act(); override;
    Procedure countPop();
    Procedure GameOver();
  End;

  { TScoreBoard }

  TScoreBoard = Class(TActor)
  private
    Fontsize: integer;
    Width: integer;
    height: integer;
    Procedure MakeImage(Title, Prefix: String; score: integer);
  public
    Constructor create(); override;
    Constructor create(Score: integer);
    Destructor destroy; override;
  End;

  { TExplosion }

  TExplosion = Class(TActor)
  private
    IMAGE_COUNT: integer;
    Increment: integer;
    fsize: integer;
    Procedure initialiseImages();
    Procedure explodeOthers();
  public
    Constructor create(); override;
    Destructor destroy; override;
    Procedure Act(); override;
  End;

  { TBomb }

  TBomb = Class(TActor)
  private
    originalx: integer;
    originaly: integer;
    Procedure Reset();
    Procedure Explode();
  public
    Constructor create(); override;
    Destructor destroy; override;
    Procedure addedtoWorld(Const World: TWorld); override;
    Procedure Act(); override;
  End;

  { TDart }

  TDart = Class(TActor)
  private
  public
    Constructor create(); override;
    Destructor destroy; override;
    Procedure Act(); override;
  End;

  { TBalloon }

  TBalloon = Class(TActor)
  private
  public
    Constructor create(); override;
    Destructor destroy; override;
    Procedure Act(); override;
    Procedure pop();
  End;

Implementation

{ TDart }

Constructor TDart.create;
Begin
  Inherited create;
  setimage('images' + PathDelim + 'dart.png');
End;

Destructor TDart.destroy;
Begin
  getimage().Free;
  Inherited destroy;
End;

Procedure TDart.Act;
Var
  mouse: TMouseInfo;
  x, y: integer;
  Balloon: TActor;
Begin
  mouse := MouseInfo;
  setLocation(mouse.getX(), mouse.getY());
  If mouseClicked(Nil) Then Begin
    x := -getImage().getWidth() Div 2;
    y := getImage().getHeight() Div 2;
    balloon := getOneObjectAtOffset(x, y, TBalloon);
    If assigned(balloon) Then Begin
      TBalloon(balloon).pop();
    End;
  End;
End;

{ TExplosion }

Constructor TExplosion.create;
Begin
  Inherited create;
  IMAGE_COUNT := 8;
  Increment := 1;
  fsize := 0;
  initialiseImages();
  playSound('sounds' + PathDelim + 'explosion.wav');
End;

Destructor TExplosion.destroy;
Begin
  Inherited destroy;
End;

Procedure TExplosion.Act;
Var
  img: TGreenfootImage;
Begin
  img := GreenFootGraphicEngine.FindImage('explosion' + inttostr(fsize));
  setimage(img);
  fsize := fsize + Increment;
  If (fsize >= IMAGE_COUNT) Then Begin
    Increment := -Increment;
    fsize := fsize + Increment;
  End;
  explodeOthers();
  If (fsize <= 0) Then Begin
    getWorld().removeObject(self);
  End;
End;

Procedure TExplosion.initialiseImages;
Var
  i: integer;
  maxSize: integer;
  images, baseImage: TGreenfootImage;
  delta: integer;
  size: integer;
Begin
  baseImage := TGreenfootImage.Create('images' + PathDelim + 'explosion.png');
  maxSize := baseImage.GetWidth * 4;
  delta := maxSize Div (IMAGE_COUNT + 1);
  size := 0;
  For i := 0 To IMAGE_COUNT - 1 Do Begin
    images := GreenFootGraphicEngine.FindImage('explosion' + inttostr(i));
    size := size + delta;
    If Not assigned(images) Then Begin
      images := TGreenfootImage.Create(baseImage);
      images.Scale(size, size);
      GreenFootGraphicEngine.AddImage(images, 'explosion' + inttostr(i));
    End;
  End;
  baseImage.free;
End;

Procedure TExplosion.explodeOthers;
Var
  explodeEm: TActorList;
  i: integer;
  a: TActor;
  //  x, y: integer;
Begin
  explodeEm := getIntersectingObjects(Nil);
  For i := 0 To high(explodeEm) Do Begin
    a := explodeEm[i];
    If (a Is TBalloon) Then Begin // Don't explode other explosions
      //      x := a.getx;
      //      y := a.gety;
      TBalloon(a).pop();
      //Enable for cascading explossions
      // getworld().addObject(TExplosion.create(), x, y);
    End;
  End;
End;

{ TBomb }

Procedure TBomb.Reset;
Begin
  setLocation(originalX, originalY);
End;

Procedure TBomb.Explode;
//Var
//  balloons: TActorList;
Begin
  //balloons := getWorld().getObjects(TBalloon);
  getWorld().addObject(TExplosion.create(), getX(), getY());
  getWorld().removeObject(self);
End;

Constructor TBomb.create;
Begin
  Inherited create;
  setimage('images' + PathDelim + 'bomb_01.png');
End;

Destructor TBomb.destroy;
Begin
  getImage().Free;
  Inherited destroy;
End;

Procedure TBomb.addedtoWorld(Const World: TWorld);
Begin
  originalx := getx;
  originaly := gety;
End;

Procedure TBomb.Act;
Var
  mouse: TMouseInfo;
Begin
  // Drag the bomb
  If (mouseDragged(self)) Then Begin
    mouse := MouseInfo;
    setLocation(mouse.getX(), mouse.getY());
  End;
  // Check if the drag has ended.
  If (mouseDragEnded(self)) Then Begin
    If assigned(getOneIntersectingObject(TBalloon)) Then Begin
      explode();
    End
    Else Begin
      reset();
    End;
  End;
End;

{ TBalloon }

Constructor TBalloon.create;
Begin
  Inherited create;
  setimage('images' + PathDelim + 'balloon1.png');
End;

Destructor TBalloon.destroy;
Begin
  getImage().Free;
  Inherited destroy;
End;

Procedure TBalloon.Act;
Begin
  setlocation(getx, gety - 1);
  If gety = 0 Then Begin
    TBallonWorld(getworld()).GameOver();
  End;
End;

Procedure TBalloon.pop;
Begin
  playSound('sounds' + PathDelim + 'pop.wav');
  TBallonWorld(getworld()).countPop();
  getWorld().removeObject(self);
End;

{ TScoreBoard }

Procedure TScoreBoard.MakeImage(Title, Prefix: String; score: integer);
Var
  image: tGreenfootImage;
Begin
  image := TGreenfootImage.create(WIDTH, HEIGHT);
  image.setColor(Color(0, 0, 0, 160));
  image.fillRect(0, 0, WIDTH, HEIGHT);
  image.setColor(Color(255, 255, 255, 100));
  image.fillRect(5, 5, WIDTH - 10, HEIGHT - 10);
  image.FontSize := Fontsize;
  image.setColor(BLACK);
  image.drawString(title, 60, 100);
  image.drawString(prefix + inttostr(score), 60, 200);
  setImage(image);
End;

Constructor TScoreBoard.create;
Begin
  create(100);
End;

Constructor TScoreBoard.create(Score: integer);
Begin
  Inherited create;
  Fontsize := 48;
  Width := 400;
  height := 300;
  makeImage('Game Over', 'Score: ', score);
End;

Destructor TScoreBoard.destroy;
Begin
  getImage().free;
  Inherited destroy;
End;

{ TCounter }

Procedure TCounter.updateImage;
Var
  image: TGreenfootImage;
Begin
  image := getImage();
  image.BeginUpdate();
  image.clear;
  image.SetColor(BLACK);
  image.drawString(text + inttostr(value), 1, 18);
  image.EndUpdate();
End;

Constructor TCounter.create;
Begin
  create('');
End;

Constructor TCounter.create(Prefix: String);
Var
  stringlenght: Integer;
Begin
  Inherited create();
  target := 0;
  value := 0;
  text := Prefix;
  stringlenght := (length(text) + 2) * 16;
  setimage(TGreenfootImage.Create(stringlenght, 24));
  //getImage().FontSize := 24;
  updateImage();
End;

Destructor TCounter.destroy;
Begin
  getImage().free;
  Inherited destroy;
End;

Procedure TCounter.Add(Score: integer);
Begin
  target := Target + Score;
End;

Function TCounter.GetValue: integer;
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
    If (Value > Target) Then Begin
      Value := value - 1;
      updateImage();
    End;
  End;
End;

Procedure TCounter.Substract(Score: integer);
Begin
  target := target - Score;
End;

{ TBallonWorld }

Procedure TBallonWorld.Populate;
Begin
  addObject(tBomb.create(), 750, 410);
  addObject(tBomb.create(), 750, 480);
  addObject(tBomb.create(), 750, 550);
  addObject(TDart.create(), 400, 300);
  addObject(counter, 100, 560);
End;

Constructor TBallonWorld.create(Parent: TOpenGLControl);
Begin
  Inherited create(Parent, 800, 600, 1);
  // Make sure actors are painted in the correct order.
  setPaintOrder([TScoreBoard, TExplosion, TBomb, TDart, TBalloon, TCounter]);
  counter := TCounter.create('Score: ');
  // Add the initial actors
  populate();
  setBackground('images' + PathDelim + 'bricks2.png');
  setspeed(50);
End;

Procedure TBallonWorld.Act;
Begin
  If (getRandomNumber(100) < 3) Then Begin
    addObject(TBalloon.create(), getRandomNumber(700), 600);
  End;
End;

Procedure TBallonWorld.countPop;
Begin
  counter.add(20);
End;

Procedure TBallonWorld.GameOver;
Begin
  addObject(tScoreBoard.create(counter.getValue()), getWidth() Div 2, getHeight() Div 2);
  playSound('sounds' + PathDelim + 'buzz.wav');
  stop();
End;

End.

