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
 * http://www.greenfoot.org/scenarios/250
 *
 *
 * Changelog : ver. 0.01 = 1:1 Translation
 *             ver. 0.02 = Minor Changes to speed up simulation ( Disable raise Exceptions )
 *             ver. 0.03 = Implement additional Features, Added usement of GreenFootGraphicEngine
 *
 *)
Unit uantsadvanced;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  math,
  ugreenfoot, OpenGLContext;

Type

  { TAntWorld }

  TAntWorld = Class(TWorld) // Eigentlich Fertig.
  private
    RESOLUTION: integer;
    SIZE: integer;
  public
    Constructor create(Parent: TOpenGLControl);
    Procedure scenario1();
    Procedure scenario2();
    Procedure scenario3();
    Function getResolution(): integer;
  End;

  { TCounter }

  TCounter = Class(TActor)
  private
    text: String;
    StringLength: integer;
    Procedure UpdateImage();
  public
    value: integer;
    Constructor Create(); override;
    Constructor Create(prefix: String);
    Destructor destroy(); override;
    Procedure Increment();
  End;

  { TAnthill }

  TAnthill = Class(TActor)
  private
    fAnts: integer;
    fmaxAnts: integer;
    fFoodCounter: TCounter;
  public
    Constructor create(); override;
    Constructor create(numberOfAnts: integer);
    Destructor destroy(); override;
    Procedure Act(); override;
    Procedure CountFood();
  End;

  { TFood }

  TFood = Class(TActor)
  private
    fSize: integer;
    fhalfsize: integer;
    fcrumbs: integer;
    fColor1: TGreenFootColor;
    fColor2: TGreenFootColor;
    fColor3: TGreenFootColor;
    Function randomCoord(): integer;
    Procedure UpdateImage();
  public
    Constructor create(); override;
    Destructor destroy(); override;
    Procedure takeSome();
  End;

  TAnt = Class(TActor)
  private
    img: TGreenfootImage;
    imgfood: TGreenfootImage;
    fHomeHill: TAnthill;
    fMAX_PH_LEVEL: integer;
    fPH_TIME: integer;
    fSPEED: integer;
    fdeltaX: integer;
    fdeltay: integer;
    carryingFood: Boolean;
    pheromoneLevel: integer;
    foundLastPheromone: integer;
    Procedure Walk();
    Procedure RandomWalk();
    Procedure HeadHome();
    Procedure headAway();
    Function computeHomeDelta(move: boolean; current, home: integer): integer;
    Procedure checkHome();
    Procedure dropPheromone();
    Procedure takeFood(food: TFood);
    Procedure DropFood();
    Function adjustSpeed(speed: integer): integer;
    Function capSpeed(speed: integer): integer;
    Procedure Move();
    Function randomChance(percent: integer): Boolean;
  public
    Constructor create(); override;
    Constructor create(Home: TAnthill);
    Destructor destroy(); override;
    Procedure Act(); override;
    Procedure CheckFood();
    Function HaveFood(): Boolean;
    Function SmellPheromone(): Boolean;
  End;

  { TPheromone }

  TPheromone = Class(TActor)
  private
    fMAX_INTENSITY: integer;
    fintensity: integer;
    Procedure updateImage();
  public
    Constructor create; override;
    Destructor destroy; override;
    Procedure Act(); override;
  End;

  { TAntlio }

  TAntlio = Class(TActor)
  private
    fantsEaten: integer;
    fSPEED: integer;
    fdeltaX: integer;
    fdeltaY: integer;
    Procedure Walk();
    Procedure RandomWalk();
    Function adjustSpeed(speed: integer): integer;
    Function capSpeed(speed: integer): integer;
    Procedure move();
    Function randomChance(percent: integer): Boolean;
    Function foundAnt(): Boolean;
    Procedure EatAnt();
    Function foundAntlio(): Boolean;
    Procedure eatAntlio();
  public
    Constructor create(); override;
    Destructor destroy(); override;
    Procedure Act(); override;
  End;

  { TFight }

  TFight = Class(TActor)
  private
    fMAX_INTENSITY: integer;
    fintensity: integer;
    //Procedure updateImage();
  public
    Constructor create(); override;
    Destructor destroy(); override;
    Procedure Act(); override;
  End;

