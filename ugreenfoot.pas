(*
 * This Unit implements some of the Greenfoot Base Classes
 * If you want to create a new World you have to derive it from TWorld
 * Use TActor to create Actors in your World. For Further informations read
 * the beginning comment of unit1.pas from this project.
 *
 * Original Dokumentation :
 * http://www.greenfoot.org/files/javadoc/greenfoot/package-summary.html
 *
 * The version of this unit is : 0.01
 *
 *
 * History : 0.01 = Initial version
 *                  TWorld, TActor, TGreenfootImage, TRandomizer
 *)
Unit ugreenfoot;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils,
  FileUtil,
  dglOpenGL, // http://wiki.delphigl.com/index.php/dglOpenGL.pas
  math,
  uvectormath, // http://corpsman.de/index.php?doc=opengl/opengl_graphikengine
  OpenGLContext, // TOpenGLControl ( default komponente unter Lazarus )
  graphics;

Type

  TMouseButton = (MB_None = 0, MB_Left = 1, MB_Middle = 2, MB_Right = 3);
  TMouseState = (MS_ButtonsDown, MS_Moving);
  TMouseStateSet = Set Of TMouseState;

  TKeys = // Alle Tasten, welche durch den Benutzer abgefragt werden können
  (
    key_a, key_b, key_c, key_d, key_e, key_f, key_g, key_h, key_i, key_j, // Fertig
    key_k, key_l, key_m, key_n, key_o, key_p, key_q, key_r, key_s, key_t, // Fertig
    key_u, key_v, key_w, key_x, key_y, key_z, // Fertig
    key_up, key_down, key_left, key_right, // Fertig
    key_enter, key_space, key_tab, key_escape, key_backspace, key_shift, key_control,
    key_f1, key_f2, key_f3, key_f4, key_f5, key_f6, key_f7, key_f8, key_f9, key_f10, key_f11, key_f12,
    key_None
    );

  TSpeedCallback = Procedure(Sender: TObject; NewSpeed: integer; Visible: Boolean) Of Object;

  TCallbacks = Record // List of all Callbacks which are needed to Controll the Main App
    StartEvent: TNotifyEvent;
    StopEvent: TNotifyEvent;
    SpeedCallback: TSpeedCallback;
  End;

  TGreenFootColor = Record
    Red: Byte;
    Green: Byte;
    Blue: Byte;
    Alpha: BYte;
  End;

  TActor = Class;

  TActorList = Array Of TActor;

  TGreenfootImage = Class;

  TActorData = Record
    Actor: TActor;
    x, y, rotation: integer;
  End;

  TSortedClasses = Record
    Class_: TClass;
    Elements: Array Of Integer;
  End;

  { TGreenfootBase }

  TGreenfootBase = Class
  private
    FWidth: Integer; // Die Breite in Pixeln
    fHeight: integer; // Die Höhe in Pixeln
    FImage: TGreenfootImage; // Das Bild
  public
    Name: String; // Einfach nur so, falls jemand den setzen will
    Constructor create(); virtual;
    Destructor destroy; override;
  End;

  { TWorld }

  TWorld = Class(TGreenfootBase)
  private
    FActOrderClasses: Array Of TClass; // Speichert die ActOrder
    FActClasses: Array Of Array Of Integer; // Alle Objecte in ihrer "Act" Order
    FPaintOrderClasses: Array Of TClass; // Speichert in welcher Reihenfolge Objekte gerendert werden sollen ( ist wichtig, da es keinen Tiefenpuffer gibt )
    FPaintClasses: Array Of Array Of Integer; // Hier werden alle Objecte Eingetragen und entsprechend gerendert.
    FObjects: Array Of TActorData; // Die Actoren die in der Welt Aggieren
    fParent: TOpenGLControl; // Das OpenGLControl in dem die Welt gerendert wird.
    fSortedClasses: Array Of TSortedClasses; // Zur Beschleunigung von Intersect Routinen sind alle Objekte Sortiert nach Typ hinterlegt
    ftoDeleteList: Array Of TActor;
    fworldHeight: integer; // Die Welthöhe gemessen in "Zellen"
    fworldWidth: integer; // Die Weltbreite gemessen in "Zellen"
    fcellsize: integer; // Die Zellengröße
    fBounded: Boolean; // Gibt an ob die Welt ein Donut ist oder nicht
    Procedure removeObject_helper(Object_: TActor); // Löscht ein Object aus der Welt
  public
    (*
     * Der Ursprung ist unten Links ( nicht wie bei Windows oben Rechts !! )
     *)
    Constructor create(Parent: TOpenGLControl; worldWidth, worldHeight, cellSize: integer; bounded: Boolean = false); reintroduce;
    Destructor destroy(); override;

    Procedure SystemAct(); // Führt einen Act Schritt aller Objecte aus
    Procedure Act(); virtual; // Auch die Welt hat einen "Act"
    Procedure addObject(Object_: TActor; x, y: integer);
    Function getBackground(): TGreenfootImage;
    Function getHeight(): integer; // Gibt die Welt Höhe in Zellen zurück
    Function getCellSize(): integer; // Gibt die ZUellengröße zurück
    Function getColorAt(x, y: integer): TGreenFootColor;
    Function getOneObject(Object_: TClass): TActor; // Gibt genau ein Object der gesuchten Klasse zurück, wenn Object_ = nil, dann wird das 1. Object zurückggeben
    Function getObjects(Object_: TClass): TActorList;
    Function getOneObjectAt(x, y: integer; Object_: TClass): TActor;
    Function getObjectsAt(x, y: integer; Object_: TClass): TActorList; // Gibt eine Liste der Objecte Zurück, welche alle den Mittelpunkt der Zelle x,y überdecken
    Function getWidth(): integer; // Gibt die Welt Breite in Zellen zurück
    Procedure removeObject(Object_: TActor); // Löscht ein Object aus der Welt
    Procedure removeObjects(Objectlist: TActorList); // Löscht ein Object aus der Welt
    Procedure rePaint(); // Do not Call this Method, it is used by the Greenfoot Simulating System
    Procedure setActOrder(Const Order: Array Of TClass);
    Procedure setBackground(Filename: String);
    Procedure setBackground(Const Image: TGreenfootImage);
    Procedure setPaintOrder(Const Order: Array Of TClass);
  End;

  { TActor }

  TActor = Class(TGreenfootBase)
  private
    fworld: TWorld;
    FIndexInWorld: integer; // Beschleunigt den Zugriff auf das Objekt in der Welt.
    FisAlive: Boolean; // Wenn True, dann ist das Object in einer TWorld und am Leben, wenn False, dann wartet es auf sein Löschen
    FWorldRotation: Integer; // Wird nur benutzt, falls diese Werte schon zugewiesen werden bevor das Objekt in die Welt geadded wird.
    Function clone: TActor; // Erzeugt eine Neue Instanz der Klasse ( klappt auch mit Kindklassen )

  protected
    Procedure act(); virtual;
    Procedure addedToWorld(Const World: TWorld); virtual; // Wird Aufgerufen, wenn der TActor Erfolgreich in die Welt eingegliedert wurde

  public
    Constructor create(); override;
    Destructor destroy; override;

    Function getHeight: integer;
    Function getImage(): TGreenfootImage;
    Function getIntersectingObjects(cls: TClass): TActorList;
    Function getNeighbours(distance: integer; diagonal: Boolean; cls: TClass): TActorList;
    Function getOneObjectAtOffset(dx, dy: integer; cls: TClass): Tactor;
    Function getOneIntersectingObject(cls: TClass): TActor;
    Function getObjectsInRange(radius: integer; cls: TClass): TActorList;
    Function getRotation(): integer;
    Function getWidth: integer;
    Function getWorld(): TWorld;
    Function getx: integer;
    Function gety: integer;
    Function intersects(Const Other: TActor): Boolean;
    Procedure rePaint(); // Do not Call this Method, it is used by the Greenfoot Simulating System
    Procedure setImage(Filename: String);
    Procedure setImage(Image: TGreenfootImage);
    Procedure setLocation(x, y: integer; ThrowExceptionOnLeaveWorld: Boolean = True);
    Procedure setRotation(rotation: integer);
  End;

  { TGreenfootImage }

  TGreenfootImage = Class
  private
    FRohdaten: Array Of Array[0..3] Of Byte; // Eine Schattenkopie von dem Was im OpenGL Buffer ist.
    FimageTexCoords: Array[0..1] Of TVector2; // Die Zugehörigen Texturkoordinaten
    Fimage: integer; // Der BildPointer im OpenGL Buffer
    fWidth: integer; // Die nach außen Sichtbare "Echte" Breite des Bildes
    fHeight: Integer; // Die nach außen Sichtbare "Echte" Höhe des Bildes
    fWidthHalf: integer; // Die hälfte der Breite (nur Intern gebraucht)
    fHeightHalf: Integer; // Die hälfte der Höhe (nur Intern gebraucht)
    fCurrentColor: TGreenFootColor; // Die Aktuelle Farbe des Pinsels
    fOpenGLWidth, FOpenGLHeight: integer; // Die Breite und Höhe im OpenGL Buffer
    fUpdateing: integer; // Hilft bei Begin / Endupdate
    fOwnedByGraphikEngine: Boolean; // True, wenn das Bild der GraphikEngine hinzugefügt wurde -> dann kümmert sich die GraphikEngine um das Freigeben
    Function FileToBitmap(Filename: String): TBitmap; // Wandelt eine "Datei" in ein TBitmap um, das dann weiter verarbetet werden kann
  public
    FontSize: integer; // Legt fest wie Hoch die Schrift in Pixeln sein soll ( - Height Spiegelt an der X-Achse )
    Constructor Create(Filename: String);
    Constructor Create(Width, Height: Integer);
    Constructor Create(Image: TGreenfootImage);
    Destructor destroy(); override;
    Procedure clear();
    Procedure drawImage(Const img: TGreenfootImage; x, y: integer);
    Procedure drawLine(x1, y1, x2, y2: integer);
    Procedure drawOval(x, y, width, height: integer);
    Procedure drawPolygon(xPoints, yPoints: Array Of Integer; npoints: integer);
    Procedure drawRect(x, y, width, height: integer);
    Procedure drawString(String_: String; x, y: integer);
    Procedure fillOval(x, y, width, height: integer);
    Procedure fillPolygon(xPoints, yPoints: Array Of Integer; npoints: integer);
    Procedure fillRect(x, y, width, height: integer);
    Function GetColorAt(x, y: integer): TGreenFootColor;
    Function GetHeight: integer;
    Function GetWidth: integer;
    Procedure RePaint(); // Do not Call this Method, it is used by the Greenfoot Simulating System
    Procedure Rotate(degrees: integer);
    Procedure Scale(Width, Height: integer);
    Procedure SetColor(Color: TGreenFootColor);
    Procedure SetColorAt(x, y: integer; Color: TGreenFootColor);
    Procedure mirrorHorizontally();

    Function TextWidth(Text: String): integer; // Gibt die Breite eines Textes in Pixeln zurück
    Function TextHeight(Text: String): integer; // Gibt die Höhe eines Textes in Pixeln zurück

    (*
     * Diese beiden Routinen sind nicht unbedingt notwendig,
     * Sie beschleunigen aber den Pixelweisen Zugriff, wenn "Viele" Pixel geändert werden.
     *)
    Procedure BeginUpdate();
    Procedure EndUpdate();
  End;

  { TGreenFootGraphicEngine }
  (*
   * Diese Klasse stellt einen Globalen Container zum Arbeiten mit Graphiken
   * zur Verfügung. Die Einmal hinzugefügten Graphiken, werden automatisch wieder
   * Freigegeben.
   *)
  TGreenFootGraphicEngine = Class
  private
    FImages: Array Of TGreenfootImage;
    fNames: Array Of String;
  public
    Constructor create();
    Destructor destroy; override;
    Procedure AddImage(Const Image: TGreenfootImage; Name: String);
    Function FindImage(Name: String): TGreenfootImage;
    Procedure Clear(); // Löscht - entfernt alle in der Engine Registrierten Bilder (bei Reset Notwendig, sollte nicht durch User aufgerufen werden!)
  End;

  { TRandomizer }

  TRandomizer = Class
  private
    State: integer;
    in1, in2, out1, out2: Double;
    Procedure Boxmuller(g1, g2: Double; Out s1, s2: Double);
  public
    Constructor create;
    Function nextGaussian: Single; // Berechnet eine Standart Normal Verteilte Zufallsvariable nach dem BoxMuller Verfahren
    Function nextInt(limit: Integer): Integer;
  End;

  { TMouseInfo }

  TMouseInfo = Class
  private
    fOnMouseDownActor: TActor; // Der Actor, der sich unter der Maus befand als der MouseDown Event Kam !
    fOnMouseUpActor: TActor; // Der Actor, der sich unter der Maus befand als der MouseDown Event Kam !
    fOnMoveActor: TActor;
    fx, fy: integer;
    fWorld: TWorld;
    fMouseState: TMouseStateSet;
    fMouseButtondown, fMouseButtonup: TMouseButton;
  public
    Constructor create;
    Function getActor(): TActor;
    Function getButton(): TMouseButton;
    Function getClickCount(): integer;
    Function getX(): integer;
    Function getY(): integer;
    Procedure MouseDown(Const World: TWorld; x, y: integer; Shift: TShiftState); // Do not Call this Method, it is used by the Greenfoot Simulating System
    Procedure MouseMove(Const World: TWorld; x, y: integer); // Do not Call this Method, it is used by the Greenfoot Simulating System
    Procedure MouseUp(); // Do not Call this Method, it is used by the Greenfoot Simulating System
    Procedure Reset(); // Do not Call this Method, it is used by the Greenfoot Simulating System
  End;

