(*
 * This Unit is the Original Java to FreePascal translation from
 *
 * http://www.greenfoot.org/scenarios/7992
 *
 *
 * Changelog : ver. 0.01 = 1:1 Translation
 *             ver. 0.02 = Diverse Bugfixes (z.B. 1. Klick erzeugt die welt, so dass es keine Bombe unter der Maus gibt).
 *
 *)
Unit uminesweeper;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  ugreenfoot, OpenGLContext;

Type

  { TBomb }

  TBomb = Class(TActor)
  private
    exploded: boolean;
  public
    Constructor create(); override;
    Procedure Boom();
  End;

  { TCover }

  TCover = Class(TActor)
  private
    Procedure Open();
  public
    Constructor create(); override;
    Procedure Act(); override;
  End;

  { TFlag }

  TFlag = Class(TActor)
  private
  public
    Constructor create(); override;
    Procedure Act(); override;
  End;

  { TCount }

  TCount = Class(TActor)
  private
    count: integer;
  public
    Constructor create(); override;
    Procedure AddedtoWorld(Const world: Tworld); override;
    Function getCount(): integer;
  End;

  { TQuestion }

  TQuestion = Class(TActor)
  private
  public
    Constructor create(); override;
    Procedure Act(); override;
  End;

  { TMineField }

  TMineField = Class(TWorld)
  private
    fBombCount: integer;
    Initialized: Boolean;
    Procedure checkGameOver();
    Procedure addBombs(count, keepoutx, keepouty: integer);
    Procedure addCounts();
    Procedure addCovers();
  public
    Constructor create(Parent: TOpenGLControl; FieldWidth, FieldHeight, BombCount: integer);
    Procedure Act(); override;
  End;

Implementation

{ TQuestion }

Constructor TQuestion.create;
Var
  image: TGreenfootImage;
Begin
  Inherited create;
  image := GreenFootGraphicEngine.FindImage('mquestion.png');
  If Not Assigned(image) Then Begin
    image := TGreenfootImage.Create('images' + PathDelim + 'mquestion.png');
    GreenFootGraphicEngine.AddImage(image, 'mquestion.png');
  End;
  setImage(image);
End;

Procedure TQuestion.Act;
Var
  mouse: TMouseInfo;
Begin
  If (mouseClicked(self)) Then Begin
    mouse := MouseInfo;
    If (mouse.getButton() = MB_Right) Then Begin
      getWorld().removeObject(self);
    End;
  End;
End;

{ TCount }

Constructor TCount.create;
Begin
  Inherited create;
  count := -1;
End;

Procedure TCount.AddedtoWorld(Const world: Tworld);
Var
  bombs: TActorList;
  image: TGreenfootImage;
Begin
  Inherited AddedtoWorld(world);
  bombs := getNeighbours(1, true, TBomb);
  count := high(bombs) + 1;
  If count = 0 Then Begin
    world.removeObject(self);
  End
  Else Begin
    image := GreenFootGraphicEngine.FindImage('mcount' + inttostr(count) + '.png');
    If Not assigned(image) Then Begin
      image := TGreenfootImage.Create('images' + PathDelim + 'mcount' + inttostr(count) + '.png');
      GreenFootGraphicEngine.AddImage(image, 'mcount' + inttostr(count) + '.png');
    End;
    setimage(image);
  End;
End;

Function TCount.getCount: integer;
Begin
  result := count;
End;

{ TFlag }

Constructor TFlag.create;
Var
  image: TGreenfootImage;
Begin
  Inherited create;
  image := GreenFootGraphicEngine.FindImage('mflag.png');
  If Not Assigned(image) Then Begin
    image := TGreenfootImage.Create('images' + PathDelim + 'mflag.png');
    GreenFootGraphicEngine.AddImage(image, 'mflag.png');
  End;
  setImage(image);
End;

Procedure TFlag.Act;
Var
  mouse: TMouseInfo;
Begin
  If (mouseClicked(self)) Then Begin
    mouse := MouseInfo;
    If (mouse.getButton() = MB_Right) Then Begin
      getWorld().addObject(tQuestion.create(), getX(), getY());
      getWorld().removeObject(self);
    End;
  End;
End;

{ TCover }

Procedure TCover.Open;
Var
  flag: TFlag;
  bomb: TBomb;
  count: TActor;
  covers: TActorList;
  Question: TQuestion;
  i: integer;
Begin
  If getWorld() = Nil Then exit;

  flag := TFlag(getOneIntersectingObject(TFlag));
  question := TQuestion(getOneIntersectingObject(tQuestion));
  If (assigned(flag) Or assigned(question)) Then Begin
    exit;
  End;

  bomb := TBomb(getOneIntersectingObject(TBomb));
  If assigned(bomb) Then Begin
    getWorld().removeObject(self);
    bomb.boom();
    exit;
  End;

  count := getOneIntersectingObject(TCount);
  If assigned(count) Then Begin
    getWorld().removeObject(self);
    exit;
  End;

  covers := getNeighbours(1, true, TCover);
  getWorld().removeObject(self);
  For i := 0 To high(covers) Do Begin
    If Not (Covers[i] Is TCover) Then Begin
      Raise exception.Create('asd');
    End;
    TCover(Covers[i]).Open();
  End;
End;

