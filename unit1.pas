(******************************************************************************)
(* Greenfoot for Lazarus                                           08.04.2013 *)
(*                                                                            *)
(* Version     : 0.03                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : This Unit implements a Greenfoot like interface for          *)
(*               Lazarus using the fpc compiler and simulating with OpenGL    *)
(*                                                                            *)
(* License     : See the file license.md, located under:                      *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(* Warranty    : There is no warranty, neither in correctness of the          *)
(*               implementation, nor anything other that could happen         *)
(*               or go wrong, use at your own risk.                           *)
(*                                                                            *)
(* Known Issues: none                                                         *)
(*                                                                            *)
(* Howto :                                                                    *)
(*         1. Create a new Unit and include :                                 *)
(*                          SysUtils, ugreenfoot, OpenGLContext               *)
(*                                                                            *)
(* Work within your created unit:                                             *)
(*                                                                            *)
(*         2. Derive a new World from TWorld                                  *)
(*         2.1 Implement whatever you want to implement                       *)
(*                                                                            *)
(*         3. Derive as many Ators from TActor as needed                      *)
(*         3.1 Implement whatever you want to implement                       *)
(*                                                                            *)
(* Work within this unit:                                                     *)
(*                                                                            *)
(*         4. Include your created unit in the uses of this unit              *)
(*                                                                            *)
(*         5. Create a "Creater Routine" in TForm1                            *)
(*              (like shown with CreateAntsAdvanced)                          *)
(*         5.1 Register all components you wrote                              *)
(*              (like shown in CreateAntsAdvanced)                            *)
(*                                                                            *)
(*         6. Edit the "RegisterWorlds" Routine from TForm1 and Register      *)
(*            your Create routine in the System by adding a new line          *)
(*              RegisterWorld('Your Name', @Your Creater Routine);            *)
(*                                                                            *)
(*         7. Compile and Run the application                                 *)
(*                                                                            *)
(* Dokumentation :                                                            *)
(*                                                                            *)
(*         There is no spezial Dokumentation for the Freepascal version.      *)
(*         Instead you can use the original dokumentation.                    *)
(*                                                                            *)
(* Original Dokumentation :                                                   *)
(*      http://www.greenfoot.org/files/javadoc/greenfoot/package-summary.html *)
(*                                                                            *)
(* History     : 0.01 - Initial version                                       *)
(*               0.02 - Ettliche Bugfixes / Memleak Clears                    *)
(*                      utetris                                               *)
(*               0.03 - Shader-Rendering und GTK3, Legacy-Diagnose             *)
(*                                                                            *)
(******************************************************************************)
Unit Unit1;

{$MODE objfpc}{$H+}
{$DEFINE DebuggMode}

Interface

Uses
  Classes, SysUtils, FileUtil, OpenGLContext, Forms, Controls, Graphics,
  Dialogs, Menus, ComCtrls, ExtCtrls, StdCtrls, Buttons, dglopengl,
  ugreenfoot, math, LCLType, LCLIntf, uvectormath,
  (*
   * Insert here your created Unit file
   *)
  uantsadvanced,
  uwombat,
  ulunarlander,
  uballon,
  uminesweeper,
  ugol,
  uprimesnake,
  uspacecommand,
  utetris,
  upacman
  ;

Type

  TActorClass = Class Of TActor; // Helper to handle with actors

  TActorClasses = Array Of Record // Helper to handle with actors
    Class_: TActorClass;
    Name: String;
  End;

  TRegisterMethod = Procedure() Of Object; // Helper to register the Creater Routines

  TRegisteredWorlds = Array Of TRegisterMethod; // Helper to register the Creater Routines

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    OpenGLControl1: TOpenGLControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    Timer2: TTimer;
    TrackBar1: TTrackBar;
    TreeView1: TTreeView;
    TreeView2: TTreeView;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure FormCloseQuery(Sender: TObject; Var CanClose: boolean);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Procedure FormKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Procedure MenuItem4Click(Sender: TObject);
    Procedure OpenGLControl1MakeCurrent(Sender: TObject; Var Allow: boolean);
    Procedure OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    Procedure OpenGLControl1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure OpenGLControl1Paint(Sender: TObject);
    Procedure OpenGLControl1Resize(Sender: TObject);
    Procedure Timer1Timer(Sender: TObject);
    Procedure OnMenuItemClick(Sender: TObject);
    Procedure Timer2Timer(Sender: TObject);
    Procedure TrackBar1Change(Sender: TObject);
  private
    { private declarations }
    Registered_Letters: Array[0..35] Of Boolean; // Die Tastaturshortcuts für das Popupmenu
    mouse: TPoint; // Einige Maus Informationen ( für das Popupmenü )
    World: tworld; // Die Aktuell Erzeugte "Welt"
    ActorClasses: TActorClasses; // Die Aktuell Registrierten Actor Klassen
    RegisterWorldCalls: TRegisteredWorlds;
    LastWorldCreateClick: TRegisterMethod;
    Procedure SetupFrame;
    Procedure ClearLCL; // Löscht alle Vorhandenen "Alten Objecte"
    Procedure CallRegisterWorld(Sender: TObject);
    Procedure RegisterActorClass(Actor: TActorClass; RegisterInPopupMenu: Boolean = true); // Registriert einen Actor in der Treeview
    Procedure RegisterWorld(Name_: String; Method: TRegisterMethod); // Registriert eine einzelne Welt
    Procedure RegisterWorlds(); // Hier werden alle "Welten" registriert.
    Procedure SpeedCallback(Sender: TObject; NewSpeed: integer; Visible_: Boolean);
    Procedure StopCallback(Sender: TObject);
    Procedure StartCallback(Sender: TObject);
  public
    { public declarations }

    (*
     * Insert here your Create Routine Deklarations
     *)

    Procedure CreateAntsAdvanced(); // Initialisiert das Szenario "Ants Advanced"
    Procedure CreateBallon(); // Initialisiert das Szenario "Ballon"
    Procedure CreateLunaLander(); // Initialisiert das Szenario "LunaLander"
    Procedure CreateMinesweeper();
    Procedure CreatePrimeSnake();
    Procedure CreateWombatWorld(); // Initialisiert das Szenario "Wombat"
    Procedure CreateGOL();
    Procedure CreateSpaceCommand();
    Procedure CreateTetris();
    Procedure CreatePacman();
  End;

Var
  Form1: TForm1;
  Initialized: Boolean = false; // Wenn True, dann darf gerendert werden

Implementation

Uses uopengl_graphikengine, uopengl_shaderprimitives, uopengl_legacychecker;

{$R *.lfm}

Procedure OnOpenGLLegacyCall(Severity: GLuint; aMessage: String);
Begin
  Initialized := False;
  ShowMessage('OpenGL Error (' + IntToStr(Severity) + '): ' + aMessage +
    LineEnding + 'Application will be terminated.');
  Halt(1);
End;

(*
 * Insert here your Create Routine Implementation
 *)

Procedure TForm1.CreateAntsAdvanced();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(uantsadvanced.TAnt, false);
  RegisterActorClass(uantsadvanced.TAnthill);
  RegisterActorClass(uantsadvanced.TAntlio);
  RegisterActorClass(uantsadvanced.Tcounter, false);
  RegisterActorClass(uantsadvanced.TFight, false);
  RegisterActorClass(uantsadvanced.TFood);
  RegisterActorClass(uantsadvanced.TPheromone, false);
  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TAntWorld.create(OpenGLControl1);
End;

Procedure TForm1.CreateBallon();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(uballon.TBalloon);
  RegisterActorClass(uballon.TBomb, false);
  RegisterActorClass(uballon.TCounter, false);
  RegisterActorClass(uballon.TDart, false);
  RegisterActorClass(uballon.TExplosion, false);
  RegisterActorClass(uballon.TScoreBoard, false);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)

  world := TBallonWorld.Create(OpenGLControl1);
End;

Procedure TForm1.CreateWombatWorld();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(uwombat.TRock);
  RegisterActorClass(uwombat.TWombat);
  RegisterActorClass(uwombat.TLeaf);
  RegisterActorClass(uwombat.TSheep, false);
  RegisterActorClass(uwombat.TCounter, false);
  RegisterActorClass(uwombat.TScoreBoard, false);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TWombatWorld.create(OpenGLControl1);
End;

Procedure TForm1.CreateGOL();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(ugol.TCell, false);
  RegisterActorClass(ugol.TGameOfLifeCell, false);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TCellularAutomata.create(OpenGLControl1);
End;

Procedure TForm1.CreateSpaceCommand();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(uspacecommand.TBigRock);
  RegisterActorClass(uspacecommand.TCounter, false);
  RegisterActorClass(uspacecommand.TEnemy);
  RegisterActorClass(uspacecommand.TEnemyGunShoot, false);
  RegisterActorClass(uspacecommand.TRock);
  RegisterActorClass(uspacecommand.TSpaceGunShoot, false);
  RegisterActorClass(uspacecommand.TSpaceShip, false);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TSpace.create(OpenGLControl1);
End;

Procedure TForm1.CreateTetris();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(utetris.TWall, False);
  RegisterActorClass(utetris.TBlock, False);
  RegisterActorClass(utetris.TTetromino, False);
  RegisterActorClass(utetris.TITetromino, False);
  RegisterActorClass(utetris.TZTetromino, False);
  RegisterActorClass(utetris.TJTetromino, False);
  RegisterActorClass(utetris.TLTetromino, False);
  RegisterActorClass(utetris.TOTetromino, False);
  RegisterActorClass(utetris.TTTetromino, False);
  RegisterActorClass(utetris.TSTetromino, False);
  RegisterActorClass(utetris.TCounter, False);
  RegisterActorClass(utetris.TScoreBoard, False);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TTetrisWorld.create(OpenGLControl1);
End;

Procedure TForm1.CreatePacman();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TPacmanField.create(OpenGLControl1);
End;

Procedure TForm1.CreateLunaLander();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(ulunarlander.TLander, false);
  RegisterActorClass(ulunarlander.TFlag);
  RegisterActorClass(ulunarlander.TExplosion);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TMoon.create(OpenGLControl1);
End;

Procedure TForm1.CreateMinesweeper();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(uminesweeper.TBomb, false);
  RegisterActorClass(uminesweeper.TCount, false);
  RegisterActorClass(uminesweeper.TCover, false);
  RegisterActorClass(uminesweeper.TFlag, false);
  RegisterActorClass(uminesweeper.TQuestion, false);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *
   * Parameter 2 = Feldbreite
   * Parameter 3 = Feldhöhe
   * Parameter 4 = Anzahl der zu erzeugenden Bomben
   *)
  world := TMineField.create(OpenGLControl1, 9, 9, 10); // Windows Beginner
  //  world := TMineField.create(OpenGLControl1, 16, 16, 40); // Windows Experienced
  //  world := TMineField.create(OpenGLControl1, 30, 16, 99); // Windows Pro
  start();