Const
  white: TGreenFootColor = (Red: $FF; Green: $FF; Blue: $FF; Alpha: 255);
  light_gray: TGreenFootColor = (Red: $C0; Green: $C0; Blue: $C0; Alpha: 255);
  gray: TGreenFootColor = (Red: $80; Green: $80; Blue: $80; Alpha: 255);
  dark_gray: TGreenFootColor = (Red: $40; Green: $40; Blue: $40; Alpha: 255);
  black: TGreenFootColor = (Red: $00; Green: $00; Blue: $00; Alpha: 255);
  red: TGreenFootColor = (Red: $FF; Green: $00; Blue: $00; Alpha: 255);
  pink: TGreenFootColor = (Red: $FF; Green: $AF; Blue: $AF; Alpha: 255);
  orange: TGreenFootColor = (Red: $FF; Green: $C8; Blue: $00; Alpha: 255);
  yellow: TGreenFootColor = (Red: $FF; Green: $FF; Blue: $00; Alpha: 255);
  green: TGreenFootColor = (Red: $00; Green: $FF; Blue: $00; Alpha: 255);
  magenta: TGreenFootColor = (Red: $FF; Green: $00; Blue: $FF; Alpha: 255);
  cyan: TGreenFootColor = (Red: $00; Green: $FF; Blue: $FF; Alpha: 255);
  blue: TGreenFootColor = (Red: $00; Green: $00; Blue: $FF; Alpha: 255);

Var
  Randomizer: TRandomizer; //  Der Zufallszahlengenerator steht immer zur Verfügung.
  GreenFootGraphicEngine: TGreenFootGraphicEngine;
  MouseInfo: TMouseInfo;

  (*
   * Basis Routinen, welche durch die Library zur Verfügung gestellt werden
   *)

Operator = (a, b: TGreenFootColor): Boolean;

Function Color(Red, Green, Blue: byte): TGreenFootColor; overload; // Wandelt RGB Farben in TGreenFootColor um.
Function Color(Red, Green, Blue, Alpha: byte): TGreenFootColor; overload; // Wandelt RGB Farben in TGreenFootColor um.

Function getMouseInfo(): TMouseInfo;
Function getRandomNumber(limit: integer): integer; // Liefert eine Gleichverteilte Zufallsvariable im x mit 0 <= x < Limit
Function isKeyDown(keyname: String): Boolean; overload;
Function isKeyDown(key: TKeys): Boolean; overload;
Procedure Start();
Procedure Stop();
Procedure SetSpeed(Speed: integer; AllowFurtherChanges: Boolean = true);
Procedure PlaySound(Filename: String);

Function mouseDragged(Obj_: TGreenfootBase): Boolean;
Function mouseDragEnded(Obj_: TGreenfootBase): Boolean;
Function mouseClicked(Obj_: TGreenfootBase): Boolean;

(*
 * All Routines below this line should never be called by the user !!
 *)
Procedure InitSystem(Callbacks: TCallbacks); // Will be called by the Main App to Register all Needed Callback.
Procedure Keypressed(value: TKeys);
Procedure KeyReleased(value: TKeys);
Procedure ReleaseAllKeys();

Procedure Nop(); // Zum Debuggen, wenn man nen Haltepunkt setzen möchte ..

Implementation

Uses IntfGraphics, LResources, LConvEncoding, LazFileUtils, lazutf8,
  fpImage // TFPColor type
  ;

Const
  CharWidth = 8;
  Charheight = 12;

Type

  TLetter = Array Of Array Of boolean;

  { TGreenFootHelperFont }

  TGreenFootHelperFont = Class // stellt eine Wrapperklasse für das Pixelbasierte Schreiben in FRohdaten zur Verfügung.
  private
    fCharWidth: integer;
    fCharHeight: Integer;
    Letters: Array[0..255] Of TLetter; // Speichert die Punkte Liste der Pixel
    fDefaultHeight: integer;
    Procedure DrawLetter(Const Image: TGreenfootImage; X, Y, Width, Height, Letter: integer);
  public
    Property DefaultHeight: integer read fDefaultHeight;
    Constructor create();
    Destructor destroy(); override;
    Procedure Textout(Image: TGreenfootImage; x, y: Integer; Text: String);
  End;

Var
  GreenFootHelperFont: TGreenFootHelperFont;
  GreenFootCallbacks: TCallbacks;
  VirtualKeys: Array[TKeys] Of boolean;
  RecentKey: TKeys;
  oldMouseState: TMouseStateSet;

Procedure Nop();
Begin

End;

Function FPColorToColor(Const Color: TFPColor): TColor;
Begin
  result := byte(color.red Shr 8) Or (color.green And $FF00) Or ((color.blue And $FF00) Shl 8);
End;

Function getMouseInfo: TMouseInfo;
Begin
  result := MouseInfo;
End;

Function getRandomNumber(limit: integer): integer;
Begin
  result := Randomizer.nextInt(limit);
End;

Operator = (a, b: TGreenFootColor): Boolean;
Begin
  result := (a.Red = b.Red) And
    (a.Green = b.Green) And
    (a.Blue = b.Blue) And
    (a.Alpha = b.Alpha);
End;

Function GetNextUpperPowerOfTwo(Value: Integer): Integer;
Var
  i: Integer;
Begin
  i := 1;
  While i < Value Do
    i := i Shl 1;
  result := i;
End;

Function Color(Red, Green, Blue: byte): TGreenFootColor; overload;
Begin
  result.Red := red;
  result.Green := Green;
  result.Blue := Blue;
  result.Alpha := 255; // Eine Farbe ohne Transparenz ist Opak
End;

Function Color(Red, Green, Blue, Alpha: byte): TGreenFootColor; overload;
Begin
  result.Red := red;
  result.Green := Green;
  result.Blue := Blue;
  result.Alpha := Alpha;
End;

Procedure Go2d(Width, Height: integer);
Begin
  glMatrixMode(GL_PROJECTION);
  glPushMatrix(); // Store The Projection Matrix
  glLoadIdentity(); // Reset The Projection Matrix
  glOrtho(0, Width, height, 0, -1, 1); // Set Up An Ortho Screen
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix(); // Store old Modelview Matrix
  glLoadIdentity(); // Reset The Modelview Matrix
End;

Procedure Exit2d();
Begin
  glMatrixMode(GL_PROJECTION);
  glPopMatrix(); // Restore old Projection Matrix
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix(); // Restore old Projection Matrix
End;

Function mouseDragged(Obj_: TGreenfootBase): Boolean;
Begin
  result := MouseInfo.fOnMouseDownActor = obj_;
End;

Function mouseDragEnded(Obj_: TGreenfootBase): Boolean;
Begin
  result := MouseInfo.fOnMouseUpActor = obj_;
  //  Das Tut noch nicht unbedingt so wie es soll, aber es geht schon ein bischen..
End;

Function mouseClicked(Obj_: TGreenfootBase): Boolean;
Begin
  result := (MS_ButtonsDown In oldMouseState) And
    (Not (MS_ButtonsDown In MouseInfo.fMouseState));
  If result And assigned(obj_) Then Begin
    result := obj_ = MouseInfo.fOnMouseUpActor;
  End;
End;

Procedure InitSystem(Callbacks: TCallbacks);
Begin
  GreenFootCallbacks := Callbacks;
  ReleaseAllKeys();
End;

Procedure Keypressed(value: TKeys);
Begin
  VirtualKeys[value] := true;
  RecentKey := value;
End;

Procedure KeyReleased(value: TKeys);
Begin
  VirtualKeys[value] := false;
  RecentKey := key_None;
End;

Procedure ReleaseAllKeys;
Var
  i: TKeys;
Begin
  For i := low(VirtualKeys) To high(VirtualKeys) Do
    VirtualKeys[i] := false;
  RecentKey := key_None;
End;

Function isKeyDown(keyname: String): Boolean; overload;
Begin
  keyname := lowercase(keyname);
  result := false;
  Case keyname Of
    'up': result := isKeyDown(key_up);
    'down': result := isKeyDown(key_down);
    'left': result := isKeyDown(key_left);
    'right': result := isKeyDown(key_right);
    'space': result := isKeyDown(key_space);
    'a': result := isKeyDown(key_a);
    'b': result := isKeyDown(key_b);
    'c': result := isKeyDown(key_c);
    'd': result := isKeyDown(key_d);
    'e': result := isKeyDown(key_e);
    'f': result := isKeyDown(key_f);
    'g': result := isKeyDown(key_g);
    'h': result := isKeyDown(key_h);
    'i': result := isKeyDown(key_i);
    'j': result := isKeyDown(key_j);
    'k': result := isKeyDown(key_k);
    'l': result := isKeyDown(key_l);
    'm': result := isKeyDown(key_m);
    'n': result := isKeyDown(key_n);
    'o': result := isKeyDown(key_o);
    'p': result := isKeyDown(key_p);
    'q': result := isKeyDown(key_q);
    'r': result := isKeyDown(key_r);
    's': result := isKeyDown(key_s);
    't': result := isKeyDown(key_t);
    'u': result := isKeyDown(key_u);
    'v': result := isKeyDown(key_v);
    'w': result := isKeyDown(key_w);
    'x': result := isKeyDown(key_x);
    'y': result := isKeyDown(key_y);
    'z': result := isKeyDown(key_z);
  End;
End;

Function isKeyDown(key: TKeys): Boolean;
Begin
  result := VirtualKeys[key];
End;

Procedure Start;
Begin
  GreenFootCallbacks.StartEvent(Nil);
End;

Procedure Stop();
Begin
  GreenFootCallbacks.StopEvent(Nil);
End;

Procedure SetSpeed(Speed: integer; AllowFurtherChanges: Boolean = true);
Begin
  GreenFootCallbacks.SpeedCallback(Nil, speed, AllowFurtherChanges);
End;

Procedure PlaySound(Filename: String);
Begin
  // Todo : PlaySound
End;

{ TGreenfootBase }

Constructor TGreenfootBase.create;
Begin
  Inherited create;
  fWidth := 0;
  fHeight := 0;
  fImage := Nil;
  name := Self.ClassName;
End;

Destructor TGreenfootBase.destroy;
Begin

End;

{ TMouseInfo }

Constructor TMouseInfo.create;
Begin
  Inherited create;
  reset;
End;

Function TMouseInfo.getActor: TActor;
Begin
  If assigned(fOnMouseDownActor) Then Begin
    result := fOnMouseDownActor;
  End
  Else Begin
    If assigned(fworld) Then Begin
      result := fworld.getOneObjectAt(fx, fy, Nil);
    End
    Else Begin
      result := Nil;
    End;
  End;