Constructor TCover.create;
Var
  cover: TGreenfootImage;
Begin
  Inherited create;
  cover := GreenFootGraphicEngine.FindImage('mcover.png');
  If Not assigned(cover) Then Begin
    cover := TGreenfootImage.Create('images' + PathDelim + 'mcover.png');
    GreenFootGraphicEngine.AddImage(cover, 'mcover.png');
  End;
  setimage(cover);
End;

Procedure TCover.Act;
Var
  mouse: TMouseInfo;
Begin
  If (mouseClicked(self)) Then Begin
    mouse := MouseInfo;
    If (mouse.getButton() = MB_Left) Then Begin
      open();
    End
    Else Begin
      If (mouse.getButton() = MB_Right) Then Begin
        getWorld().addObject(tFlag.create(), getX(), getY());
      End;
    End;
  End;
End;

{ TBomb }

Constructor TBomb.create;
Var
  image: TGreenfootImage;
Begin
  Inherited create;
  Exploded := false;
  image := GreenFootGraphicEngine.FindImage('mbomb.png');
  If Not Assigned(image) Then Begin
    image := TGreenfootImage.Create('images' + PathDelim + 'mbomb.png');
    GreenFootGraphicEngine.AddImage(image, 'mbomb.png');
  End;
  setImage(image);
End;

Procedure TBomb.Boom;
Var
  questions, covers, flags, bombs: TActorList;
  i: Integer;
  image: TGreenfootImage;
Begin
  exploded := true;
  bombs := getWorld().getObjects(TBomb);
  // Alle Bomben Anzeigen.
  For i := 0 To high(bombs) Do Begin
    flags := getWorld().getObjectsAt(bombs[i].getx, bombs[i].gety, TFlag);
    getWorld().removeObjects(flags);
    covers := getworld().getObjectsAt(bombs[i].getx, bombs[i].gety, TCover);
    getWorld().removeObjects(covers);
    questions := getworld().getObjectsAt(bombs[i].getx, bombs[i].gety, TQuestion);
    getWorld().removeObjects(questions);
  End;
  image := GreenFootGraphicEngine.FindImage('mboom.png');
  If Not assigned(image) Then Begin
    image := TGreenfootImage.Create('images' + PathDelim + 'mboom.png');
    GreenFootGraphicEngine.AddImage(image, 'mboom.png');
  End;
  setimage(image);
  stop;
End;

{ TMineField }

Procedure TMineField.checkGameOver;
Var
  bombs: TActorList;
  numBombs, numCovers: integer;
  b: Boolean;
  i: Integer;
Begin
  (*
   * Das Spiel ist beendet, wenn entweder nur noch Bomben verdeckt sind, oder eine Bombe gezündet wurde ( der 2. Fall verhindert das weiterspielen nach einer Explosion )
   *)
  bombs := getObjects(TBomb);
  numBombs := length(bombs);
  numCovers := length(getObjects(TCover));
  b := false;
  For i := 0 To high(bombs) Do Begin
    If TBomb(bombs[i]).exploded Then Begin
      b := true;
      break;
    End;
  End;
  If (numBombs = numCovers) Or b Then Begin
    stop();
  End;
End;

Procedure TMineField.addBombs(count, keepoutx, keepouty: integer);
Var
  x, y, i: integer;
Begin
  For i := 0 To count - 1 Do Begin
    x := -1;
    y := -1;
    // Die Bomben so erstellen, dass sie überall da sind, wo der User nicht hingeklickt hat.
    Repeat
      x := getRandomNumber(getWidth());
      y := getRandomNumber(getHeight());
    Until (high(getObjectsAt(x, y, TBomb)) = -1) And (Not ((x = keepoutx) And (y = keepouty)));
    addObject(TBomb.create(), x, y);
  End;
End;

Procedure TMineField.addCounts;
Var
  x, y: integer;
Begin
  For x := 0 To getWidth() - 1 Do Begin
    For y := 0 To getHeight() - 1 Do Begin
      If (high(getObjectsAt(x, y, TBomb)) = -1) Then Begin
        addObject(TCount.create(), x, y);
      End;
    End;
  End;
End;

Procedure TMineField.addCovers;
Var
  x, y: integer;
Begin
  For x := 0 To getWidth() - 1 Do Begin
    For y := 0 To getHeight() - 1 Do Begin
      addObject(tCover.create(), x, y);
    End;
  End;
End;

Constructor TMineField.create(Parent: TOpenGLControl; FieldWidth, FieldHeight, BombCount: integer);
Begin
  If FieldWidth * FieldHeight <= BombCount Then Begin
    Raise exception.create('Error to much bombs for this field.');
  End;
  Inherited create(parent, FieldWidth, FieldHeight, 16);
  fBombCount := BombCount;
  setBackground('images' + PathDelim + 'mgrid.png');
  setPaintOrder([TQuestion, TFlag, TCover, TBomb]);
  addCovers();
End;

Procedure TMineField.Act;
Var
  mouse: TMouseInfo;
  x, y: integer;
Begin
  If Not Initialized And mouseClicked(Nil) Then Begin
    Initialized := true;
    mouse := MouseInfo;
    x := mouse.getX();
    y := mouse.getY();
    addBombs(fBombCount, x, y);
    addCounts();
  End;
  checkGameOver();
End;

End.