End;

Procedure TForm1.CreatePrimeSnake();
Begin
  (*
   * Alle Klassen welche in der Treeview und im PopupMenü angezeigt werden sollen müssen hier stehen
   *)
  RegisterActorClass(uprimesnake.TFood, false);
  RegisterActorClass(uprimesnake.TFood2, false);
  RegisterActorClass(uprimesnake.TNum, false);
  RegisterActorClass(uprimesnake.TSnake, false);
  RegisterActorClass(uprimesnake.TSnakeBody, false);
  RegisterActorClass(uprimesnake.TWall, false);

  (*
   * Und zu guter Letzt muss noch die "Welt" erzeugt werden.
   *)
  world := TSnakeWorld.create(OpenGLControl1);
End;

(*
 * Register here your created "Create Routine"
 *)

Procedure TForm1.RegisterWorlds();
Begin
  RegisterWorld('Ants Advanced', @CreateAntsAdvanced);
  RegisterWorld('Ballon', @CreateBallon);
  RegisterWorld('Game of live', @CreateGOL);
  RegisterWorld('Luna Lander', @CreateLunaLander);
  RegisterWorld('Mine sweeper', @CreateMinesweeper);
  RegisterWorld('Prime snake', @CreatePrimeSnake);
  RegisterWorld('Space command', @CreateSpaceCommand);
  RegisterWorld('Tetris', @CreateTetris);
  RegisterWorld('Wombat', @CreateWombatWorld);

  //  RegisterWorld('Pacman', @CreatePacman); // -- Not yet fully ported