End;

Function TMouseInfo.getButton: TMouseButton;
Begin
  // Todo : TMouseInfo.getButton
  result := fMouseButtonUp;
End;

Function TMouseInfo.getClickCount: integer;
Begin
  // Todo : TMouseInfo.getClickCount
  result := 0;
End;

Function TMouseInfo.getX: integer;
Begin
  result := fx;
End;

Function TMouseInfo.getY: integer;
Begin
  result := fy;
End;

Procedure TMouseInfo.MouseDown(Const World: TWorld; x, y: integer;
  Shift: TShiftState);
//Var
//  img: TGreenfootImage;
Begin
  fOnMouseUpActor := Nil;
  fx := x;
  fy := y;
  fOnMouseDownActor := World.getOneObjectAt(x, y, Nil);
  //  If assigned(fOnMouseDownActor) Then Begin
  //    img := TGreenfootImage.Create(fOnMouseDownActor.getImage());
  //    img.clear();
  //    fOnMouseDownActor.setImage(img);
  //  End;
  fOnMoveActor := fOnMouseDownActor;
  fMouseState := fMouseState + [MS_ButtonsDown];
  fMouseButtonup := MB_None;
  If ssRight In Shift Then Begin
    fMouseButtondown := MB_Right;
  End
  Else Begin
    If ssMiddle In Shift Then Begin
      fMouseButtondown := MB_Middle;
    End
    Else Begin
      If ssLeft In Shift Then Begin
        fMouseButtondown := MB_Left;
      End
      Else Begin
        fMouseButtondown := MB_None;
      End;
    End;
  End;
End;

Procedure TMouseInfo.MouseMove(Const World: TWorld; x, y: integer);
Begin
  fMouseState := fMouseState + [MS_Moving];
  fOnMouseUpActor := Nil;
  fx := x;
  fy := y;
End;

Procedure TMouseInfo.MouseUp;
Begin
  fOnMouseUpActor := fOnMouseDownActor;
  fOnMouseDownActor := Nil;
  fMouseState := fMouseState - [MS_ButtonsDown];
  fMouseButtonup := fMouseButtondown;
End;

Procedure TMouseInfo.Reset;
Begin
  fOnMouseUpActor := Nil;
  fOnMouseDownActor := Nil;
  fWorld := Nil;
  fMouseState := [];
  fMouseButtondown := MB_None;
  fMouseButtonup := MB_None;
End;

{ TGreenFootGraphicEngine }

Constructor TGreenFootGraphicEngine.create();
Begin
  Inherited create;
  setlength(FImages, 0);
  setlength(fNames, 0);
End;

Destructor TGreenFootGraphicEngine.destroy;
Begin
  Clear();
End;

Procedure TGreenFootGraphicEngine.AddImage(Const Image: TGreenfootImage;
  Name: String);
Var
  img: TGreenfootImage;
Begin
  img := FindImage(Name);
  If assigned(img) Then Begin
    Raise exception.create('Error, you are not allowed to add two images with the same name.');
  End;
  Image.fOwnedByGraphikEngine := true;
  setlength(fNames, high(fNames) + 2);
  setlength(FImages, high(FImages) + 2);
  fnames[high(fNames)] := LowerCase(Name);
  FImages[high(FImages)] := Image;
End;

Function TGreenFootGraphicEngine.FindImage(Name: String): TGreenfootImage;
Var
  i: integer;
Begin
  result := Nil;
  name := lowercase(name);
  For i := 0 To high(fNames) Do Begin
    If fNames[i] = Name Then Begin
      result := FImages[i];
      exit;
    End;
  End;
End;

Procedure TGreenFootGraphicEngine.Clear();
Var
  i: Integer;
Begin
  For i := 0 To high(FImages) Do
    FImages[i].Free;
  setlength(FImages, 0);
  setlength(fNames, 0);
End;

{ TGreenfootImage }

Constructor TGreenfootImage.Create(Filename: String);
Var
  b: TBitmap;
  i, j, c: integer;
  IntfImg1: TLazIntfImage;
  col: TFPColor;
Begin
  Inherited create;
  fOwnedByGraphikEngine := false;
  FontSize := GreenFootHelperFont.DefaultHeight;
  fUpdateing := 0;
  fCurrentColor := Color(0, 0, 0, 0);
  b := FileToBitmap(Filename);
  IntfImg1 := TLazIntfImage.Create(0, 0);
  IntfImg1.LoadFromBitmap(B.Handle, B.MaskHandle);
  fOpenGLWidth := GetNextUpperPowerOfTwo(b.Width);
  FOpenGLHeight := GetNextUpperPowerOfTwo(b.Height);
  fWidth := b.Width;
  fHeight := b.Height;
  fWidthHalf := fWidth Div 2;
  fHeightHalf := fHeight Div 2;
  FimageTexCoords[0] := v2(0, fHeight / FOpenGLHeight);
  FimageTexCoords[1] := v2(fWidth / fOpenGLWidth, 0);
  SetLength(FRohdaten, fOpenGLWidth * FOpenGLHeight);
  c := 0;
  For j := 0 To FOpenGLHeight - 1 Do Begin
    For i := 0 To fOpenGLWidth - 1 Do Begin
      If (i < fWidth) And (j < fHeight) Then Begin
        col := IntfImg1.Colors[i, j];
        // Berücksichtigen der Transparenz ( clFuchsia = Durchsichtig )
        If (col.red And $FF00 = $FF00) And
          (col.green And $FF00 = $0000) And
          (col.blue And $FF00 = $FF00) Then Begin
          FRohdaten[c][0] := 0;
          FRohdaten[c][1] := 0;
          FRohdaten[c][2] := 0;
          FRohdaten[c][3] := 0; // Komplett Durchsichtig
        End
        Else Begin
          FRohdaten[c][0] := col.red Div 256;
          FRohdaten[c][1] := col.green Div 256;
          FRohdaten[c][2] := col.blue Div 256;
          FRohdaten[c][3] := 255; // Komplett Opak
        End;
      End
      Else Begin // Bildbereiche Auserhalb des Sichtbaren
        // CLNone
        FRohdaten[c][0] := 0;
        FRohdaten[c][1] := 0;
        FRohdaten[c][2] := 0;
        FRohdaten[c][3] := 0; // Komplett Durchsichtig
      End;
      inc(c);
    End;
  End;
  IntfImg1.free;
  b.free;
  glGenTextures(1, @Fimage);
  glBindTexture(GL_TEXTURE_2D, fimage);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fOpenGLWidth, FOpenGLHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, @FRohdaten[0][0]);
End;

Constructor TGreenfootImage.Create(Width, Height: Integer);
Var
  i: Integer;
Begin
  Inherited create;
  fOwnedByGraphikEngine := false;
  FontSize := GreenFootHelperFont.DefaultHeight;
  fUpdateing := 0;
  fCurrentColor := Color(0, 0, 0, 0);
  fOpenGLWidth := GetNextUpperPowerOfTwo(Width);
  FOpenGLHeight := GetNextUpperPowerOfTwo(Height);
  fWidth := Width;
  fHeight := Height;
  fWidthHalf := fWidth Div 2;
  fHeightHalf := fHeight Div 2;
  FimageTexCoords[0] := v2(0, fHeight / FOpenGLHeight);
  FimageTexCoords[1] := v2(fWidth / fOpenGLWidth, 0);
  setlength(FRohdaten, fOpenGLWidth * FOpenGLHeight);
  For i := 0 To high(FRohdaten) Do Begin
    FRohdaten[i][0] := 0;
    FRohdaten[i][1] := 0;
    FRohdaten[i][2] := 0;
    FRohdaten[i][3] := 0;
  End;
  // Der OpenGL Teil
  glGenTextures(1, @Fimage);
  glBindTexture(GL_TEXTURE_2D, fimage);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fOpenGLWidth, FOpenGLHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, @FRohdaten[0][0]);
End;

Constructor TGreenfootImage.Create(Image: TGreenfootImage);
Var
  i: Integer;
Begin
  Inherited create;
  fOwnedByGraphikEngine := false;
  FontSize := GreenFootHelperFont.DefaultHeight;
  fUpdateing := 0;
  fCurrentColor := Color(0, 0, 0, 0);
  fOpenGLWidth := GetNextUpperPowerOfTwo(image.fWidth);
  FOpenGLHeight := GetNextUpperPowerOfTwo(image.fHeight);
  fWidth := image.fWidth;
  fHeight := image.fHeight;
  fWidthHalf := fWidth Div 2;
  fHeightHalf := fHeight Div 2;
  FimageTexCoords[0] := image.FimageTexCoords[0];
  FimageTexCoords[1] := image.FimageTexCoords[1];
  setlength(FRohdaten, fOpenGLWidth * FOpenGLHeight);
  For i := 0 To high(FRohdaten) Do Begin
    FRohdaten[i][0] := image.FRohdaten[i][0];
    FRohdaten[i][1] := image.FRohdaten[i][1];
    FRohdaten[i][2] := image.FRohdaten[i][2];
    FRohdaten[i][3] := image.FRohdaten[i][3];
  End;
  // Der OpenGL Teil
  glGenTextures(1, @Fimage);
  glBindTexture(GL_TEXTURE_2D, fimage);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fOpenGLWidth, FOpenGLHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, @FRohdaten[0][0]);
End;

Destructor TGreenfootImage.destroy;
Begin
  setlength(FRohdaten, 0);
  glDeleteTextures(1, @fimage);
End;

Function TGreenfootImage.FileToBitmap(Filename: String): TBitmap;
Var
  p: TPortableNetworkGraphic;
  j: TJPEGImage;
Begin
  If Not FileExistsUTF8(Filename) Then Begin
    Raise exception.create('Error could not Find : "' + Filename + '"');
  End;
  result := TBitmap.create;
  If lowercase(ExtractFileExt(filename)) = '.bmp' Then Begin
    result.LoadFromFile(utf8tosys(Filename));
  End
  Else Begin
    If lowercase(ExtractFileExt(filename)) = '.png' Then Begin
      p := TPortableNetworkGraphic.Create;
      p.LoadFromFile(utf8tosys(Filename));
      result.Assign(p);
      p.free;
    End
    Else Begin
      If lowercase(ExtractFileExt(filename)) = '.jpg' Then Begin
        j := TJPEGImage.Create;
        j.LoadFromFile(utf8tosys(Filename));
        result.Assign(j);
        j.free;
      End
      Else Begin
        Raise exception.create('Error unsupported file format : "' + Filename + '"');
      End;
    End;
  End;
End;

Procedure TGreenfootImage.clear;
Var
  i: Integer;
Begin
  fCurrentColor := Color(0, 0, 0, 0);
  For i := 0 To high(FRohdaten) Do Begin
    FRohdaten[i][0] := 0;
    FRohdaten[i][1] := 0;
    FRohdaten[i][2] := 0;
    FRohdaten[i][3] := 0;
  End;
  If fUpdateing = 0 Then Begin
    glBindTexture(GL_TEXTURE_2D, fimage);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexSubImage2D(gl_texture_2d, 0, 0, 0, fOpenGLWidth, FOpenGLHeight, GL_RGBA, GL_UNSIGNED_BYTE, @Frohdaten[0][0]);
  End;
End;

Procedure TGreenfootImage.RePaint;
Var
  b: Boolean;
Begin
  B := glIsEnabled(gl_Blend);
  If Not b Then
    glenable(gl_Blend);
  If Fimage <> 0 Then Begin
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(1, 1, 1, 1);
    glBindTexture(GL_TEXTURE_2D, FImage);
    glBegin(GL_QUADS);
    //    glTexCoord2f(0, 0);
    glTexCoord2f(FimageTexCoords[0].x, FimageTexCoords[1].y);
    glVertex2f(-fWidthHalf, -fHeightHalf);
    //    glTexCoord2f(1, 0);
    glTexCoord2f(FimageTexCoords[1].x, FimageTexCoords[1].y);
    glVertex2f(fWidthHalf + 1, -fHeightHalf);
    //    glTexCoord2f(1, 1);
    glTexCoord2f(FimageTexCoords[1].x, FimageTexCoords[0].y);
    glVertex2f(fWidthHalf + 1, fHeightHalf + 1);
    //    glTexCoord2f(0, 1);
    glTexCoord2f(FimageTexCoords[0].x, FimageTexCoords[0].y);
    glVertex2f(-fWidthHalf, fHeightHalf + 1);
    glend();
  End;
  If Not b Then
    gldisable(gl_Blend);
