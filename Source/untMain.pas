Unit untMain;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls,
  StdCtrls, Buttons, Grids, Spin, ExtCtrls, Utils;

Type
  TfrmMain = Class(TForm)
    ExitBtn: TBitBtn;
    btnDomains: TBitBtn;
    btnBTSolve: TBitBtn;
    pgctlMain: TPageControl;
    tabDefine: TTabSheet;
    mtxGraph: TStringGrid;
    mtxDomain: TStringGrid;
    edtNodeCount: TSpinEdit;
    lblNodeCount: TLabel;
    btnRandomize: TButton;
    tabResult: TTabSheet;
    imgGraph: TPaintBox;
    rdogrpSelectVariable: TRadioGroup;
    rdogrpSelectValue: TRadioGroup;
    mmoSolveLog: TMemo;
    Label1: TLabel;
    btnBTFCSolve: TBitBtn;
    btnArcConsitency: TBitBtn;
    Procedure ExitBtnClick(Sender: TObject);
    Procedure mtxGraphSetEditText(Sender: TObject; ACol, ARow: Integer; Const Value: String);
    Procedure FormCreate(Sender: TObject);
    Procedure btnRandomizeClick(Sender: TObject);
    Procedure edtNodeCountChange(Sender: TObject);
    Procedure imgGraphPaint(Sender: TObject);
    Procedure btnDomainsClick(Sender: TObject);
    Procedure btnBTSolveClick(Sender: TObject);
    Procedure btnAboutClick(Sender: TObject);
    Procedure rdogrpSelectVariableClick(Sender: TObject);
    Procedure rdogrpSelectValueClick(Sender: TObject);
    Procedure btnBTFCSolveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnArcConsitencyClick(Sender: TObject);
  private
    { Private declarations }
    Assignment: TDomainArray;
    PolicyVar: TSelectVarType;
    PolicyDom: TSelectDomType;
  public
    { Public declarations }
  End;

Var
  frmMain: TfrmMain;
  NodeNames: array [0 .. 26] of Char;

Implementation

Uses
  Math, untDomains;

{$R *.dfm}

Procedure TfrmMain.ExitBtnClick(Sender: TObject);
Begin
  Application.Terminate;
End;

Procedure TfrmMain.mtxGraphSetEditText(Sender: TObject; ACol, ARow: Integer; Const Value: String);
Begin
  mtxGraph.Cells[ARow, ACol] := Value;

  mtxGraph.Cells[ARow, ARow] := '';
  mtxGraph.Cells[ACol, ACol] := '';

  imgGraph.Refresh;
End;

Procedure TfrmMain.FormCreate(Sender: TObject);
Var
  Index: Integer;
Begin
  mmoSolveLog.Clear;

  For Index := 0 To High(NodeNames) Do
    NodeNames[Index] := Chr(Index + 64);

  SetLength(Assignment, MaxNode + 1);
  For Index := 0 To MaxNode Do
  Begin
    mtxGraph.Cells[0, Index] := NodeNames[Index];
    mtxGraph.Cells[Index, 0] := NodeNames[Index];
    mtxDomain.Cells[Index, 0] := NodeNames[Index];
    mtxDomain.Cells[0, Index] := NodeNames[Index];
    Assignment[Index] := NullValue;
  End;

  PolicyVar := svFirstLast;
  PolicyDom := sdFirstLast;

  mtxDomain.ColWidths[0] := 16;
End;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  edtNodeCountChange(edtNodeCount);
  btnRandomize.Click;
end;

Procedure TfrmMain.btnRandomizeClick(Sender: TObject);
Var
  Row, Col: Integer;
Begin
  Randomize;

  For Row := 1 To edtNodeCount.Value Do
    For Col := Row + 1 To edtNodeCount.Value Do
      If Random(edtNodeCount.Value) = 0 Then
      Begin
        mtxGraph.Cells[Row, Col] := '1';
        mtxGraph.Cells[Col, Row] := '1';
      End
      Else
      Begin
        mtxGraph.Cells[Row, Col] := '0';
        mtxGraph.Cells[Col, Row] := '0';
      End;

  imgGraph.Refresh;
End;

Procedure TfrmMain.edtNodeCountChange(Sender: TObject);
Var
  Temp, Index: Integer;
Begin
  If edtNodeCount.Value > MaxNode Then
    Exit;

  If TryStrToInt(edtNodeCount.Text, Temp) Then
  Begin
    mtxGraph.RowCount := edtNodeCount.Value + 1;
    mtxGraph.ColCount := edtNodeCount.Value + 1;
    mtxDomain.ColCount := edtNodeCount.Value + 1;
    SetLength(Assignment, edtNodeCount.Value);
    For Index := Low(Assignment) To High(Assignment) Do
      Assignment[Index] := NullValue;
  End;

  imgGraph.Refresh;
End;

Procedure TfrmMain.imgGraphPaint(Sender: TObject);
Var
  I, J: Integer;
  Center: Integer;
  NodeColor: TColor;
  Points: Array [1 .. MaxNode] Of TPoint;