Implementation

{ TFight }

//Procedure TFight.updateImage;
//Var
//  Size: integer;
//  image: TGreenfootImage;
//  alpha: integer;
//Begin
//  size := fintensity Div 3 + 5;
//  image := tGreenfootImage.create(size + 1, size + 1);
//  alpha := fintensity Div 3;
//  image.setColor(Color(255, 255, 255, alpha));
//  image.fillOval(0, 0, size, size);
//  image.setColor(RED);
//  image.fillRect(size Div 8, size Div 8, 8, 8);
//  setImage(image);
//  image.free;
//End;

Constructor TFight.create;
Begin
  Inherited create;
  fMAX_INTENSITY := 180;
  fintensity := fMAX_INTENSITY;
  setImage('images' + PathDelim + 'skull.png');
End;

Destructor TFight.destroy;
Begin
  getImage().Free;
  Inherited destroy;
End;

Procedure TFight.Act;
Begin
  fintensity := fintensity - 1;
  If (fintensity <= 0) Then Begin
    getWorld().removeObject(self);
    //End
    //Else Begin
      //If ((fintensity Mod 4) = 0) Then Begin
        //updateImage();
      //End;
  End;
End;

{ TPheromone }

Constructor TPheromone.create;
Begin
  Inherited create;
  fMAX_INTENSITY := 180;
  fintensity := fMAX_INTENSITY;
  setimage(tGreenfootImage.Create(1, 1)); // Einen Dummy Erstellen, der nachher wieder gelöscht werden kann
  updateImage();
End;

Destructor TPheromone.destroy;
Begin
  Inherited destroy;
End;

(**
 * Make the image
 *)

Procedure TPheromone.updateImage;
Var
  size: integer;
  alpha: integer;
  image: TGreenfootImage;
Begin
  (*
   * Da unter Umständen sehr Viel Pheromone erzeugt werden macht der Einsatz
   * der GreenFootGraphicEngine Sinn. Das Sample würde aber auch ohne Laufen.
   *)
  size := fintensity Div 3 + 5;
  image := GreenFootGraphicEngine.FindImage('Pheromone' + inttostr(size + 1));
  If Not assigned(image) Then Begin
    image := tGreenfootImage.Create(size + 1, size + 1);
    alpha := fintensity Div 3;
    image.setColor(Color(255, 255, 255, alpha));
    image.fillOval(0, 0, size, size);
    image.setColor(DARK_GRAY);
    image.fillRect(size Div 2, size Div 2, 2, 2);
    GreenFootGraphicEngine.AddImage(Image, 'Pheromone' + inttostr(size + 1));
  End;
  setImage(image);
End;

(**
 * The pheromone decreases the intesity.
 *)

Procedure TPheromone.Act;
Begin
  fintensity := fintensity - 1;
  If (fintensity <= 0) Then Begin
    getWorld().removeObject(self);
  End
  Else Begin
    If ((fintensity Mod 4) = 0) Then Begin
      updateImage();
    End;
  End;
End;

{ TCounter }

Constructor TCounter.Create;
//Var
//  image: TGreenfootImage;
Begin
  //text := '';
  //StringLength := (length(text) + 2) * 10;
  //image := TGreenfootImage.Create(StringLength, 16);
  //setimage(image);
  //image.free;
  //updateImage();
  create('');
End;

Constructor TCounter.Create(prefix: String);
Var
  image: TGreenfootImage;
Begin
  Inherited Create;
  text := prefix;
  StringLength := (length(text) + 2) * 10;
  image := TGreenfootImage.Create(StringLength, 16);
  setimage(image);
  //image.free;
  updateImage();
End;