End;

Procedure TGreenfootImage.Rotate(degrees: integer);
//Var
//  x, y, i, j: integer;
//  tmp: Array Of Array[0..3] Of byte;
Begin
  // Todo : Rotates this image around the center.
 { // Aktuell ist nur ein 90° weises Schlampiges Ding implementiert
  While degrees < 0 Do
    degrees := degrees + 360;
  degrees := degrees Mod 360;
  If degrees = 180 Then Begin

    glDeleteTextures(1, @fimage); // Altes OpenGL Image Löschen
    setlength(tmp, length(FRohdaten));
    // Kopie anlegen
    For i := 0 To high(tmp) Do
      tmp[i] := FRohdaten[i];
    // Drehung Durchführen
    For i := 0 To fWidth * fHeight - 1 Do Begin
      x := i Mod fWidth;
      y := i Div fWidth;
      j := (fHeight - y) * (fOpenGLWidth - 1) + (fWidth - x-1);
      //      j := (fHeight - (i Div fWidth) - 1) * fOpenGLWidth + (i Mod fWidth);
      FRohdaten[i] := tmp[j];
    End;
    glGenTextures(1, @Fimage);
    glBindTexture(GL_TEXTURE_2D, fimage);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fOpenGLWidth, FOpenGLHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, @FRohdaten[0][0]);
  End;}
End;

Procedure TGreenfootImage.Scale(Width, Height: integer);
Type
  tcol = Array[0..3] Of byte;
Var
  tmp: Array Of Array[0..3] Of byte;
  oow: integer;
  ow, oh: integer;

  Function Interpol(x, y: single): tcol;
  Var
    il, ir, jl, jr: integer;
    si, sii, sj, sji: Single;
    c: Array[0..3] Of Array[0..3] Of byte;
  Begin
    // Berechnen der Indicees
    il := trunc(x);
    ir := min(il + 1, ow - 1);
    jl := trunc(y);
    jr := min(jl + 1, oh - 1);
    si := x - il;
    sii := 1 - si;
    sj := y - jl;
    sji := 1 - sj;
    // Auslesen der Farbwerte
    c[0] := tmp[jl * oow + il];
    c[1] := tmp[jl * oow + ir];
    c[2] := tmp[jr * oow + il];
    c[3] := tmp[jr * oow + ir];

    // Senkrechte Interpolation
    c[0][0] := clamp(round(c[2][0] * sj + c[0][0] * sji), 0, 255);
    c[0][1] := clamp(round(c[2][1] * sj + c[0][1] * sji), 0, 255);
    c[0][2] := clamp(round(c[2][2] * sj + c[0][2] * sji), 0, 255);
    c[0][3] := clamp(round(c[2][3] * sj + c[0][3] * sji), 0, 255);

    c[1][0] := clamp(round(c[3][0] * sj + c[1][0] * sji), 0, 255);
    c[1][1] := clamp(round(c[3][1] * sj + c[1][1] * sji), 0, 255);
    c[1][2] := clamp(round(c[3][2] * sj + c[1][2] * sji), 0, 255);
    c[1][3] := clamp(round(c[3][3] * sj + c[1][3] * sji), 0, 255);

    // Waagrechte Interpolation
    c[0][0] := clamp(round(c[1][0] * si + c[0][0] * sii), 0, 255);
    c[0][1] := clamp(round(c[1][1] * si + c[0][1] * sii), 0, 255);
    c[0][2] := clamp(round(c[1][2] * si + c[0][2] * sii), 0, 255);
    c[0][3] := clamp(round(c[1][3] * si + c[0][3] * sii), 0, 255);

    // Ausgabe
    result[0] := c[0][0];
    result[1] := c[0][1];
    result[2] := c[0][2];
    result[3] := c[0][3];
  End;

Var
  c: tcol;
  x, y: Double;
  i, j: Integer;
Begin
  glDeleteTextures(1, @fimage); // Altes OpenGL Image Löschen
  // Anlegen einer Kopie
  tmp := Nil;
  setlength(tmp, high(FRohdaten) + 1);
  For i := 0 To high(tmp) Do Begin
    tmp[i] := FRohdaten[i];
  End;
  oow := fOpenGLWidth;
  ow := fWidth;
  oh := fHeight;
  // neu Reserwieren des Speichers
  fOpenGLWidth := GetNextUpperPowerOfTwo(Width);
  FOpenGLHeight := GetNextUpperPowerOfTwo(Height);
  setlength(FRohdaten, fOpenGLWidth * FOpenGLHeight);
  For i := 0 To high(FRohdaten) Do Begin
    frohdaten[i][0] := 0;
    frohdaten[i][1] := 0;
    frohdaten[i][2] := 0;
    frohdaten[i][3] := 0;
  End;
  fWidth := Width;
  fHeight := Height;
  fWidthHalf := fWidth Div 2;
  fHeightHalf := fHeight Div 2;
  // Umrechnen der Texturkoordinaten, das ist hier so komisch, weil das Bild ja auch Gespiegelt sein Kann..
  If (FimageTexCoords[0].x) <> 0 Then
    FimageTexCoords[0].x := fWidth / fOpenGLWidth;
  If (FimageTexCoords[1].x) <> 0 Then
    FimageTexCoords[1].x := fWidth / fOpenGLWidth;
  If (FimageTexCoords[0].y) <> 0 Then
    FimageTexCoords[0].y := fHeight / FOpenGLHeight;
  If (FimageTexCoords[1].y) <> 0 Then
    FimageTexCoords[1].y := fHeight / FOpenGLHeight;
  // Stretchdraw des Alten auf das Neue (Bilinear Interpoliert)
  For i := 0 To width - 1 Do Begin
    x := ConvertDimension(0, fWidth - 1, i, 0, ow - 1);
    For j := 0 To height - 1 Do Begin
      y := ConvertDimension(0, fHeight - 1, j, 0, oh - 1);
      c := InterPol(x, y);
      FRohdaten[j * fOpenGLWidth + i] := c;
    End;
  End;
  glGenTextures(1, @Fimage);
  glBindTexture(GL_TEXTURE_2D, fimage);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fOpenGLWidth, FOpenGLHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, @FRohdaten[0][0]);
End;

Procedure TGreenfootImage.SetColor(Color: TGreenFootColor);
Begin
  fCurrentColor := Color;
End;

Procedure TGreenfootImage.SetColorAt(x, y: integer; Color: TGreenFootColor);
Var
  d: Array[0..3] Of byte;
Begin
  If (x >= 0) And (x < fWidth) And
    (y >= 0) And (y < fHeight) Then Begin
    d[0] := Color.Red;
    d[1] := Color.Green;
    d[2] := Color.Blue;
    d[3] := Color.Alpha;
    // Übernehmen in den Rohdaten
    FRohdaten[y * fOpenGLWidth + x][0] := color.Red;
    FRohdaten[y * fOpenGLWidth + x][1] := color.Green;
    FRohdaten[y * fOpenGLWidth + x][2] := color.Blue;
    FRohdaten[y * fOpenGLWidth + x][3] := color.Alpha;
    // Übernehmen im OpenGL Puffer
    If fUpdateing = 0 Then Begin
      glEnable(GL_TEXTURE_2D);
      glBindTexture(GL_TEXTURE_2D, fimage);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, @d[0]);
    End;
  End
  Else Begin
    // Bleibt zu Klären ob das hier Sinnvoll ist..
    //Raise Exception.Create('TGreenfootImage.SetColorAt, Error Index out of bounds.');
  End;
End;

Procedure TGreenfootImage.drawImage(Const img: TGreenfootImage; x, y: integer);
Var
  i, j: integer;
  d, c: TGreenFootColor;
Begin
  BeginUpdate();
  For i := 0 To Img.GetWidth - 1 Do
    For j := 0 To img.GetHeight - 1 Do Begin
      c := img.GetColorAt(i, j);
      If c.Alpha <> 0 Then Begin
        d := GetColorAt(i, j);
        // mit, oder Ohne Additivem Blending
        c.Red := clamp((d.Red * (255 - c.Alpha) + c.Red * c.Alpha) Div c.Alpha, 0, 255);
        c.Green := clamp((d.Green * (255 - c.Alpha) + c.Green * c.Alpha) Div c.Alpha, 0, 255);
        c.Blue := clamp((d.Blue * (255 - c.Alpha) + c.Blue * c.Alpha) Div c.Alpha, 0, 255);
        SetColorAt(i + x, j + y, c);
      End;
    End;
  EndUpdate();
End;

Procedure TGreenfootImage.drawLine(x1, y1, x2, y2: integer);
// Implementiert ist der Bresenham Allgorithmus
Var
  x, y, t, dx, dy, incx, incy, pdx, pdy, ddx, ddy, es, el, err: integer;
Begin
  BeginUpdate();
  dx := x2 - x1;
  dy := y2 - y1;
  incx := sign(dx);
  incy := sign(dy);
  If (dx < 0) Then dx := -dx;
  If (dy < 0) Then dy := -dy;
  If (dx > dy) Then Begin
    pdx := incx;
    pdy := 0;
    ddx := incx;
    ddy := incy;
    es := dy;
    el := dx;
  End
  Else Begin
    pdx := 0;
    pdy := incy;
    ddx := incx;
    ddy := incy;
    es := dx;
    el := dy;
  End;
  x := x1;
  y := y1;
  err := el Div 2;
  SetColorAt(x, y, fCurrentColor);
  For t := 0 To el - 1 Do Begin
    err := err - es;
    If (err < 0) Then Begin
      err := err + el;
      x := x + ddx;
      y := y + ddy;
    End
    Else Begin
      x := x + pdx;
      y := y + pdy;
    End;
    SetColorAt(x, y, fCurrentColor);
  End;
  EndUpdate();
End;

Procedure TGreenfootImage.drawOval(x, y, width, height: integer);
Var
  xm, ym, a, b: integer;
  dx, dy, a2, b2, err, e2: integer;
Begin
  BeginUpdate();
  // Init
  xm := x + width Div 2;
  ym := y + height Div 2;
  a := height Div 2;
  b := width Div 2;
  dx := 0;
  dy := b;
  a2 := a * a;
  b2 := b * b;
  err := b2 - (2 * b - 1) * a2; (* Fehler im 1. Schritt *)
  // Paint
  Repeat
    SetColorAt(xm + dx, ym + dy, fCurrentColor); // I. Quadrant */
    SetColorAt(xm - dx, ym + dy, fCurrentColor); // II. Quadrant */
    SetColorAt(xm - dx, ym - dy, fCurrentColor); // III. Quadrant */
    SetColorAt(xm + dx, ym - dy, fCurrentColor); // IV. Quadrant */
    e2 := 2 * err;
    If (e2 < (2 * dx + 1) * b2) Then Begin
      dx := dx + 1;
      err := err + (2 * dx + 1) * b2;
    End;
    If (e2 > -(2 * dy - 1) * a2) Then Begin
      dy := dy - 1;
      err := err - (2 * dy - 1) * a2;
    End;
  Until (dy < 0);

  dx := dx + 1;
  While (dx < a) Do Begin // fehlerhafter Abbruch bei flachen Ellipsen (b=1)
    SetColorAt(xm + dx, ym, fCurrentColor); // -> Spitze der Ellipse vollenden
    SetColorAt(xm - dx, ym, fCurrentColor);
    dx := dx + 1;
  End;
  EndUpdate();
End;

Procedure TGreenfootImage.drawPolygon(xPoints, yPoints: Array Of Integer;
  npoints: integer);
Var
  i, j: integer;
Begin
  BeginUpdate();
  For i := 0 To npoints - 1 Do Begin
    j := (i + 1) Mod npoints;
    drawLine(xpoints[i], ypoints[i], xpoints[j], ypoints[j]);
  End;
  EndUpdate();
End;