End;

(******************************************************************************)
(* Everything below this line is to implement the whole system around. You    *)
(* need not to understand, or to edit anything below.                         *)
(*                                                                            *)
(* Attention, if you change or modify anything below this comment the         *)
(* application could get broken or will not work as expected.                 *)
(******************************************************************************)

{ TForm1 }

Procedure TForm1.FormCreate(Sender: TObject);
Var
  t: TTreeNode;
  c: TCallbacks;
Begin
  // Init dglOpenGL.pas , Teil 1
  If Not InitOpenGl Then Begin
    showmessage('Error, could not init dglOpenGL.pas');
    Halt;
  End;
  OpenGLControl1.AutoResizeViewport := True;
  OpenGLControl1.DebugContext := True;
  Caption := 'Greenfoot for Lazarus ver. 0.03 by Corpsman, www.Corpsman.de';
  Timer1.Interval := 17;
  GroupBox1.Align := alBottom;
  panel1.Align := alright;
  TreeView2.Align := alTop;
  TreeView1.Align := alclient;
  t := TreeView2.Items.AddChild(Nil, 'TWorld');
  TreeView2.Items.AddChild(t, '');
  t.Expand(true);
  RegisterWorlds();
  LastWorldCreateClick := Nil;
  c.StopEvent := @StopCallback;
  c.StartEvent := @StartCallback;
  c.SpeedCallback := @SpeedCallback;
  InitSystem(c);
  OpenGLControl1.Invalidate;