Destructor TCounter.destroy;
Begin
  getimage().free;
  Inherited destroy;
End;

Procedure TCounter.Increment;
Begin
  value := value + 1;
  UpdateImage();
End;

Procedure TCounter.UpdateImage;
Var
  image: TGreenfootImage;
Begin
  image := getimage();
  image.clear();
  image.SetColor(BLACK);
  image.drawString(text + inttostr(value), 1, 12);
End;

{ TAntlio }

Constructor TAntlio.create;
Begin
  Inherited create;
  fantsEaten := 0;
  fdeltaX := 0;
  fdeltaY := 0;
  fSPEED := 3;
  setimage('images' + PathDelim + 'antlio.png');
End;

Destructor TAntlio.destroy;
Begin
  getimage().free;
  Inherited destroy;
End;

Procedure TAntlio.Walk;
Begin
  randomwalk;
End;

Procedure TAntlio.RandomWalk;
Begin
  If (randomChance(50)) Then Begin
    fdeltaX := adjustSpeed(fdeltaX);
    fdeltaY := adjustSpeed(fdeltaY);
  End;
  move();
End;

Function TAntlio.adjustSpeed(speed: integer): integer;
Begin
  speed := speed + randomizer.nextInt(2 * FSPEED - 1) - FSPEED + 1;
  result := capSpeed(speed);
End;

Function TAntlio.capSpeed(speed: integer): integer;
Begin
  If (speed < -fSPEED) Then Begin
    result := -fSPEED;
  End
  Else Begin
    If (speed > fSPEED) Then Begin
      result := fSPEED;
    End
    Else Begin
      result := speed;
    End;
  End;
End;

Procedure TAntlio.move;
Begin
  //try {
  setLocation(getX() + fdeltaX, getY() + fdeltaY, false);
  //}
  //catch (IndexOutOfBoundsException e) {
      // We don't care - just leave it
  //}
  setRotation(round(180 * arctan2(fdeltaY, fdeltaX) / PI));
End;

Function TAntlio.randomChance(percent: integer): Boolean;
Begin
  result := Randomizer.nextInt(100) < percent;
End;

//eat codeeeee

Function TAntlio.foundAnt: Boolean;
Var
  ant: Tactor;
Begin
  ant := getOneObjectAtOffset(0, 0, TAnt);
  result := assigned(ant);
End;

(**
 * Eat a Ant.
 *)

Procedure TAntlio.EatAnt;
Var
  ant: TActor;
  fh: Tantlio;
Begin
  Ant := getOneIntersectingObject(TAnt);
  If assigned(ant) Then Begin
    // eat the Ant...
    getWorld().removeObject(Ant);
    fantsEaten := fantsEaten + 1;
    If (fantsEaten >= 10) Then Begin
      fantsEaten := 0;
      //        int f = Greenfoot.getRandomNumber(1000);
      fh := tantlio.create();
      getWorld().addObject(fh, getX(), getY());
    End;
  End;
End;

Function TAntlio.foundAntlio: Boolean;
Var
  antlio: TActor;
Begin
  antlio := getOneObjectAtOffset(0, 0, TAntlio);
  result := Assigned(antlio);
End;

Procedure TAntlio.eatAntlio;
Var
  antlio: TActor;
  fd: TFood;
  ff: TFight;
Begin
  antlio := getOneIntersectingObject(TAntlio);
  If assigned(antlio) Then Begin
    If (getRandomNumber(100) <= 90) Then Begin
      getWorld().removeObject(antlio);
      fantsEaten := fantsEaten + 1;
      fd := TFood.create();
      getWorld().addObject(fd, getx, gety);
      ff := TFight.create();
      getWorld().addObject(ff, getx, gety);
    End;
  End;
End;

Procedure TAntlio.Act;
Begin
  // Add your action code here.
  If (foundAnt()) Then Begin
    eatAnt();
  End
  Else Begin
    If (foundAntlio()) Then Begin
      If (getRandomNumber(100) <= 2) Then Begin
        eatAntlio();
      End;
      walk();
      walk();
      walk();
      walk();
      walk();
    End
    Else Begin
      walk();
    End;
  End;