Procedure TGreenfootImage.drawRect(x, y, width, height: integer);
Begin
  BeginUpdate();
  // Die Waagrechten
  drawLine(x, y, x + width, y);
  drawLine(x, y + height, x + width, y + height);
  // Die Senkrechten
  drawLine(x, y, x, y + height);
  drawLine(x + width, y, x + width, y + height);
  EndUpdate();
End;

Procedure TGreenfootImage.drawString(String_: String; x, y: integer);
Begin
  BeginUpdate();
  GreenFootHelperFont.Textout(self, x, y - GreenFootHelperFont.fCharHeight, string_);
  EndUpdate();
End;

Procedure TGreenfootImage.fillOval(x, y, width, height: integer);
Var
  xm, ym, a, b: integer;
  dx, dy, a2, b2, err, e2: integer;
  k: integer;
Begin
  BeginUpdate();
  // Init
  xm := x + width Div 2;
  ym := y + height Div 2;
  a := height Div 2;
  b := width Div 2;
  dx := 0;
  dy := b;
  a2 := a * a;
  b2 := b * b;
  err := b2 - (2 * b - 1) * a2; (* Fehler im 1. Schritt *)
  // Paint
  Repeat
    For k := -dx To dx Do Begin
      SetColorAt(xm + k, ym + dy, fCurrentColor);
      SetColorAt(xm + k, ym - dy, fCurrentColor);
    End;
    e2 := 2 * err;
    If (e2 < (2 * dx + 1) * b2) Then Begin
      dx := dx + 1;
      err := err + (2 * dx + 1) * b2;
    End;
    If (e2 > -(2 * dy - 1) * a2) Then Begin
      dy := dy - 1;
      err := err - (2 * dy - 1) * a2;
    End;
  Until (dy < 0);

  dx := dx + 1;
  While (dx < a) Do Begin // fehlerhafter Abbruch bei flachen Ellipsen (b=1)
    SetColorAt(xm + dx, ym, fCurrentColor); // -> Spitze der Ellipse vollenden
    SetColorAt(xm - dx, ym, fCurrentColor);
    dx := dx + 1;
  End;
  EndUpdate();
End;

//Todo : dieser Ansatz scheint besser :  http://www.cse.ohio-state.edu/~gurari/course/cse693s04/cse693s04su77.html
//       Auch ne Beschreibung :          http://www.cs.rit.edu/~icss571/filling/how_to.html
//       Ebenfalls stands im GIS Skript, von da aus wurde es auch schon mal implementiert..

Procedure TGreenfootImage.fillPolygon(xPoints, yPoints: Array Of Integer;
  npoints: integer);
(*
 * Die Implementierte Variante stammt von
 *
 * http://alienryderflex.com/polygon_fill/
 *
 * und wurde entsprechend an FreePascal Angepasst, ebenfalls wurden diverse "Änderungen"
 * Anderungen :
 *              - Unterstützen eines "Freien" Zeichenbereiches
 *              - Rundungsfehler korrigiert ( so dass sie mit dem Bresenham Algorithmus zusammenpassen )
 * vorgenommen.
 *)

Var
  miny, maxy,
    polyCorners, nodes, pixely, i, j, swap: integer;
  nodex: Array Of integer;
Begin
  If (npoints < 3)
    Or (high(xPoints) < npoints - 1)
    Or (high(yPoints) < npoints - 1) Then exit; // It should be at least a triangle, and the Data should Valid
  BeginUpdate();
  // Get the min and max y-Dimension
  miny := yPoints[0];
  maxy := yPoints[0];
  For i := 1 To npoints - 1 Do Begin
    miny := min(miny, yPoints[i]);
    maxy := max(maxy, yPoints[i]);
  End;
  polyCorners := npoints;
  nodex := Nil;
  setlength(nodex, polyCorners);
  For pixely := miny To maxy Do Begin
    //  Build a list of nodes.
    nodes := 0;
    j := polyCorners - 1;
    For i := 0 To polyCorners - 1 Do Begin
      If (((yPoints[i] < pixely) And (yPoints[j] >= pixelY))
        Or ((yPoints[j] < pixely) And (yPoints[i] >= pixelY))) Then Begin
        nodex[nodes] := ceil(xPoints[i] + (pixelY - yPoints[i]) / (yPoints[j] - yPoints[i]) * (xPoints[j] - xPoints[i]));
        inc(nodes);
      End;
      j := i;
    End;
    //  Sort the nodes, via a simple “Bubble” sort.
    i := 0;
    While (i < nodes - 1) Do Begin
      If (nodex[i] > nodex[i + 1]) Then Begin
        swap := nodex[i];
        nodex[i] := nodex[i + 1];
        nodex[i + 1] := swap;
        If (i > 0) Then i := i - 1;
      End
      Else Begin
        i := i + 1;
      End;
    End;
    //  Fill the pixels between node pairs.
    i := 0;
    While (i < nodes) Do Begin
      For j := nodex[i] To nodex[i + 1] - 1 Do Begin
        //canvas.Pixels[j, pixely] := clred;
        SetColorAt(j, pixely, fCurrentColor);
      End;
      inc(i, 2);
    End;
  End;
  setlength(nodex, 0);
  EndUpdate();
End;

Procedure TGreenfootImage.fillRect(x, y, width, height: integer);
Var
  i, j: integer;
Begin
  BeginUpdate();
  For i := 0 To width - 1 Do
    For j := 0 To height - 1 Do Begin
      SetColorAt(x + i, y + j, fCurrentColor);
    End;
  EndUpdate();
End;

Function TGreenfootImage.GetColorAt(x, y: integer): TGreenFootColor;
Var
  i: integer;
Begin
  Begin
    result := color(0, 0, 0, 0);
    If (x >= 0) And (x < FWidth) And
      (y >= 0) And (y < fHeight) Then Begin
      i := y * fOpenGLWidth + x;
      result.Red := FRohdaten[i][0];
      result.Green := FRohdaten[i][1];
      result.Blue := FRohdaten[i][2];
      result.Alpha := FRohdaten[i][3];
    End;
  End;
End;

Function TGreenfootImage.GetHeight: integer;
Begin
  result := fHeight;
End;

Function TGreenfootImage.GetWidth: integer;
Begin
  result := fWidth;
End;

Procedure TGreenfootImage.BeginUpdate;
Begin
  inc(fUpdateing);
End;

Procedure TGreenfootImage.EndUpdate;
Begin
  dec(fUpdateing);
  If fUpdateing = 0 Then Begin // Beim Ende eines Updates wird alles geschrieben
    glBindTexture(GL_TEXTURE_2D, fimage);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexSubImage2D(gl_texture_2d, 0, 0, 0, fOpenGLWidth, FOpenGLHeight, GL_RGBA, GL_UNSIGNED_BYTE, @Frohdaten[0][0]);
  End;
  If fUpdateing < 0 Then Begin
    Raise exception.create('Error you called TGreenfootImage.EndUpdate to often.');
  End;
End;

Procedure TGreenfootImage.mirrorHorizontally;
Var
  tmp: Single;
  i1, i2, i, j: integer;
  r, g, b, a: integer;
Begin
  tmp := FimageTexCoords[0].x;
  FimageTexCoords[0].x := FimageTexCoords[1].x;
  FimageTexCoords[1].x := tmp;
  For j := 0 To fHeight - 1 Do Begin
    For i := 0 To fWidth Div 2 Do Begin
      i1 := j * fOpenGLWidth + i;
      i2 := j * fOpenGLWidth + (fWidth - 1 - i);
      r := FRohdaten[i1][0];
      g := FRohdaten[i1][1];
      b := FRohdaten[i1][2];
      a := FRohdaten[i1][3];
      FRohdaten[i1][0] := FRohdaten[i2][0];
      FRohdaten[i1][1] := FRohdaten[i2][1];
      FRohdaten[i1][2] := FRohdaten[i2][2];
      FRohdaten[i1][3] := FRohdaten[i2][3];
      FRohdaten[i2][0] := r;
      FRohdaten[i2][1] := g;
      FRohdaten[i2][2] := b;
      FRohdaten[i2][3] := a;
    End;
  End;
End;

Function TGreenfootImage.TextWidth(Text: String): integer;
Var
  j: integer;