End;

Procedure TForm1.FormDestroy(Sender: TObject);
Begin
  Timer1.Enabled := False;
  Timer2.Enabled := False;
  Initialized := False;
  If OpenGLControl1.MakeCurrent Then Begin
    ClearLCL;
    OpenGL_GraphikEngine_FinalizeShaderSystem;
    OpenGL_ShaderPrimitives_FinalizeShaderSystem;
  End;
  Timer2.Enabled := False;
End;

Procedure TForm1.SetupFrame;
Begin
  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT);
End;

Procedure TForm1.SpeedCallback(Sender: TObject; NewSpeed: integer;
  Visible_: Boolean);
Begin
  TrackBar1.Position := clamp(NewSpeed, 1, 100);
  TrackBar1Change(Nil);
  trackbar1.Visible := Visible_;
End;

Procedure TForm1.StopCallback(Sender: TObject);
Begin
  If Timer2.Enabled Then Begin
    Button2.OnClick(Nil);
    showmessage('Simulation stopped.');
  End;
End;

Procedure TForm1.StartCallback(Sender: TObject);
Begin
  If Not Timer2.Enabled Then Begin
    Button2.OnClick(Nil);
  End;
End;

Procedure TForm1.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState
  );

  Procedure PressKey(Value: TKeys);
  Begin
    Keypressed(Value);
    Key := 0;
  End;