Begin
  If Not TryStrToInt(edtNodeCount.Text, I) Then
    Exit;

  Center := Min(imgGraph.Width, imgGraph.Height) Shr 1;
  For I := 1 To edtNodeCount.Value Do
  Begin
    Points[I].X := Round(Center + (Center - 32) * Sin(I * 2 * PI / edtNodeCount.Value));
    Points[I].Y := Round(Center + (Center - 32) * Cos(I * 2 * PI / edtNodeCount.Value));
  End;

  imgGraph.Canvas.Pen.Width := 2;
  For I := 1 To edtNodeCount.Value Do
  Begin
    For J := I + 1 To edtNodeCount.Value Do
    Begin
      If mtxGraph.Cells[I, J] = '1' Then
      Begin
        imgGraph.Canvas.Pen.Color := clBlack;
        imgGraph.Canvas.MoveTo(Points[I].X, Points[I].Y);
        imgGraph.Canvas.LineTo(Points[J].X, Points[J].Y);
      End;
    End;
  End;

  imgGraph.Canvas.Pen.Width := 1;
  For I := 1 To edtNodeCount.Value Do
  Begin
    imgGraph.Canvas.Pen.Color := clBlack;
    imgGraph.Canvas.Brush.Color := clWhite;
    If Assignment[I - 1] <> NullValue Then
    Begin
      Try
        NodeColor := StringToColor(PrefixColorInDelphi + Assignment[I - 1]);
        imgGraph.Canvas.Brush.Color := NodeColor;
      Except
        imgGraph.Canvas.Ellipse(Points[I].X - Radius, Points[I].Y - Radius, Points[I].X + Radius,
          Points[I].Y + Radius);
        imgGraph.Canvas.Font.Color := clBlack;
        imgGraph.Canvas.TextOut(Points[I].X - Round(imgGraph.Canvas.TextWidth(IntToStr(I)) / 2),
          Points[I].Y - Round(imgGraph.Canvas.TextHeight(IntToStr(I)) / 2),
          IntToStr(I) + ' ' + Assignment[I - 1]);
      End;
    End;

    imgGraph.Canvas.Ellipse(Points[I].X - Radius, Points[I].Y - Radius, Points[I].X + Radius,
      Points[I].Y + Radius);
    imgGraph.Canvas.Font.Color := clBlack;
    imgGraph.Canvas.TextOut(Points[I].X - Round(imgGraph.Canvas.TextWidth(IntToStr(I)) / 2),
      Points[I].Y - Round(imgGraph.Canvas.TextHeight(IntToStr(I)) / 2), NodeNames[I]);
  End;
End;

Procedure TfrmMain.btnDomainsClick(Sender: TObject);
Begin
  frmDomains.ShowModal;
End;

Procedure TfrmMain.btnBTSolveClick(Sender: TObject);
Var
  Index: Integer;
Begin
  SetLength(Assignment, mtxGraph.ColCount - 1);
  For Index := Low(Assignment) To High(Assignment) Do
    Assignment[Index] := NullValue;

  mmoSolveLog.Clear;
  mmoSolveLog.Lines.Add('Begin Of Solving CSP.');
  If BackTracking(Assignment, mtxGraph, mtxDomain, mmoSolveLog.Lines, PolicyVar, PolicyDom) Then
    mmoSolveLog.Lines.Add('End Of Solving CSP.')
  Else
    mmoSolveLog.Lines.Add('CSP not be Solve!.');

  pgctlMain.ActivePage := tabResult;
  imgGraph.Refresh;
End;

Procedure TfrmMain.btnAboutClick(Sender: TObject);
Begin
  MessageDlg('CSP Solver 1.0' + #10#13 + 'AI Project, Tir 1386' + #10#13 + 'ShahabeDanesh Institute'
    + #10#13 + 'h.t.Azeri@GMail.com.' + #10#13#10#13 + 'Programmer: ' + #10#13 +
    '    Hossein Taghi-Zadeh.', mtInformation, [mbOK], 0);
End;

Procedure TfrmMain.rdogrpSelectVariableClick(Sender: TObject);
Begin
  PolicyVar := TSelectVarType(rdogrpSelectVariable.ItemIndex);
End;

Procedure TfrmMain.rdogrpSelectValueClick(Sender: TObject);
Begin
  PolicyDom := TSelectDomType(rdogrpSelectValue.ItemIndex);
End;

Procedure TfrmMain.btnBTFCSolveClick(Sender: TObject);
Var
  Index: Integer;
Begin
  SetLength(Assignment, mtxGraph.ColCount - 1);
  For Index := Low(Assignment) To High(Assignment) Do
    Assignment[Index] := NullValue;

  mmoSolveLog.Clear;
  mmoSolveLog.Lines.Add('Begin Of Solving CSP.');
  If BT_ForwardChecking(Assignment, mtxGraph, mtxDomain, mmoSolveLog.Lines, PolicyVar,
    PolicyDom) Then
    mmoSolveLog.Lines.Add('End Of Solving CSP.')
  Else
    mmoSolveLog.Lines.Add('CSP not be Solve!.');

  pgctlMain.ActivePage := tabResult;

  imgGraph.Refresh;
End;

procedure TfrmMain.btnArcConsitencyClick(Sender: TObject);
Var
  Index: Integer;
Begin
  SetLength(Assignment, mtxGraph.ColCount - 1);
  For Index := Low(Assignment) To High(Assignment) Do
    Assignment[Index] := NullValue;

  mmoSolveLog.Clear;
  mmoSolveLog.Lines.Add('Begin Of Solving CSP.');
  If BT_AC3(Assignment, mtxGraph, mtxDomain, mmoSolveLog.Lines, PolicyVar, PolicyDom) Then
    mmoSolveLog.Lines.Add('End Of Solving CSP.')
  Else
    mmoSolveLog.Lines.Add('CSP not be Solve!.');

  pgctlMain.ActivePage := tabResult;

  imgGraph.Refresh;
End;

End.