Begin
  j := 0;
  While pos(#13, text) <> 0 Do Begin
    j := max(j, pos(#13, text) - 1);
    delete(Text, 1, pos(#13, text));
  End;
  j := max(j, length(Text));
  result := j * round(CharWidth * FontSize / Charheight);
End;

Function TGreenfootImage.TextHeight(Text: String): integer;
Var
  i, j: integer;
Begin
  j := 1;
  For i := 1 To length(text) Do Begin
    If (text[i]) = #13 Then inc(j);
  End;
  result := j * FontSize;
End;

{ TGreenFootHelperFont }

Constructor TGreenFootHelperFont.create;
Var
  bitmap: TBitmap;
  TempIntfImg: TLazIntfImage;
  cxc, ax, ay, i, j, k: integer;
  acol: TColor;
Begin
  Inherited create;
  fDefaultHeight := Charheight + 1;
  fCharHeight := Charheight;
  fCharWidth := CharWidth;
  // Laden der Pixeldaten
  Bitmap := TBitmap.Create;
  bitmap.LoadFromLazarusResource('OpenGLFont');
  TempIntfImg := TLazIntfImage.Create(0, 0);
  TempIntfImg.LoadFromBitmap(Bitmap.Handle, Bitmap.MaskHandle);
  cxc := bitmap.Width Div CharWidth;
  For k := 0 To 255 Do Begin
    ax := (k Mod cxc) * CharWidth;
    ay := (k Div cxc) * Charheight;
    SetLength(Letters[k], CharWidth + 1, Charheight + 1);
    For i := 0 To charwidth - 1 Do
      For j := 0 To charheight - 1 Do Begin
        acol := FPColorToColor(TempIntfImg.Colors[ax + i, ay + j]);
        letters[k][i, j] := acol = clwhite;
      End;
    For j := 0 To charheight - 1 Do Begin
      letters[k][CharWidth, j] := false;
    End;
    For i := 0 To charwidth - 1 Do Begin
      letters[k][i, charheight] := false;
    End;
  End;
  TempIntfImg.free;
  bitmap.Free;
End;

Destructor TGreenFootHelperFont.destroy;
Var
  i: Byte;
Begin
  For i := low(letters) To high(Letters) Do
    setlength(letters[i], 0);
End;

(*
 * Zeichnet einen Stretchdraw Buchstaben auf das Bild
 *)

Procedure TGreenFootHelperFont.DrawLetter(Const Image: TGreenfootImage; X, Y, Width, Height, Letter: integer);
Var
  col: TGreenFootColor;

  Function InterPolate(sx, sy: Single; ox, oy: integer): TGreenFootColor;
  Var
    xl, xr, yl, yr: integer;
    scalx, scaly, scalxi, scalyi: single;
    c: Array[0..3] Of TGreenFootColor;
    cl_none: TGreenFootColor;
  Begin
    cl_none := image.GetColorAt(ox, oy);
    xl := trunc(sx);
    xr := min(xl + 1, fCharWidth);
    yl := trunc(sy);
    yr := min(yl + 1, fCharHeight);
    // Wenn Nichts Geglättet werden mus
    If Letters[Letter][xl, yl] And
      Letters[Letter][xr, yl] And
      Letters[Letter][xr, yr] And
      Letters[Letter][xl, yr] Then Begin // Fall 1. Der Pixel ist Voll Sichtbar
      result := col;
      exit;
    End;
    If (Not Letters[Letter][xl, yl]) And
      (Not Letters[Letter][xr, yl]) And
      (Not Letters[Letter][xr, yr]) And
      (Not Letters[Letter][xl, yr]) Then Begin // Fall 2. Der Pixel ist Voll unSichtbar
      result := cl_none;
      exit;
    End;

    If Letters[letter][xl, yl] Then
      c[0] := col
    Else
      c[0] := cl_none;
    If Letters[letter][xr, yl] Then
      c[1] := col
    Else
      c[1] := cl_none;
    If Letters[letter][xl, yr] Then
      c[2] := col
    Else
      c[2] := cl_none;
    If Letters[letter][xr, yr] Then
      c[3] := col
    Else
      c[3] := cl_none;

    scalx := sx - xl;
    scaly := sy - yl;
    scalxi := 1 - scalx;
    scalyi := 1 - scaly;
    // Senkrechte Interpolation
    c[0].Red := clamp(round(c[2].Red * scaly + c[0].Red * scalyi), 0, 255);
    c[0].green := clamp(round(c[2].green * scaly + c[0].green * scalyi), 0, 255);
    c[0].blue := clamp(round(c[2].blue * scaly + c[0].blue * scalyi), 0, 255);
    c[0].alpha := clamp(round(c[2].alpha * scaly + c[0].alpha * scalyi), 0, 255);

    c[1].Red := clamp(round(c[3].Red * scaly + c[1].Red * scalyi), 0, 255);
    c[1].green := clamp(round(c[3].green * scaly + c[1].green * scalyi), 0, 255);
    c[1].blue := clamp(round(c[3].blue * scaly + c[1].blue * scalyi), 0, 255);
    c[1].alpha := clamp(round(c[3].alpha * scaly + c[1].alpha * scalyi), 0, 255);

    // Waagrechte Interpolation
    c[0].Red := clamp(round(c[1].Red * scalx + c[0].Red * scalxi), 0, 255);
    c[0].green := clamp(round(c[1].green * scalx + c[0].green * scalxi), 0, 255);
    c[0].blue := clamp(round(c[1].blue * scalx + c[0].blue * scalxi), 0, 255);
    c[0].alpha := clamp(round(c[1].alpha * scalx + c[0].alpha * scalxi), 0, 255);

    // Ausgabe
    result.Red := c[0].Red;
    result.green := c[0].green;
    result.blue := c[0].blue;
    result.alpha := c[0].alpha;
  End;

Var
  i, j: integer;
  lx, ly: Single;
  rescol: TGreenFootColor;

Begin
  col := Image.fCurrentColor;
  For i := 0 To width - 1 Do Begin
    lx := ConvertDimension(0, width - 1, i, 0, fCharWidth);
    For j := 0 To height - 1 Do Begin
      ly := ConvertDimension(0, Height - 1, j, 0, fCharHeight);
      rescol := InterPolate(lx, ly, x + i, y + j);
      image.SetColorAt(x + i, y + j, resCol);
    End;
  End;
End;

Procedure TGreenFootHelperFont.Textout(Image: TGreenfootImage; x, y: Integer;
  Text: String);
Var
  s: String;
  b: Byte;
  ax, ay: integer;
  cw, i: Integer;
Begin
  s := ConvertEncoding(Text, EncodingUTF8, 'ISO-8859-1'); // Umwandeln in Iso 8859 ( denn so ist Letters Codiert )
  ax := x;
  ay := y;
  cw := round(fCharWidth * Image.FontSize / fCharHeight);
  For i := 1 To length(s) Do Begin
    b := ord(s[i]);
    If b = 13 Then Begin
      ax := x;
      ay := ay + Image.FontSize;
    End;
    // Alles unter 32 ist Unsichtbar.
    // If b >= 32 Then Begin
    If (b <> 13) And (b <> 10) Then Begin
      DrawLetter(Image, ax, ay, cw, Image.FontSize, b);
      ax := ax + cw;
    End;
  End;
End;

{ TRandomizer }

Constructor TRandomizer.create;
Begin
  Inherited create;
  Randomize;
  State := 0;
End;

Procedure TRandomizer.Boxmuller(g1, g2: Double; Out s1, s2: Double);
Var
  r: double;
Begin
  r := g1 * g1 + g2 * g2;
  If (r <= 1.0) And (r <> 0) Then Begin
    s1 := sqrt(-2 * ln(r) / r) * g1;
    s2 := sqrt(-2 * ln(r) / r) * g2;
  End
  Else Begin // Eigentlich darf nun nichts geschehen, aber wir bilden dann einfach auf 0 ab ;)
    s1 := 0;
    s2 := 0;
  End;
End;

Function TRandomizer.nextGaussian: Single;
Begin
  Case State Of
    0: Begin
        // Zwei Normal Verteilte Zahlen zwischen -0.5 und 0.5
        in1 := (random(10000) - 5000) / 5000;
        in2 := (random(10000) - 5000) / 5000;
        Boxmuller(in1, in2, out1, out2);
        result := out1;
        state := 1;
      End;
    1: Begin
        result := out2;
        state := 0;
      End;
  End;
End;

Function TRandomizer.nextInt(limit: Integer): Integer;
Begin
  result := random(limit);
End;

{ TActor }

Constructor TActor.create;
Begin
  Inherited create;
  FisAlive := false;
  fworld := Nil;
  FWorldRotation := 0;
End;

Destructor TActor.destroy;
Begin
  If assigned(FImage) And (Not FImage.fOwnedByGraphikEngine) Then FImage.Free;
  Inherited destroy;
End;

Procedure TActor.act;
Begin
  // Nothing
End;

Procedure TActor.addedToWorld(Const World: TWorld);
Begin
  // Wir Merken uns die Welt der wir Angehören.
End;

Function TActor.getOneObjectAtOffset(dx, dy: integer; cls: TClass): Tactor;
Var
  i: Integer;
  j: Integer;
  ex, ey, ewh, ehh, gy: Integer;
  gx: Integer;
Begin
  result := Nil;
  If assigned(fworld) Then Begin
    gx := (getx + dx) * fworld.fcellsize;
    gy := (gety + dy) * fworld.fcellsize;
    For i := 0 To high(fworld.fSortedClasses) Do Begin
      // Wir haben die Klasse von cls gefunden
      If (cls = Nil) Or (fworld.fSortedClasses[i].Class_.ClassType = cls.ClassType) Then Begin
        For j := 0 To high(fworld.fSortedClasses[i].Elements) Do Begin
          // wir haben das 1. Object gefunden, dass sich an der gesuchten Koordinate befindet
          ex := fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].x * fworld.fcellsize;
          ey := fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].y * fworld.fcellsize;
          ewh := fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor.getWidth Div 2;
          ehh := fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor.getHeight Div 2;
          // Wenn das Zentrum von unserem Object auf der Fläche des Anderen Objectes liegt
          If (fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor <> self) And
            // Wenn das Andere Objelt überhaupt noch Lebt
          (fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor.FisAlive) And
            (gx >= ex - ewh) And (gx <= ex + ewh) And
            (gy >= ey - ehh) And (gy <= ey + ehh) Then Begin
            result := fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor;
            break;
          End;
        End;
        If cls <> Nil Then break;
      End;
    End;
  End;
End;

Procedure TActor.rePaint;
Begin
  If assigned(fImage) Then Begin
    fimage.Repaint();
  End;
End;

Procedure TActor.setImage(Filename: String);
Begin
  If assigned(FImage) And (Not FImage.fOwnedByGraphikEngine) Then FImage.Free;
  fimage := TGreenfootImage.create(Filename);
  fWidth := fimage.GetWidth;
  fHeight := fimage.GetHeight;
End;

Procedure TActor.setImage(Image: TGreenfootImage);
Begin
  If assigned(FImage) And (Not FImage.fOwnedByGraphikEngine) Then Begin
    FImage.Free;
    fImage := TGreenfootImage.Create(Image);
  End
  Else Begin
    fimage := Image;
  End;
  fWidth := image.GetWidth;
  fHeight := image.GetHeight;
End;

Function TActor.getWorld: TWorld;
Begin
  result := fworld;
End;

Function TActor.getx: integer;
Begin
  result := fworld.FObjects[FIndexInWorld].x;
End;

Function TActor.gety: integer;
Begin
  result := fworld.FObjects[FIndexInWorld].y;
End;

Function TActor.getWidth: integer;
Begin
  result := fWidth;
End;

Function TActor.clone: TActor;
Begin
  result := TActor(self.ClassType.create);
  result.create();
End;

Function TActor.intersects(Const Other: TActor): Boolean;
Var
  acty: Integer;
  actx: Integer;
  actw: Integer;
  acth: Integer;
  octy: Integer;
  octx: Integer;
  octw: Integer;
  octh: Integer;
  tl, br: Tvector2;
  otl, obr: Tvector2;
Begin
  result := false;
  If Not assigned(fworld) Or Not assigned(Other) Then Begin
    Raise exception.create('TActor.intersects : Error invalid Arguments, or World not initialized');
    exit;
  End;
  If other = self Then exit; // Wir Kollidieren zwar immer mit uns selbst, aber das interessiert nicht.
  If Not other.FisAlive Then exit; // Wir können nur mit Lebendigen Objekten Kollidieren
  actx := getx * fworld.fcellsize;
  acty := gety * fworld.fcellsize;
  actw := getWidth;
  acth := getHeight;
  tl := v2(actx - actw Div 2, acty - acth Div 2);
  //    br := v2(actx + actw Div 2, acty + acth Div 2);
  br := v2(actx + actw Div 2 - 1, acty + acth Div 2 - 1); // Sonst überlappen sich auch 2 Actoren, welche nur nebeneinander liegen
  octx := other.getx * fworld.fcellsize;
  octy := other.gety * fworld.fcellsize;
  octw := other.getWidth;
  octh := other.getHeight;
  otl := v2(octx - octw Div 2, octy - octh Div 2);
  //    obr := v2(octx + octw Div 2, octy + octh Div 2);
  obr := v2(octx + octw Div 2 - 1, octy + octh Div 2 - 1); // Sonst überlappen sich auch 2 Actoren, welche nur nebeneinander liegen
  result := RectIntersectRect(tl, br, otl, obr);
End;

Function TActor.getOneIntersectingObject(cls: TClass): TActor;
Var
  i, j: integer;
Begin
  result := Nil;
  If Not assigned(fworld) Or Not assigned(cls) Then Begin
    Raise exception.create('TActor.intersects : Error invalid Arguments, or World not initialized');
    exit;
  End;
  For i := 0 To high(fworld.fSortedClasses) Do Begin
    If (cls = Nil) Or (fworld.fSortedClasses[i].Class_.ClassType = cls.ClassType) Then Begin
      For j := 0 To high(fworld.fSortedClasses[i].Elements) Do Begin
        If intersects(fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor) Then Begin
          result := fworld.FObjects[fworld.fSortedClasses[i].Elements[j]].Actor;
          // Wir wollen nur das 1. Objekt, also Fertig.
          break;
        End;
      End;
      // Wenn die Klasse gefunden wurde, gibts keine Weiteren mehr
      If (cls <> Nil) Then
        break;
    End;
  End;
End;

Function TActor.getObjectsInRange(radius: integer; cls: TClass): TActorList;
Var
  i, actx, acty, octy, octx: Integer;
  l: TActorList;
Begin
  result := Nil;
  l := getWorld().getObjects(cls); // Alle Kandidaten hohlen
  actx := getx * fworld.fcellsize;
  acty := gety * fworld.fcellsize;
  For i := 0 To high(l) Do Begin
    If (l[i] <> self) And (l[i].FisAlive) Then Begin // Nur die Lebendigen und nicht uns selbst
      octx := l[i].getx * fworld.fcellsize;
      octy := l[i].gety * fworld.fcellsize;
      If sqr(radius) >= sqr(octx - actx) + sqr(octy - acty) Then Begin // Die die im Range sind
        setlength(result, high(result) + 2);
        result[high(result)] := l[i];
      End;
    End;
  End;
  setlength(l, 0);
End;

Function TActor.getRotation: integer;
Begin
  If assigned(fworld) Then Begin
    result := fworld.FObjects[FIndexInWorld].rotation;
  End
  Else Begin
    Result := FWorldRotation;
  End;
End;

Function TActor.getHeight: integer;
Begin
  result := fHeight;
End;

Function TActor.getImage: TGreenfootImage;
Begin
  result := FImage;
End;

Function TActor.getIntersectingObjects(cls: TClass): TActorList;
Var
  w: TWorld;
  c, i, j: Integer;
Begin
  result := Nil;
  SetLength(result, 100);
  c := 0;
  w := getWorld();
  For j := 0 To high(w.fSortedClasses) Do Begin
    If (cls = Nil) Or (w.fSortedClasses[j].Class_.ClassType = cls) Then Begin
      For i := 0 To high(w.fSortedClasses[j].Elements) Do Begin
        If intersects(w.FObjects[w.fSortedClasses[j].Elements[i]].Actor) Then Begin
          Result[c] := w.FObjects[w.fSortedClasses[j].Elements[i]].Actor;
          inc(c);
          If c > high(result) Then Begin
            setlength(result, high(result) + 101);
          End;
        End;
        If cls <> Nil Then break;
      End;
    End;
  End;
  setlength(result, c);
End;

Function TActor.getNeighbours(distance: integer; diagonal: Boolean; cls: TClass
  ): TActorList;
Var
  w: TWorld;
  ox, oy, x, y, c, i, j: Integer;
  b: Boolean;
Begin
  result := Nil;
  SetLength(result, 100);
  c := 0;
  w := getWorld();
  x := getx;
  y := gety;
  For j := 0 To high(w.fSortedClasses) Do Begin
    If (cls = Nil) Or (w.fSortedClasses[j].Class_.ClassType = cls) Then Begin
      For i := 0 To high(w.fSortedClasses[j].Elements) Do Begin
        If (w.FObjects[w.fSortedClasses[j].Elements[i]].Actor <> self) And
          (w.FObjects[w.fSortedClasses[j].Elements[i]].Actor.FisAlive) Then Begin
          ox := w.FObjects[w.fSortedClasses[j].Elements[i]].Actor.getx;
          oy := w.FObjects[w.fSortedClasses[j].Elements[i]].Actor.gety;
          If diagonal Then Begin
            b := distance >= max(abs(ox - x), abs(oy - y));
          End
          Else Begin
            b := distance >= abs(ox - x) + abs(oy - y);
          End;
          If b Then Begin
            Result[c] := w.FObjects[w.fSortedClasses[j].Elements[i]].Actor;
            inc(c);
            If c > high(result) Then Begin
              setlength(result, high(result) + 101);
            End;
          End;
        End;
      End;
      If cls <> Nil Then break;
    End;
  End;
  setlength(result, c);
End;

Procedure TActor.setLocation(x, y: integer; ThrowExceptionOnLeaveWorld: Boolean
  );
Var
  e: Boolean;
Begin
  e := false;
  If (x < 0) Or (x >= fworld.fworldWidth) Then Begin
    If fworld.fBounded Then Begin
      //      x := Mod2(x, fworld.fworldWidth); // Das würde nen "Wrap Around" machen, bin mir aber nicht sicher das dies gewünscht ist...
    End
    Else Begin
      e := true;
      x := clamp(x, 0, fworld.fworldWidth - 1);
    End;
  End;
  If (y < 0) Or (y >= fworld.fworldHeight) Then Begin
    If fworld.fBounded Then Begin
      //      y := Mod2(y, fworld.fworldHeight); // Das würde nen "Wrap Around" machen, bin mir aber nicht sicher das dies gewünscht ist...
    End
    Else Begin
      e := true;
      y := clamp(y, 0, fworld.fworldHeight - 1);
    End;
  End;
  fworld.FObjects[FIndexInWorld].x := x;
  fworld.FObjects[FIndexInWorld].y := y;
  If e And ThrowExceptionOnLeaveWorld Then Begin
    Raise Exception.create(self.ClassName + '.setLocation : IndexOutOfBounds');
  End;
End;

Procedure TActor.setRotation(rotation: integer);
Begin
  If assigned(fworld) Then Begin
    fworld.FObjects[FIndexInWorld].rotation := Mod2(rotation, 360);
  End
  Else Begin
    FWorldRotation := rotation;
  End;
End;

{ World }

Constructor TWorld.create(Parent: TOpenGLControl; worldWidth, worldHeight,
  cellSize: integer; bounded: Boolean);
Begin
  Inherited create;
  ftoDeleteList := Nil;
  fBounded := bounded;
  fParent := Parent;
  fworldHeight := worldHeight;
  fworldWidth := worldWidth;
  fParent.Width := worldWidth * cellSize;
  fParent.Height := worldHeight * cellSize;
  FWidth := worldWidth * cellSize;
  fHeight := worldHeight * cellSize;
  fcellsize := cellSize;
  fParent.OnResize(self);
  FPaintOrderClasses := Nil;
  FObjects := Nil;
  FActOrderClasses := Nil;
  setlength(FActClasses, 1);
  setlength(FPaintClasses, 1);
End;

Destructor TWorld.destroy;
Var
  i: integer;
Begin
  If assigned(FImage) And (Not FImage.fOwnedByGraphikEngine) Then FImage.Free;
  FImage := Nil;
  // Freigeben der Ordering Informationen
  setlength(FPaintOrderClasses, 0);
  // Freigeben aller Objecte
  For i := 0 To high(FObjects) Do Begin
    FObjects[i].actor.free;
  End;
  setlength(FObjects, 0);
  // Freigeben der SystemAct Informationen
  setlength(FActClasses, 0);
  // Freigeben der "Sortiert" Informationen
  For i := 0 To high(fSortedClasses) Do Begin
    setlength(fSortedClasses[i].Elements, 0);
  End;
  setlength(fSortedClasses, 0);
  setlength(ftoDeleteList, 0);
End;

Procedure TWorld.setBackground(Filename: String);
Begin
  If assigned(FImage) Then FImage.Free;
  Fimage := TGreenfootImage.Create(utf8tosys(Filename));
End;

Procedure TWorld.setBackground(Const Image: TGreenfootImage);
Begin
  Fimage := image;
End;

Procedure TWorld.rePaint;
Var
  i, j: Integer;
Begin
  Go2d(FWidth, fHeight);
  // 1. der Hintergrund
  If assigned(Fimage) Then Begin
    glpushmatrix;
    glTranslatef(-Fimage.fWidth / 2, Fimage.fHeight / 2, 0);
    For j := 1 To (fHeight Div Fimage.fHeight) + 1 Do Begin
      glpushmatrix;
      For i := 1 To (FWidth Div Fimage.fWidth) + 1 Do Begin
        glTranslatef(Fimage.fWidth, 0, 0);
        Fimage.RePaint();
      End;
      glPopMatrix;
      glTranslatef(0, Fimage.fHeight, 0);
    End;
    glPopMatrix;
  End;
  // Nach Reihenfolge Rendern aller Objekte
  For i := high(FPaintClasses) Downto 0 Do Begin // Das Rendern geschieht Rückwärts, damit der Tiefenpuffer Richtig "überschrieben" wird.
    For j := 0 To high(FPaintClasses[i]) Do Begin
      If FObjects[FPaintClasses[i, j]].Actor.FisAlive Then Begin // Nur was Lebt wird auch gezeichnet
        glPushMatrix;
        If fcellsize > 1 Then Begin
          glTranslatef(FObjects[FPaintClasses[i, j]].x * fcellsize + fcellsize Div 2, FObjects[FPaintClasses[i, j]].y * fcellsize + fcellsize Div 2, 0);
        End
        Else Begin
          glTranslatef(FObjects[FPaintClasses[i, j]].x, FObjects[FPaintClasses[i, j]].y, 0);
        End;
        glRotatef(FObjects[FPaintClasses[i, j]].rotation, 0, 0, 1);
        FObjects[FPaintClasses[i, j]].Actor.RePaint();
        glPopMatrix;
      End;
    End;
  End;
  Exit2d();
End;

Procedure TWorld.setPaintOrder(Const Order: Array Of TClass);
Var
  i: Integer;
Begin
  setlength(FPaintOrderClasses, high(Order) + 1);
  setlength(FPaintClasses, high(Order) + 2); // Eines mehr, denn stehts nicht in der Liste, ists "Wurscht" und damit in der geringsten Priorität
  For i := 0 To high(Order) Do Begin
    FPaintOrderClasses[i] := Order[i];
  End;
End;

Procedure TWorld.setActOrder(Const Order: Array Of TClass);
Var
  i: Integer;
Begin
  setlength(FActOrderClasses, high(Order) + 1);
  setlength(FPaintClasses, high(Order) + 2); // Eines mehr, denn stehts nicht in der Liste, ists "Wurscht" und damit in der geringsten Priorität
  For i := 0 To high(Order) Do Begin
    FActOrderClasses[i] := Order[i];
  End;
End;

Procedure TWorld.addObject(Object_: TActor; x, y: integer);
Var
  i: Integer;
  b: Boolean;
Begin
  // Hinzufügen des Objectes
  SetLength(FObjects, high(FObjects) + 2);
  FObjects[high(FObjects)].Actor := Object_;
  FObjects[high(FObjects)].x := x;
  FObjects[high(FObjects)].y := y;
  FObjects[high(FObjects)].rotation := Object_.FWorldRotation;

  // Suchen der PaintOrder
  b := false;
  For i := 0 To high(FPaintOrderClasses) Do Begin
    If Object_.ClassType = FPaintOrderClasses[i].ClassType Then Begin
      setlength(FPaintClasses[i], high(FPaintClasses[i]) + 2);
      FPaintClasses[i][high(FPaintClasses[i])] := high(FObjects);
      b := true;
      break;
    End;
  End;
  // Die Paintreihenfolge konnte nicht bestimmt werden => Eintragen in die Default Gruppe
  If Not b Then Begin
    setlength(FPaintClasses[high(FPaintClasses)], high(FPaintClasses[high(FPaintClasses)]) + 2);
    FPaintClasses[high(FPaintClasses)][high(FPaintClasses[high(FPaintClasses)])] := high(FObjects);
  End;

  // Suchen der SystemAct Order
  b := false;
  For i := 0 To high(FActOrderClasses) Do Begin
    If Object_.ClassType = FActOrderClasses[i].ClassType Then Begin
      setlength(FActClasses[i], high(FActClasses[i]) + 2);
      FActClasses[i][high(FActClasses[i])] := high(FObjects);
      b := true;
      break;
    End;
  End;
  // Die Actreihenfolge konnte nicht bestimmt werden => Eintragen in die Default Gruppe
  If Not b Then Begin
    setlength(FActClasses[high(FActClasses)], high(FActClasses[high(FActClasses)]) + 2);
    FActClasses[high(FActClasses)][high(FActClasses[high(FActClasses)])] := high(FObjects);
  End;

  // Einfügen des Objektes in die Sortiere Liste
  b := false;
  For i := 0 To high(fSortedClasses) Do Begin
    If Object_.ClassType = fSortedClasses[i].Class_.ClassType Then Begin
      setlength(fSortedClasses[i].Elements, high(fSortedClasses[i].Elements) + 2);
      fSortedClasses[i].Elements[high(fSortedClasses[i].Elements)] := high(FObjects);
      b := true;
      break;
    End;
  End;
  // Die sortiertreihenfolge konnte nicht bestimmt werden => Neu anlegen
  If Not b Then Begin
    setlength(fSortedClasses, high(fSortedClasses) + 2);
    setlength(fSortedClasses[high(fSortedClasses)].Elements, 1);
    fSortedClasses[high(fSortedClasses)].Class_ := Object_.ClassType;
    fSortedClasses[high(fSortedClasses)].Elements[0] := high(FObjects);
  End;

  // Dem Object Sagen, dass es nun in der Welt ist.
  Object_.FisAlive := true; // Das Objekt lebt
  Object_.fworld := self; // und gehört zu dieser Welt
  Object_.FIndexInWorld := high(FObjects);
  Object_.addedToWorld(self); // Sollte der User ein "OnAdd" haben wollen, Nutzen dann wird dies hier ausgelöst.
End;

Function TWorld.getBackground: TGreenfootImage;
Begin
  result := Fimage;
End;

Function TWorld.getHeight: integer;
Begin
  result := fworldHeight;
End;

Function TWorld.getCellSize: integer;
Begin
  result := fcellsize;
End;

Function TWorld.getColorAt(x, y: integer): TGreenFootColor;
Begin
  result := color(0, 0, 0, 0);
  If assigned(Fimage) Then Begin
    result := Fimage.GetColorAt(x, y);
  End;
End;

Function TWorld.getOneObject(Object_: TClass): TActor;
Var
  i: integer;
Begin
  result := Nil;
  If Object_ = Nil Then Begin
    If assigned(FObjects) Then Begin
      //    setlength(result, high(FObjects) + 1);
      //    For i := 0 To high(FObjects) Do Begin
      result := FObjects[0].Actor;
    End;
    //    End;
  End
  Else Begin
    For i := 0 To high(fSortedClasses) Do Begin
      If fSortedClasses[i].Class_.ClassType = Object_.ClassType Then Begin
        //        setlength(result, high(fSortedClasses[i].Elements) + 1);
        //        For j := 0 To high(fSortedClasses[i].Elements) Do Begin
        result := FObjects[fSortedClasses[i].Elements[0]].Actor;
        //        End;
        break;
      End;
    End;
  End;
End;

Function TWorld.getObjects(Object_: TClass): TActorList;
Var
  i, j: integer;
Begin
  result := Nil;
  If Object_ = Nil Then Begin
    setlength(result, high(FObjects) + 1);
    For i := 0 To high(FObjects) Do Begin
      result[i] := FObjects[i].Actor;
    End;
  End
  Else Begin
    For i := 0 To high(fSortedClasses) Do Begin
      If fSortedClasses[i].Class_.ClassType = Object_.ClassType Then Begin
        setlength(result, high(fSortedClasses[i].Elements) + 1);
        For j := 0 To high(fSortedClasses[i].Elements) Do Begin
          result[j] := FObjects[fSortedClasses[i].Elements[j]].Actor;
        End;
        break;
      End;
    End;
  End;
End;

Function TWorld.getOneObjectAt(x, y: integer; Object_: TClass): TActor;
Var
  ex, ey, ew, eh, i, j: Integer;
Begin
  result := Nil;
  x := x * fcellsize;
  y := y * fcellsize;
  For i := 0 To high(FPaintClasses) Do Begin
    // Da in der Obersten Klasse alle Elemente unsortiert sind muss hier anders gearbeitet werden.
    If i = high(FPaintClasses) Then Begin
      For j := high(FPaintClasses[i]) Downto 0 Do Begin
        If ((object_ = Nil) Or (FObjects[FPaintClasses[i, j]].Actor.ClassType = Object_.ClassType))
          And (FObjects[FPaintClasses[i, j]].Actor.FisAlive) Then Begin
          ex := FObjects[FPaintClasses[i, j]].x * fcellsize;
          ey := FObjects[FPaintClasses[i, j]].y * fcellsize;
          ew := FObjects[FPaintClasses[i, j]].Actor.getWidth Div 2;
          eh := FObjects[FPaintClasses[i, j]].Actor.getHeight Div 2;
          If (x >= ex - ew) And (x <= ex + ew) And
            (y >= ey - eh) And (y <= ey + eh) Then Begin
            result := FObjects[FPaintClasses[i, j]].Actor;
            exit;
          End;
        End;
      End;
    End
    Else Begin
      // Alle Anderen Klassen sind ja Sortiert nach FPaintOrderClasses;
      If (Object_ = Nil) Or (FPaintOrderClasses[i].ClassType = Object_.ClassType) Then Begin
        For j := high(FPaintClasses[i]) Downto 0 Do Begin
          //          If (object_ = Nil) Or (FObjects[FPaintClasses[i, j]].Actor.ClassType = Object_.ClassType) Then Begin
          If FObjects[FPaintClasses[i, j]].Actor.FisAlive Then Begin
            ex := FObjects[FPaintClasses[i, j]].x * fcellsize;
            ey := FObjects[FPaintClasses[i, j]].y * fcellsize;
            ew := FObjects[FPaintClasses[i, j]].Actor.getWidth Div 2;
            eh := FObjects[FPaintClasses[i, j]].Actor.getHeight Div 2;
            If (x >= ex - ew) And (x <= ex + ew) And
              (y >= ey - eh) And (y <= ey + eh) Then Begin
              result := FObjects[FPaintClasses[i, j]].Actor;
              exit;
            End;
          End;
        End;
        // Es wird sicher nichts mehr gefunden.
        If assigned(Object_) Then exit;
      End;
    End;
  End;
  //  For i := high(fSortedClasses) Downto 0 Do Begin
  //    If (Object_ = Nil) Or (fSortedClasses[i].Class_.ClassType = Object_.ClassType) Then Begin
  //      For j := high(fSortedClasses[i].Elements) Downto 0 Do Begin
  //        ex := FObjects[fSortedClasses[i].Elements[j]].x * fcellsize;
  //        ey := FObjects[fSortedClasses[i].Elements[j]].y * fcellsize;
  //        ew := FObjects[fSortedClasses[i].Elements[j]].Actor.getWidth Div 2;
  //        eh := FObjects[fSortedClasses[i].Elements[j]].Actor.getHeight Div 2;
  //        If (x >= ex - ew) And (x <= ex + ew) And
  //          (y >= ey - eh) And (y <= ey + eh) Then Begin
  //          result := FObjects[fSortedClasses[i].Elements[j]].Actor;
  //          exit;
  //        End;
  //      End;
  //      If assigned(Object_) Then break;
  //    End;
  //  End;
End;

Function TWorld.getObjectsAt(x, y: integer; Object_: TClass): TActorList;
Var
  ex, ey, ew, eh, i, j: Integer;
Begin
  result := Nil;
  x := x * fcellsize;
  y := y * fcellsize;
  For i := 0 To high(fSortedClasses) Do Begin
    If (Object_ = Nil) Or (fSortedClasses[i].Class_.ClassType = Object_.ClassType) Then Begin
      For j := 0 To high(fSortedClasses[i].Elements) Do Begin
        If FObjects[fSortedClasses[i].Elements[j]].Actor.FisAlive Then Begin
          ex := FObjects[fSortedClasses[i].Elements[j]].x * fcellsize;
          ey := FObjects[fSortedClasses[i].Elements[j]].y * fcellsize;
          ew := FObjects[fSortedClasses[i].Elements[j]].Actor.getWidth Div 2;
          eh := FObjects[fSortedClasses[i].Elements[j]].Actor.getHeight Div 2;
          If (x >= ex - ew) And (x <= ex + ew) And
            (y >= ey - eh) And (y <= ey + eh) Then Begin
            setlength(result, high(result) + 2);
            result[high(Result)] := FObjects[fSortedClasses[i].Elements[j]].Actor;
          End;
        End;
      End;
      If assigned(Object_) Then break;
    End;
  End;
End;

Function TWorld.getWidth: integer;
Begin
  result := fworldWidth;
End;

Procedure TWorld.removeObject(Object_: TActor);
Begin
  // Wenn das Objekt noch Existiert, wird es gekillt
  If Object_.FisAlive Then Begin
    // Objekt auf Inaktiv setzen
    Object_.FisAlive := false;
    // Merken, dass es gelöscht werden muss
    setlength(ftoDeleteList, high(ftoDeleteList) + 2);
    ftoDeleteList[high(ftoDeleteList)] := Object_;
  End;
End;

Procedure TWorld.removeObjects(Objectlist: TActorList);
Var
  i: integer;
Begin
  For i := 0 To high(Objectlist) Do Begin
    removeObject(Objectlist[i]);
  End;
  //  If assigned(Objectlist) Then Begin
  //    oh := high(ftoDeleteList) + 1;
  //    setlength(ftoDeleteList, high(ftoDeleteList) + 2 + High(Objectlist));
  //    For i := 0 To high(Objectlist) Do Begin
  //      Objectlist[i].FisAlive := false;
  //      ftoDeleteList[oh + i] := Objectlist[i];
  //    End;
  //  End;
End;

Procedure TWorld.removeObject_helper(Object_: TActor);
Var
  i, j, k: integer;
  oindex: integer;
Begin
  oindex := object_.FIndexInWorld; // Zwecks einfacherer Lesbarkeit

  // 1. Austragen des Objectes aus der Fobjects Liste
  For i := oindex To high(FObjects) - 1 Do Begin
    FObjects[i] := FObjects[i + 1];
    FObjects[i].Actor.FIndexInWorld := i; // Umbiegen des "Index In World"
  End;
  setlength(FObjects, high(FObjects));

  // 2. Entfernen des Objectes aus der Paintorder, und "Verringern" der anderen Pointer
  For i := high(FPaintClasses) Downto 0 Do Begin
    For j := high(FPaintClasses[i]) Downto 0 Do Begin
      // Entfernen des Pointers
      If FPaintClasses[i, j] = oindex Then Begin
        For k := j To high(FPaintClasses[i]) - 1 Do
          FPaintClasses[i, k] := FPaintClasses[i, k + 1];
        setlength(FPaintClasses[i], high(FPaintClasses[i]));
      End
      Else Begin
        // Verringern der "Pointer" oberhalb
        If FPaintClasses[i, j] > oindex Then FPaintClasses[i, j] := FPaintClasses[i, j] - 1;
      End;
    End;
  End;

  // 3. Entfernen des Objectes aus der Actorder, und "Verringern" der anderen Pointer
  For i := high(FActClasses) Downto 0 Do Begin
    For j := high(FActClasses[i]) Downto 0 Do Begin
      // Entfernen des Pointers
      If FActClasses[i, j] = oindex Then Begin
        For k := j To high(FActClasses[i]) - 1 Do
          FActClasses[i, k] := FActClasses[i, k + 1];
        setlength(FActClasses[i], high(FActClasses[i]));
      End
      Else Begin
        // Verringern der "Pointer" oberhalb
        If FActClasses[i, j] > oindex Then FActClasses[i, j] := FActClasses[i, j] - 1;
      End;
    End;
  End;

  // 4. Entfernen des Objectes aus der Sortiert nach Klasse order, und "Verringern" der anderen Pointer
  For i := high(fSortedClasses) Downto 0 Do Begin
    For j := high(fSortedClasses[i].Elements) Downto 0 Do Begin
      // Entfernen des Pointers
      If fSortedClasses[i].Elements[j] = oindex Then Begin
        For k := j To high(fSortedClasses[i].Elements) - 1 Do
          fSortedClasses[i].Elements[k] := fSortedClasses[i].Elements[k + 1];
        setlength(fSortedClasses[i].Elements, high(fSortedClasses[i].Elements));
        // Die Art dieser Klasse gibt es nicht mehr, also wird sie als Gesamtheit gelöscht
        If high(fSortedClasses[i].Elements) = -1 Then Begin
          For k := i To high(fSortedClasses) - 1 Do
            fSortedClasses[k] := fSortedClasses[k + 1];
          setlength(fSortedClasses, high(fSortedClasses));
        End;
      End
      Else Begin
        // Verringern der "Pointer" oberhalb
        If fSortedClasses[i].Elements[j] > oindex Then fSortedClasses[i].Elements[j] := fSortedClasses[i].Elements[j] - 1;
      End;
    End;
  End;

  // 5. Das Object letztendes entfernen
  object_.free;
End;

Procedure TWorld.SystemAct;
Var
  i, j: integer;
Begin
  Act(); // Wir rufen unser eigenes Act auf
  For i := 0 To high(FActClasses) Do Begin
    For j := 0 To high(FActClasses[i]) Do Begin
      If FObjects[FActClasses[i, j]].Actor.FisAlive Then // Nur Lebendige Objekte werden behandelt
        FObjects[FActClasses[i, j]].Actor.Act();
    End;
  End;
  // Abarbeiten der "Zu Löschenden" Liste und diese Objekte tatsächlich Löschen.
  For i := 0 To high(ftoDeleteList) Do Begin
    removeObject_helper(ftoDeleteList[i]);
  End;
  setlength(ftoDeleteList, 0);
  //  MouseInfo.fMouseState := MouseInfo.fMouseState - [MS_Moving];
  oldMouseState := MouseInfo.fMouseState;
End;

Procedure TWorld.Act;
Begin
  // Nichts zu tun
End;

Initialization

{$I greenfoot.ressource}

  Randomizer := TRandomizer.create;
  GreenFootHelperFont := TGreenFootHelperFont.Create;
  GreenFootGraphicEngine := TGreenFootGraphicEngine.create;
  MouseInfo := TMouseInfo.create;

Finalization;

  MouseInfo.free;
  Randomizer.Free;
  GreenFootHelperFont.free;
  GreenFootGraphicEngine.free;

End.