Begin
  // Todo : Hier fehlen noch einige Tastaturereignisse
  If ssShift In Shift Then Keypressed(key_shift);
  If Key = VK_SHIFT Then PressKey(key_shift);
  If Key = VK_UP Then PressKey(key_up);
  If Key = VK_DOWN Then PressKey(key_down);
  If Key = VK_LEFT Then PressKey(key_left);
  If Key = VK_RIGHT Then PressKey(key_right);
  If Key = VK_SPACE Then PressKey(key_space);
  If Key = VK_A Then PressKey(key_a);
  If Key = VK_b Then PressKey(key_b);
  If Key = VK_c Then PressKey(key_c);
  If Key = VK_d Then PressKey(key_d);
  If Key = VK_e Then PressKey(key_e);
  If Key = VK_f Then PressKey(key_f);
  If Key = VK_g Then PressKey(key_g);
  If Key = VK_h Then PressKey(key_h);
  If Key = VK_i Then PressKey(key_i);
  If Key = VK_j Then PressKey(key_j);
  If Key = VK_k Then PressKey(key_k);
  If Key = VK_l Then PressKey(key_l);
  If Key = VK_m Then PressKey(key_m);
  If Key = VK_n Then PressKey(key_n);
  If Key = VK_o Then PressKey(key_o);
  If Key = VK_p Then PressKey(key_p);
  If Key = VK_q Then PressKey(key_q);
  If Key = VK_r Then PressKey(key_r);
  If Key = VK_s Then PressKey(key_s);
  If Key = VK_t Then PressKey(key_t);
  If Key = VK_u Then PressKey(key_u);
  If Key = VK_v Then PressKey(key_v);
  If Key = VK_w Then PressKey(key_w);
  If Key = VK_x Then PressKey(key_x);
  If Key = VK_y Then PressKey(key_y);
  If Key = VK_z Then PressKey(key_z);

  If (sender = TrackBar1) Or (sender = Button1) Or (sender = Button2) Or (sender = Button3) Then key := 0;
End;

Procedure TForm1.FormKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);

  Procedure ReleaseKey(Value: TKeys);
  Begin
    KeyReleased(Value);
    Key := 0;
  End;

Begin
  If ssShift In Shift Then KeyReleased(key_shift);
  If Key = VK_SHIFT Then ReleaseKey(key_shift);
  If Key = VK_UP Then ReleaseKey(key_up);
  If Key = VK_DOWN Then ReleaseKey(key_down);
  If Key = VK_LEFT Then ReleaseKey(key_left);
  If Key = VK_RIGHT Then ReleaseKey(key_right);
  If Key = VK_SPACE Then ReleaseKey(key_space);
  If Key = VK_A Then ReleaseKey(key_a);
  If Key = VK_b Then ReleaseKey(key_b);
  If Key = VK_c Then ReleaseKey(key_c);
  If Key = VK_d Then ReleaseKey(key_d);
  If Key = VK_e Then ReleaseKey(key_e);
  If Key = VK_f Then ReleaseKey(key_f);
  If Key = VK_g Then ReleaseKey(key_g);
  If Key = VK_h Then ReleaseKey(key_h);
  If Key = VK_i Then ReleaseKey(key_i);
  If Key = VK_j Then ReleaseKey(key_j);
  If Key = VK_k Then ReleaseKey(key_k);
  If Key = VK_l Then ReleaseKey(key_l);
  If Key = VK_m Then ReleaseKey(key_m);
  If Key = VK_n Then ReleaseKey(key_n);
  If Key = VK_o Then ReleaseKey(key_o);
  If Key = VK_p Then ReleaseKey(key_p);
  If Key = VK_q Then ReleaseKey(key_q);
  If Key = VK_r Then ReleaseKey(key_r);
  If Key = VK_s Then ReleaseKey(key_s);
  If Key = VK_t Then ReleaseKey(key_t);
  If Key = VK_u Then ReleaseKey(key_u);
  If Key = VK_v Then ReleaseKey(key_v);
  If Key = VK_w Then ReleaseKey(key_w);
  If Key = VK_x Then ReleaseKey(key_x);
  If Key = VK_y Then ReleaseKey(key_y);
  If Key = VK_z Then ReleaseKey(key_z);
  If (sender = TrackBar1) Or (sender = Button1) Or (sender = Button2) Or (sender = Button3) Then key := 0;
End;

Procedure TForm1.FormCloseQuery(Sender: TObject; Var CanClose: boolean);
Begin
  Initialized := false;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  If Not Initialized Then Exit;
  If Not OpenGLControl1.MakeCurrent Then Exit;
  If assigned(world) Then world.SystemAct();
