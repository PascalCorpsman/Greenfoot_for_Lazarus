(*
 * This Unit is the Original Java to FreePascal translation from
 *
 * http://www.greenfoot.org/scenarios/1336
 *
 *
 * Changelog : ver. 0.01 = 1:1 Translation
 *             ver. 0.02 = Minor Changes
 *
 *)
Unit ugol;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  ugreenfoot, OpenGLContext;

Type

  { TCell }

  TCell = Class(TActor) // Müsste fertig sein.
  private
    mystate, mylaststate: Boolean;
    myFirstTime: Boolean;
    mynumNeighbors: integer;
    mybodysize: integer;
    myNeighbors: TActorList;
  public
    Constructor create(); override;
    Constructor create(cellsize: integer); virtual;
    //    Destructor destroy(); override;
    Procedure saveLastState();
    Function getState(): Boolean;
    Procedure flipstate();
    Procedure SetState(state: Boolean);
    Function countNeighbors(): integer;
    Procedure act(); override;
    Procedure ShowState;
    Procedure ApplyRule(); virtual;
  End;

  { TGameOfLifeCell }

  TGameOfLifeCell = Class(TCell)
  private
  public
    Constructor create(cellsize: integer); override;
    Procedure ApplyRule(); override;
  End;

  { TCellularAutomata }

  TCellularAutomata = Class(TWorld) // Müsste fertig sein.
  private
    mycells: Array Of Array Of TCell;
    mywidth, myheight, mycellsize: integer;
    Procedure CreateCells();
    Procedure setInitCellState(Const Cell: TCell);
  public
    Constructor create(Parent: TOpenGLControl);
    Procedure Act(); override;
  End;

Implementation

{ TGameOfLifeCell }

Constructor TGameOfLifeCell.create(cellsize: integer);
Begin
  Inherited create(cellsize);
End;

Procedure TGameOfLifeCell.ApplyRule;
Var
  numNeighborsOn: integer;
  state: Boolean;
Begin
  numNeighborsOn := countNeighbors();
  state := mystate;
  If (numNeighborsOn < 2) Then Begin
    state := false;
  End
  Else Begin
    If (numNeighborsOn > 3) Then Begin
      state := false;
    End
    Else Begin
      If (numNeighborsOn = 3) Then Begin
        state := True;
      End
    End;
  End;
  mystate := state;
End;

{ TCell }

Constructor TCell.create;
Begin
  create(10);
End;

Constructor TCell.create(cellsize: integer);
Var
  img: TGreenfootImage;
Begin
  Inherited create;
  myFirstTime := true;
  mystate := false;
  mylaststate := false;
  img := GreenFootGraphicEngine.FindImage('gol_alive');
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(cellsize, cellsize);
    img.BeginUpdate();
    img.clear();
    img.SetColor(WHITE);
    img.fillRect(1, 1, cellsize - 2, cellsize - 2);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'gol_alive');
  End;
  img := GreenFootGraphicEngine.FindImage('gol_dead');
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(cellsize, cellsize);
    img.BeginUpdate();
    img.clear();
    img.SetColor(black);
    img.fillRect(1, 1, cellsize - 2, cellsize - 2);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'gol_dead');
  End;
  setImage(img);
  myBodySize := cellSize - 2;
  showState();
End;

Procedure TCell.saveLastState;
Begin
  mylaststate := mystate;
End;

Function TCell.getState: Boolean;
Begin
  result := mystate;
End;

Procedure TCell.flipstate;
Begin
  SetState(Not mystate);
End;

Procedure TCell.SetState(state: Boolean);
Begin
  mystate := state;
  ShowState;
End;

Function TCell.countNeighbors: integer;
Var
  sum: integer;
  i: Integer;
Begin
  sum := 0;
  For i := 0 To myNumNeighbors - 1 Do Begin
    If (TCell(myNeighbors[i]).myLastState) Then
      inc(sum);
  End;
  result := sum;
End;

Procedure TCell.act;
Var
  neighbors: TActorList;
  i: Integer;
Begin
  If (myFirstTime) Then Begin
    neighbors := getNeighbours(1, true, self.ClassType);
    myNumNeighbors := length(neighbors);
    //    myNeighbors = new Cell[myNumNeighbors];
    setlength(myNeighbors, myNumNeighbors);
    For i := 0 To myNumNeighbors - 1 Do Begin
      myNeighbors[i] := TCell(neighbors[i]);
    End;
    myFirstTime := false;
  End;
  applyRule();
  showState();
End;

Procedure TCell.ShowState;
Begin
  If mystate Then Begin
    setImage(GreenFootGraphicEngine.FindImage('gol_alive'));
  End
  Else Begin
    setImage(GreenFootGraphicEngine.FindImage('gol_dead'));
  End;
End;

Procedure TCell.ApplyRule;
Begin

End;

{ TCellularAutomata }

Procedure TCellularAutomata.CreateCells();
Var
  i: Integer;
  c: TCell;
  j: Integer;
Begin
  SetLength(mycells, myHeight, mywidth);
  For i := 0 To myheight - 1 Do
    For j := 0 To mywidth - 1 Do Begin
      c := TGameOfLifeCell.create(mycellsize); // Hier wird festgelegt was für eine Art von Zelle das Level befölkern soll
      mycells[i, j] := c;
      setInitCellState(c);
      addObject(c, i, j);
    End;
End;

Procedure TCellularAutomata.setInitCellState(Const Cell: TCell);
Begin
  If getRandomNumber(4) = 0 Then Begin
    cell.setstate(true);
  End;
End;

Constructor TCellularAutomata.create(Parent: TOpenGLControl);
Var
  img: TGreenfootImage;
Begin
  Inherited create(parent, 50, 50, 10);
  myheight := getHeight();
  mywidth := getWidth();
  mycellsize := getCellSize();
  img := TGreenfootImage.Create(mycellsize, mycellsize);
  img.BeginUpdate();
  img.clear();
  img.SetColor(RED);
  img.drawLine(0, 0, mywidth - 1, 0);
  img.drawLine(0, 0, 0, myheight - 1);
  img.EndUpdate();
  setBackground(img);
  CreateCells();
  SetSpeed(10);
End;

Procedure TCellularAutomata.Act();
Var
  i: Integer;
  j: Integer;
Begin
  For i := 0 To myHeight - 1 Do Begin
    For j := 0 To myWidth - 1 Do Begin
      myCells[i][j].saveLastState();
    End;
  End;
End;

End.

