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
Unit ulunarlander;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  ugreenfoot, OpenGLContext;

Type

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

  { TMoon }

  TMoon = Class(Tworld)
  private
    gravity: double;
    landingcolor: TGreenFootColor;
    spacecolor: TGreenFootColor;
    Explosion: TExplosion;
  public
    Constructor create(Parent: TOpenGLControl);
    Destructor destroy; override;
    Function getGravity(): Double;
    Function getLandingColor(): TGreenFootColor;
    Function getSpaceColor(): TGreenFootColor;
    Procedure ExplodeAt(x, y: integer);
  End;

  { TFlag }

  TFlag = Class(TActor)
  private
  public
    Constructor create(); override;
    Destructor destroy; override;
  End;

  { TLander }

  TLander = Class(TActor)
  private
    moon: TMoon;
    speed: Double;
    MAX_LAnding_Speed: double;
    thrust: double;
    altitude: double;
    speedfactor: Double;
    rocket: TGreenfootImage;
    rocketwithThrust: TGreenfootImage;
    leftx: integer;
    rightx: integer;
    bottom: integer;
    Procedure ProcessKeys();
    Procedure ApplyGravity();
    Function isLanding(): boolean;
    Function isExploding(): boolean;
    Procedure CheckCollision();
  public
    Constructor create; override;
    Destructor destroy(); override;
    Procedure Act(); override;
    Procedure addedToWorld(Const World: TWorld); override;
  End;

Implementation

{ TExplosion }

Constructor TExplosion.create;
Begin
  Inherited create;
  IMAGE_COUNT := 8;
  Increment := 1;
  fsize := 0;
  initialiseImages();
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
  x, y: integer;
Begin
  explodeEm := getIntersectingObjects(Nil);
  For i := 0 To high(explodeEm) Do Begin
    a := explodeEm[i];
    If Not (a Is TExplosion) Then Begin // Don't explode other explosions
      x := a.getx;
      y := a.gety;
      getworld().removeObject(a);
      getworld().addObject(TExplosion.create(), x, y);
    End;
  End;
End;

{ TFlag }

Constructor TFlag.create();
Begin
  Inherited create;
  setimage(TGreenfootImage.Create('images' + PathDelim + 'flag.png'));
End;

Destructor TFlag.destroy;
Begin
  getImage().free;
  Inherited destroy;
End;

{ TLander }

Constructor TLander.create;
Begin
  Inherited create;
  speed := 0;
  MAX_LAnding_Speed := 15;
  thrust := -3;
  speedfactor := 10;
  leftx := -13;
  rightx := 15;
  bottom := 27;
  setimage('images' + PathDelim + 'rocket.png');
  rocket := getImage();
  rocketwithThrust := TGreenfootImage.Create('images' + PathDelim + 'thrust.png');
  rocketwithThrust.drawImage(rocket, 0, 0);
  (*
   * Add Images to Graphik Engine to avoid flickering
   *)
  GreenFootGraphicEngine.AddImage(Rocket, 'Rocket');
  GreenFootGraphicEngine.AddImage(rocketwithThrust, 'Rocket_with_trust');
End;

Destructor TLander.destroy;
Begin
  Inherited destroy;
End;

Procedure TLander.ProcessKeys;
Begin
  If (isKeyDown('down')) Then Begin
    speed := speed + thrust;
    setImage(rocketWithThrust);
  End
  Else Begin
    setImage(rocket);
  End;
End;

Procedure TLander.ApplyGravity;
Begin
  speed := speed + moon.getGravity();
End;

Function TLander.isLanding: boolean;
Var
  leftColor: TGreenFootColor;
  rightColor: TGreenFootColor;
Begin
  leftColor := moon.getColorAt(getX() + leftX, getY() + bottom);
  rightColor := moon.getColorAt(getX() + rightX, getY() + bottom);
  result := (speed <= MAX_LANDING_SPEED) And (leftColor = moon.getLandingColor()) And (rightColor = moon.getLandingColor());
End;

Function TLander.isExploding: boolean;
Var
  leftColor, rightColor: TGreenFootColor;
Begin
  leftColor := moon.getColorAt(getX() + leftX, getY() + bottom);
  rightColor := moon.getColorAt(getX() + rightX, getY() + bottom);
  result := (leftColor <> moon.getSpaceColor()) Or (rightColor <> moon.getSpaceColor());
End;

Procedure TLander.CheckCollision;
Begin
  If (isLanding()) Then Begin
    setImage(rocket);
    moon.addObject(TFlag.create(), getX(), getY());
    stop();
  End
  Else Begin
    If (isExploding()) Then Begin
      moon.ExplodeAt(getX(), getY());
      moon.removeObject(self);
    End;
  End;
End;

Procedure TLander.Act;
Begin
  processKeys();
  applyGravity();
  altitude := altitude + (speed / speedFactor);
  setLocation(getX(), round(altitude));
  checkCollision();
End;

Procedure TLander.addedToWorld(Const World: TWorld);
Begin
  Inherited addedToWorld(World);
  Moon := Tmoon(world);
  altitude := gety();
End;

{ Mood }

Constructor TMoon.create(Parent: TOpenGLControl);
Begin
  Inherited create(Parent, 600, 600, 1);
  setBackground('images' + PathDelim + 'moon.png');
  gravity := 1.6;
  landingcolor := white;
  spacecolor := black;
  addobject(TLander.create(), 326, 100);
  Explosion := TExplosion.create();
  SetSpeed(40);
End;

Destructor TMoon.destroy;
Begin
  // Wenn es keine Explosion gab.
  If Assigned(Explosion) Then
    Explosion.Free;
  Inherited destroy;
End;

Function TMoon.getGravity: Double;
Begin
  result := gravity;
End;

Function TMoon.getLandingColor: TGreenFootColor;
Begin
  result := LandingColor;
End;

Function TMoon.getSpaceColor: TGreenFootColor;
Begin
  result := spacecolor;
End;

Procedure TMoon.ExplodeAt(x, y: integer);
Begin
  addObject(Explosion, x, y);
  Explosion := Nil;
End;

End.