End;

Procedure TForm1.Button2Click(Sender: TObject);
Begin
  Timer2.enabled := Not Timer2.Enabled;
  //  Trackbar1.Enabled := Not Timer2.Enabled;
  If timer2.Enabled Then
    button2.Caption := 'Stop'
  Else
    button2.Caption := 'Start';
  OpenGLControl1.SetFocus;
End;

Procedure TForm1.Button3Click(Sender: TObject);
Begin
  If Not Initialized Then Exit;
  If Not OpenGLControl1.MakeCurrent Then Exit;
  If assigned(LastWorldCreateClick) Then Begin
    ClearLCL;
    LastWorldCreateClick();
  End;
End;

Procedure TForm1.MenuItem4Click(Sender: TObject);
Begin
  close;
End;

Var
  allowcnt: Integer = 0;

Procedure TForm1.OpenGLControl1MakeCurrent(Sender: TObject; Var Allow: boolean);
Begin
  If allowcnt >= 2 Then Begin
    exit;
  End;
  inc(allowcnt);
  // Sollen Dialoge beim Starten ausgeführt werden ist hier der Richtige Zeitpunkt
  If allowcnt = 1 Then Begin
    // Init dglOpenGL.pas , Teil 2
    ReadExtensions; // Anstatt der Extentions kann auch nur der Core geladen werden. ReadOpenGLCore;
    ReadImplementationProperties;
    RegisterLegacyCheckerCallback(@OnOpenGLLegacyCall);
  End;
  If allowcnt = 2 Then Begin
    (*
      Man bedenke, jedesmal wenn der Renderingcontext neu erstellt wird, müssen sämtliche Graphiken neu Geladen werden.
      Bei Nutzung der TOpenGLGraphikengine, bedeutet dies, das hier ein clear durchgeführt werden mus !!
    *)
    OpenGL_GraphikEngine.Clear;
    SetupFrame;
    If Not Assigned(glCreateShader) Then Begin
      ReadExtensions;
      ReadImplementationProperties;
      RegisterLegacyCheckerCallback(@OnOpenGLLegacyCall);
    End;
    If Not Assigned(glCreateShader) Then
      OnOpenGLLegacyCall(0, 'Shader support is required. No legacy fallback.');
    Try
      OpenGL_GraphikEngine_InitializeShaderSystem;
      OpenGL_ShaderPrimitives_InitializeShaderSystem;
    Except
      On ShaderError: Exception Do
        OnOpenGLLegacyCall(0, ShaderError.Message);
    End;
    glDisable(GL_DEPTH_TEST); // Brauchts eigentlich nicht, schadet aber auch nicht
    // Der Anwendung erlauben zu Rendern.
    Initialized := True;
    ReActivateKHRDebug;
    OpenGLControl1Resize(Nil);
  End;
  Form1.Invalidate;
End;

Procedure TForm1.OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  zs: integer;
  nx, ny: integer;
Begin
  If assigned(world) Then Begin
    zs := world.getCellSize();
    nx := x Div zs;
    ny := y Div zs;
    MouseInfo.MouseDown(world, nx, ny, Shift);
    mouse := point(nx, ny);
    //    caption := format('%d %d', [nx,ny]);
  End;
End;

Procedure TForm1.OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
Var
  zs: integer;
Begin
  If assigned(world) Then Begin
    zs := world.getCellSize();
    If zs <> 0 Then Begin
      MouseInfo.MouseMove(world, x Div zs, y Div zs);
    End;
  End;
End;

Procedure TForm1.OpenGLControl1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  If assigned(world) Then Begin
    MouseInfo.MouseUp();
  End;
End;

Procedure TForm1.OpenGLControl1Paint(Sender: TObject);
Begin
  If Not Initialized Then Exit;
  SetupFrame;
  uopengl_graphikengine.Go2d(OpenGLControl1.Width, OpenGLControl1.Height);
  If assigned(World) Then
    world.RePaint();
  uopengl_graphikengine.Exit2d;
  OpenGLControl1.SwapBuffers;