End;

{ TFood }

Constructor TFood.create;
Begin
  Inherited create;
  fSize := 30;
  fcrumbs := 100;
  fhalfsize := fSize Div 2;
  fColor1 := Color(160, 200, 60);
  fColor2 := Color(80, 100, 30);
  fColor3 := Color(10, 50, 0);
  setimage(TGreenfootImage.create(fSize, fSize));
  UpdateImage();
End;

Destructor TFood.destroy;
Begin
  getimage().free;
  Inherited destroy;
End;

(**
 * Removes some food from this pile of food.
 *)

Procedure TFood.takeSome;
Begin
  fcrumbs := fcrumbs - 3;
  If (fcrumbs <= 0) Then Begin
    GetWorld().removeObject(self);
  End
  Else Begin
    UpdateImage();
  End;
End;

(**
 * Returns a random number relative to the size of the food pile.
 *)

Function TFood.randomCoord: integer;
Var
  val: integer;
Begin
  val := fhalfsize + round(Randomizer.nextGaussian * 0.75 * (fhalfsize / 2));
  If (val < 0) Then
    result := 0
  Else Begin
    If (val > fSize - 2) Then
      result := fSize - 2
    Else
      Result := val;
  End;
End;

(**
 * Update the image
 *)

Procedure TFood.UpdateImage;
Var
  Image: TGreenfootImage;
  i, x, y: integer;
Begin
  //image := TGreenfootImage.create(fSize, fSize);
  image := getImage();
  image.BeginUpdate();
  image.clear();
  For i := 0 To fcrumbs - 1 Do Begin
    x := randomCoord();
    y := randomCoord();
    image.setColorAt(x, y, fcolor1);
    image.setColorAt(x + 1, y, fcolor2);
    image.setColorAt(x, y + 1, fcolor2);
    image.setColorAt(x + 1, y + 1, fcolor3);
  End;
  image.EndUpdate();
  //SetImage(Image);
  //image.free;
End;

{ TAnt }

Constructor TAnt.create;
Begin
  //Inherited create;
  //fHomeHill := Nil;
  //fMAX_PH_LEVEL := 18;
  //fPH_TIME := 30;
  //fSPEED := 3;
  //fdeltaX := 0;
  //fdeltay := 0;
  //carryingFood := false;
  //pheromoneLevel := fMAX_PH_LEVEL;
  //foundLastPheromone := 0;
  //setImage('images' + PathDelim + 'ant.png');
  create(Nil);
End;

Constructor TAnt.create(Home: TAnthill);
Var
  ig: TGreenfootImage;
Begin
  Inherited create;
  fHomeHill := Home;
  fMAX_PH_LEVEL := 18;
  fPH_TIME := 30;
  fSPEED := 3;
  fdeltaX := 0;
  fdeltay := 0;
  carryingFood := false;
  pheromoneLevel := fMAX_PH_LEVEL;
  foundLastPheromone := 0;
  (*
   * Using the GreenFootGraphicEngine is not necessery, but will optimize the
   * memory management
   *)
  ig := GreenFootGraphicEngine.FindImage('Ant');
  If assigned(ig) Then Begin
    // Wenn die Bilder schon mal geladen wurden, brauchen sie nicht noch mal erzeugt werden
    img := ig;
    imgfood := GreenFootGraphicEngine.FindImage('AntFood');
  End
  Else Begin
    // Die Aller erste Ameise, erzeugt beide Bilde für alle Anderen Ameisen.
    img := TGreenfootImage.Create('images' + PathDelim + 'ant.png');
    GreenFootGraphicEngine.AddImage(img, 'Ant');
    imgfood := TGreenfootImage.Create('images' + PathDelim + 'ant-with-food.png');
    GreenFootGraphicEngine.AddImage(imgfood, 'AntFood');
  End;
  setimage(img);