End;

Procedure TForm1.OpenGLControl1Resize(Sender: TObject);
Var
  TargetWidth, TargetHeight: Integer;
Begin
  // Anpassen der Main Form auf die Erstellte Welt
  If Initialized Then Begin
    If Not OpenGLControl1.MakeCurrent Then Exit;
    glViewport(0, 0, OpenGLControl1.Width, OpenGLControl1.Height);
    OpenGLControl1.Invalidate;

    TargetWidth := max(580, OpenGLControl1.Width + 227 + 10);
    TargetHeight := max(350, OpenGLControl1.Height + 43 + GroupBox1.Height);
    If (Width = TargetWidth) And (Height = TargetHeight) Then Exit;

    Constraints.MaxHeight := 0;
    Constraints.MinHeight := 0;
    Constraints.MaxWidth := 0;
    Constraints.MinWidth := 0;
    SetBounds(max(0, (Screen.Width - TargetWidth) Div 2),
      max(0, (Screen.Height - TargetHeight) Div 2), TargetWidth, TargetHeight);
    Constraints.MaxHeight := Height;
    Constraints.MinHeight := Height;
    Constraints.MaxWidth := Width;
    Constraints.MinWidth := Width;
  End;
End;

Procedure TForm1.Timer1Timer(Sender: TObject);
{$IFDEF DebuggMode}
Var
  i: Cardinal;
  p: Pchar;
{$ENDIF}
Begin
  If Initialized Then Begin
    OpenGLControl1.Invalidate;
{$IFDEF DebuggMode}
    If Not OpenGLControl1.MakeCurrent Then Exit;
    i := glGetError();
    If i <> 0 Then Begin
      Timer1.Enabled := false;
      p := gluErrorString(i);
      OnOpenGLLegacyCall(i, String(p));
    End;
{$ENDIF}
  End;
End;

Procedure TForm1.OnMenuItemClick(Sender: TObject);
Var
  i: integer;
  a: TActor;
Begin
  If Not Initialized Then Exit;
  If Not OpenGLControl1.MakeCurrent Then Exit;
  If sender Is TMenuItem Then Begin
    i := (sender As TMenuItem).Tag;
    If (i >= 0) And (i <= high(ActorClasses)) Then Begin
      a := ActorClasses[i].Class_.create();
      World.AddObject(a, mouse.x, mouse.y);
    End;
  End;
End;

Procedure TForm1.Timer2Timer(Sender: TObject);
//Var
//  t: Dword;
Begin
  If Not Initialized Then Exit;
  If Not OpenGLControl1.MakeCurrent Then Exit;
  //  t := gettickcount;
  If assigned(world) Then
    world.SystemAct();
  //  t := GetTickCount - t;
  //  caption := inttostr(t);
End;

Procedure TForm1.TrackBar1Change(Sender: TObject);
Begin
  Timer2.interval := 1000 Div TrackBar1.Position;
  //Timer2.interval := TrackBar1.Position;
End;

Procedure TForm1.CallRegisterWorld(Sender: TObject);
Var
  i: integer;
Begin
  If Not Initialized Then Exit;
  If Not OpenGLControl1.MakeCurrent Then Exit;
  If Sender Is TMenuItem Then Begin
    i := TMenuItem(sender).tag;
    If (i >= 0) And (i <= high(RegisterWorldCalls)) Then Begin
      ClearLCL;
      LastWorldCreateClick := RegisterWorldCalls[i];
      RegisterWorldCalls[i]();
      TreeView2.Items[1].Text := world.ClassName;
    End;
  End;
End;

Procedure TForm1.RegisterWorld(Name_: String; Method: TRegisterMethod);
Var
  t: TMenuItem;