End;

Destructor TAnt.destroy;
Begin
  Inherited destroy;
End;

(**
 * Walk around in search of food.
 *)

Procedure TAnt.Walk;
Begin
  If (foundLastPheromone > 0) Then Begin // if we can still remember...
    foundLastPheromone := foundLastPheromone - 1;
    headAway();
  End
  Else Begin
    If (smellPheromone()) Then Begin
      move();
    End
    Else Begin
      randomWalk();
    End;
  End;
  checkFood();
End;

(**
 * Walk around randomly.
 *)

Procedure TAnt.RandomWalk;
Begin
  If (randomChance(50)) Then Begin
    fdeltaX := adjustSpeed(fdeltaX);
    fdeltaY := adjustSpeed(fdeltaY);
  End;
  move();
End;

(**
 * Try to walk home.
 *)

Procedure TAnt.HeadHome;
Var
  distanceX, distancey: integer;
  moveX, movey: boolean;
Begin
  If Not assigned(fhomeHill) Then Begin
    //if we do not have a home, we can not go there.
    exit;
  End;
  If (randomChance(2)) Then Begin
    randomWalk(); // cannot always walk straight...
  End
  Else Begin
    distanceX := abs(getX() - fhomeHill.getX());
    distanceY := abs(getY() - fhomeHill.getY());
    moveX := (distanceX > 0) And (randomizer.nextInt(distanceX + distanceY) < distanceX);
    moveY := (distanceY > 0) And (randomizer.nextInt(distanceX + distanceY) < distanceY);

    fdeltaX := computeHomeDelta(moveX, getX(), fhomeHill.getX());
    fdeltaY := computeHomeDelta(moveY, getY(), fhomeHill.getY());
    move();

    If (pheromoneLevel = fMAX_PH_LEVEL) Then Begin
      dropPheromone();
    End
    Else Begin
      pheromoneLevel := pheromoneLevel + 1;
    End;
  End;
  checkHome();
End;

(**
 * Try to walk away from home.
 *)

Procedure TAnt.headAway;
Var
  distanceX, distancey: integer;
  moveX, movey: boolean;
Begin
  If Not assigned(fhomeHill) Then Begin
    //if we do not have a home, we can not head away from it.
    exit;
  End;
  If (randomChance(2)) Then Begin
    randomWalk(); // cannot always walk straight...
  End
  Else Begin
    distanceX := abs(getX() - fhomeHill.getX());
    distanceY := abs(getY() - fhomeHill.getY());
    moveX := (distanceX > 0) And (randomizer.nextInt(distanceX + distanceY) < distanceX);
    moveY := (distanceY > 0) And (randomizer.nextInt(distanceX + distanceY) < distanceY);

    fdeltaX := computeHomeDelta(moveX, getX(), fhomeHill.getX()) * -1;
    fdeltaY := computeHomeDelta(moveY, getY(), fhomeHill.getY()) * -1;
    move();
  End;

End;

(**
  * Compute and return the direction (delta) that we should steer in when
  * we're on our way home.
  *)

Function TAnt.computeHomeDelta(move: boolean; current, home: integer): integer;
Begin
  If (move) Then Begin
    If (current > home) Then Begin
      result := -fSPEED;
    End
    Else Begin
      result := fSPEED;
    End;
  End
  Else
    result := 0;
End;

(**
 * Are we home? Drop the food if we are.
 *)

Procedure TAnt.checkHome;
Begin
  If (fhomeHill <> Nil) And (intersects(fhomeHill)) Then Begin
    dropFood();
    // move one step to where we came from so that we set out back in
    // the
    // right direction
    fdeltaX := -fdeltaX;
    fdeltaY := -fdeltaY;
    move();
    move();
  End;
End;

(**
 * Drop a spot of pheromones at our current location.
 *)

Procedure TAnt.dropPheromone;
Var
  ph: TPheromone;