Begin
  t := TMenuItem.Create(MainMenu1);
  t.Caption := name_;
  t.OnClick := @CallRegisterWorld;
  setlength(RegisterWorldCalls, high(RegisterWorldCalls) + 2);
  RegisterWorldCalls[high(RegisterWorldCalls)] := Method;
  t.Tag := high(RegisterWorldCalls);
  MenuItem2.Add(t);
End;

Procedure TForm1.RegisterActorClass(Actor: TActorClass;
  RegisterInPopupMenu: Boolean);

Const
  ShortCut = '&&&'; // Todo : Eigentlich sollte das nur ein & sein, aber das scheint wohl ein Bug in der LCL zu sein, wenn der Gefixt ist, dann muss das her entsprechend auf '&' reduziert werden.

  Function TryInsertShortCutLetter(Value: String): String;
  Var
    i: integer;
  Begin
    If value <> '' Then Begin
      i := 1;
      If lowercase(value[1]) = 't' Then i := 2; // Ein Guter Programmierer Beginnt mit Txxx, das T überspringen wir, sollte es da sein.
      While i < length(Value) Do Begin
        If lowercase(value[i]) In ['a'..'z', '0'..'9'] Then Begin
          If lowercase(value[i]) In ['a'..'z'] Then Begin
            If Not Registered_Letters[ord(lowercase(value[i])) - ord('a')] Then Begin
              Registered_Letters[ord(lowercase(value[i])) - ord('a')] := true;
              insert(ShortCut, Value, i);
              i := length(value) + 1;
            End;
          End;
          If (i <= length(value)) And (lowercase(value[i]) In ['0'..'9']) Then Begin
            If Not Registered_Letters[ord(lowercase(value[i])) - ord('0')] Then Begin
              Registered_Letters[ord(lowercase(value[i])) - ord('0')] := true;
              insert(ShortCut, Value, i);
              i := length(value) + 1;
            End;
          End;
        End;
        inc(i);
      End;
    End;
    result := value;
  End;

Var
  t: TTreeNode;
  i: TMenuItem;
  s: String;
Begin
  // Todo : Wenn zuerst eine KindKlasse eingefügt wird, und Später seine Elternklasse, dann stimmt die Ausgabe nicht ( siehe TEnemyGunShoot )

  // Eintragen der ActorKlasse in die "Creater" Liste
  setlength(ActorClasses, high(ActorClasses) + 2);
  ActorClasses[high(ActorClasses)].Class_ := Actor;
  ActorClasses[high(ActorClasses)].Name := actor.ClassType.ClassName;
  // Eintrgen der ActorKlasse in die Treeview
  t := TreeView1.Items.FindNodeWithText(actor.ClassParent.ClassType.ClassName); // Suchen des "Vater" Knoten
  TreeView1.Items.AddChild(t, actor.ClassType.ClassName);
  // Dafür sorgen dass alle TreeNodes Sichtbar sind.
  TreeView1.items[0].Expand(true);
  // Die Klasse im Popup Menü eintragen
  If (RegisterInPopupMenu) Then Begin
    i := TMenuItem.Create(PopupMenu1);
    s := actor.ClassType.ClassName;
    s := TryInsertShortCutLetter(s);
    i.Caption := 'Create "' + s + '" here.';
    i.Tag := high(ActorClasses);
    i.OnClick := @OnMenuItemClick;
    PopupMenu1.Items.Add(i);
  End;
End;

Procedure TForm1.ClearLCL;
Var
  i: integer;
Begin
  If Not OpenGLControl1.MakeCurrent Then Exit;
  If Assigned(World) Then World.Free;
  World := Nil;
  GreenFootGraphicEngine.Clear();
  For i := low(Registered_Letters) To high(Registered_Letters) Do
    Registered_Letters[i] := false;
  timer2.Enabled := true;
  Button2Click(Nil);
  PopupMenu1.Items.Clear;
  TreeView1.Items.Clear;
  TreeView1.Items.AddChild(Nil, 'TActor'); // Den "Anker" eintragen.
  setlength(ActorClasses, 0);
  TrackBar1.Visible := true;
  MouseInfo.Reset();
  ReleaseAllKeys();
End;

End.