Begin
  // otherwise drop a new one
  ph := tPheromone.create();
  getWorld().addObject(ph, getX(), getY());
  pheromoneLevel := 0;
End;

(**
 * Drop a spot of pheromones at our current location.
 *)

Procedure TAnt.takeFood(food: TFood);
Begin
  carryingFood := true;
  food.takeSome();
  setimage(imgfood);
End;

(**
 * Drop our food in the ant hill.
 *)

Procedure TAnt.DropFood;
Begin
  carryingFood := false;
  fhomeHill.countFood();
  setImage(img);
End;

(**
 * Adjust the speed randomly (start moving, continue or slow down). The
 * speed returned is in the range [-SPEED .. SPEED].
 *)

Function TAnt.adjustSpeed(speed: integer): integer;
Begin
  speed := speed + randomizer.nextInt(2 * fSPEED - 1) - fSPEED + 1;
  result := capSpeed(speed);
End;

(**
 * The speed returned is in the range [-SPEED .. SPEED].
 *)

Function TAnt.capSpeed(speed: integer): integer;
Begin
  If (speed < -fSPEED) Then Begin
    result := -fSPEED
  End
  Else Begin
    If (speed > fSPEED) Then
      result := fSPEED
    Else
      result := speed;
  End;
End;

(**
 * Move forward according to the current delta values.
 *)

Procedure TAnt.Move;
Begin
  //Try  // Die Try Routine ist mit dem "false" Parameter ausgehebelt, das steigert deutlich die Simulationsgeschwindigkeit
  setLocation(getX() + fdeltaX, getY() + fdeltaY, false);
  //Except
    // We don't care - just leave it
  //End;
  setRotation(round(180 * arctan2(fdeltaY, fdeltaX) / PI));
End;

(**
 * Return 'true' in exactly 'percent' number of calls. That is: a call
 * randomChance(25) has a 25% chance to return true.
 *)

Function TAnt.randomChance(percent: integer): Boolean;
Begin
  result := Randomizer.nextInt(100) < percent;
End;

(**
 * Do what an ant's gotta do.
 *)

Procedure TAnt.Act;
Begin
  If (haveFood()) Then Begin
    headHome();
  End
  Else Begin
    walk();
  End;
End;

Procedure TAnt.CheckFood;
Var
  food: TFood;
Begin
  food := TFood(getOneIntersectingObject(TFood));
  If Assigned(Food) Then Begin
    takefood(Food);
  End;
End;

(**
 * Tell whether we are carrying food of not.
 *)

Function TAnt.HaveFood: Boolean;
Begin
  result := carryingFood;
End;

(**
 * Check whether we can smell pheromones. If we can, turn towards it and
 * return true. Otherwise just return false.
 *)

Function TAnt.SmellPheromone: Boolean;
Var
  ph: TActor;
Begin
  result := false;
  ph := getOneIntersectingObject(TPheromone);
  If assigned(ph) Then Begin
    fdeltaX := capSpeed(ph.getX() - getX());
    fdeltaY := capSpeed(ph.getY() - getY());
    If (fdeltaX = 0) And (fdeltaY = 0) Then Begin
      foundLastPheromone := fPH_TIME;
    End;
    result := true;
  End;
End;

{ TAnthill }

Constructor TAnthill.create;
Begin
  //Inherited create;
  //fFoodCounter := Nil;
  //fmaxAnts := 400000;
  //fAnts := 0;
  //SetImage('images' + pathdelim + 'anthill.png');
  create(400000);
End;

Constructor TAnthill.create(numberOfAnts: integer);
Begin
  Inherited create;
  fFoodCounter := Nil;
  fAnts := 0;
  fmaxAnts := numberOfAnts;
  SetImage('images' + pathdelim + 'anthill.png');
End;

Destructor TAnthill.destroy;
Begin
  getImage().free;
  Inherited destroy;
End;

Procedure TAnthill.Act;
Begin
  If getRandomNumber(100) < 7 Then Begin
    getworld.addObject(TAnt.Create(self), getx, gety);
    fAnts := fAnts + 1;
  End
  Else Begin
    If (fants >= 50) Then Begin
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      getworld.addObject(TAnt.Create(self), getx, gety);
      fants := 0;
    End;
  End;
End;

(**
 * Record that we have collected another bit of food.
 *)

Procedure TAnthill.CountFood;
Var
  x, y: integer;
Begin
  If Not assigned(fFoodCounter) Then Begin
    fFoodCounter := TCounter.Create('Food: ');
    x := getx;
    y := gety + getwidth() Div 2 + 8;
    If (y >= getworld.getheight()) Then Begin
      y := getworld.getheight();
    End;
    GetWorld().AddObject(fFoodCounter, x, y);
  End;
  fFoodCounter.increment();
End;

{ AntWorld }

(**
 * Create a new world. It will be initialised with a few ant hills
 * and food sources
 *)

Constructor TAntWorld.create(Parent: TOpenGLControl);
Begin
  size := 640;
  RESOLUTION := 1;
  Inherited create(parent, size Div RESOLUTION, size Div RESOLUTION, RESOLUTION);
  setBackground('images' + pathdelim + 'sand.jpg');
  setPaintOrder([TAnt, TAntlio, TCounter, TFood, TAntHill, TPheromone]);
  scenario3();
  SetSpeed(20);
End;

Procedure TAntWorld.scenario1;
Begin
  AddObject(TAnthill.Create(70), size Div 2, size Div 2);

  AddObject(TFood.create(), SIZE Div 2, SIZE Div 2 - 260);
  AddObject(TFood.create(), SIZE Div 2 + 215, SIZE Div 2 - 100);
  AddObject(TFood.create(), SIZE Div 2 + 215, SIZE Div 2 + 100);
  AddObject(TFood.create(), SIZE Div 2, SIZE Div 2 + 260);
  AddObject(TFood.create(), SIZE Div 2 - 215, SIZE Div 2 + 100);
  AddObject(TFood.create(), SIZE Div 2 - 215, SIZE Div 2 - 100);

  AddObject(TAntlio.create(), SIZE Div 2 - 215, SIZE Div 2 - 100);
  AddObject(TAntlio.create(), SIZE Div 2, SIZE Div 2 + 260);
End;

Procedure TAntWorld.scenario2;
Begin
  AddObject(TAnthill.Create(40), 546, 356);
  AddObject(TAnthill.Create(40), 95, 267);

  AddObject(TFood.create(), 80, 71);
  AddObject(TFood.create(), 291, 56);
  AddObject(TFood.create(), 516, 212);
  AddObject(TFood.create(), 311, 269);
  AddObject(TFood.create(), 318, 299);
  AddObject(TFood.create(), 315, 331);
  AddObject(TFood.create(), 141, 425);
  AddObject(TFood.create(), 378, 547);
  AddObject(TFood.create(), 566, 529);

  AddObject(TAntlio.create(), SIZE Div 2 - 215, SIZE Div 2 - 100);
  AddObject(TAntlio.create(), SIZE Div 2, SIZE Div 2 + 260);
End;

Procedure TAntWorld.scenario3;
Begin
  AddObject(TAnthill.Create(40), 576, 134);
  AddObject(TAnthill.Create(40), 59, 512);

  AddObject(TFood.create(), 182, 84);
  AddObject(TFood.create(), 39, 308);
  AddObject(TFood.create(), 249, 251);
  AddObject(TFood.create(), 270, 272);
  AddObject(TFood.create(), 291, 253);
  AddObject(TFood.create(), 339, 342);
  AddObject(TFood.create(), 593, 340);
  AddObject(TFood.create(), 487, 565);

  AddObject(TAntlio.create(), SIZE Div 2 - 215, SIZE Div 2 - 100);
  AddObject(TAntlio.create(), SIZE Div 2, SIZE Div 2 + 260);
End;

Function TAntWorld.getResolution: integer;
Begin
  result := RESOLUTION;
End;

End.

