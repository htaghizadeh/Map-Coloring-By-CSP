Unit Utils;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls,
  StdCtrls, Buttons, Grids, Spin, ExtCtrls;

Const
  Radius = 12;
  MaxNode = 26;
  NullValue = '';
  NodeConnectValue = '1';
  PrefixColorInDelphi = 'cl';

Type
  NodeType = Integer;
  DomainType = String;

  TArc = Record
    Xi, Xj: NodeType;
  End;

  TArcQueue = Array Of TArc;

  TNodeArray = Array Of NodeType;
  TDomainArray = Array Of DomainType;

  TSelectDomType = (sdFirstLast, sdLastFirst);
  TSelectVarType = (svFirstLast, svLastFirst, svMostDegree, svMRV);

Function BackTracking(Var Assignment: TDomainArray; Const Matrix, Domains: TStringGrid;
  LogList: TStrings; PolicyVar: TSelectVarType; PolicyDom: TSelectDomType): Boolean;
Function BT_ForwardChecking(Var Assignment: TDomainArray; Const Matrix, Domains: TStringGrid;
  LogList: TStrings; PolicyVar: TSelectVarType; PolicyDom: TSelectDomType): Boolean;
Function BT_AC3(Var Assignment: TDomainArray; Const Matrix, Domains: TStringGrid; LogList: TStrings;
  PolicyVar: TSelectVarType; PolicyDom: TSelectDomType): Boolean;

Implementation

uses
  untMain;

var
  tmpDomains: TStringGrid;

function TempDomains: TStringGrid;
begin
  if not Assigned(tmpDomains) then
  begin
    tmpDomains := TStringGrid.Create(Application);
    tmpDomains.ColCount := untMain.frmMain.mtxDomain.ColCount;
    tmpDomains.RowCount := untMain.frmMain.mtxDomain.RowCount;
  end;

  Result := tmpDomains;
end;

procedure CopyMatrix(Src, Dst: TStringGrid);
var
  I, J: Integer;
begin
  for I := 0 to Src.RowCount - 1 do
    for J := 0 to Src.ColCount - 1 do
      Dst.Cells[J, I] := Src.Cells[J, I];
end;

function GetNodeName(Id: Integer): string;
begin
  Result := untMain.NodeNames[Id];
end;

// Result is True, If Node1 and Node2 in matrix graph has been adjacent

Function Neighbor(Node1, Node2: NodeType; Const Matrix: TStringGrid): Boolean;
Begin
  Result := Matrix.Cells[Node1, Node2] = NodeConnectValue;
End;

Function Neighbors(Node: NodeType; Const Matrix: TStringGrid): TNodeArray;
Var
  Index, Len: Integer;
Begin
  Len := 1;
  Index := 1;

  While (Index < Matrix.ColCount) Do
  Begin

    If Neighbor(Node, Index, Matrix) Then
    Begin
      SetLength(Result, Len);
      Result[Len - 1] := Index;
      Inc(Len);
    End;

    Inc(Index);
  End;
End;

Function MostDegree(Const Matrix: TStringGrid; Const Assignment: TDomainArray): NodeType;
Var
  Index, Count: Integer;
Begin
  Count := -2;
  Result := -1;

  For Index := Low(Assignment) + 1 To High(Assignment) + 1 Do
  Begin
    If Trim(Assignment[Index - 1]) <> NullValue Then
      Continue;

    If Count < High(Neighbors(Index, Matrix)) Then
    Begin
      Count := High(Neighbors(Index, Matrix));
      Result := Index;
    End;
  End;

End;

Function MRV(Domains: TStringGrid; Assignment: TDomainArray): NodeType;

  Function CountOfDomainValue(Varaible: NodeType): Integer;
  Var
    Index: Integer;
  Begin
    Result := 0;

    For Index := 1 To Domains.RowCount - 1 Do
      If Domains.Cells[Varaible, Index] <> NullValue Then
        Inc(Result);
  End;

Var
  Index, Count: Integer;
Begin
  Count := Domains.RowCount;
  Result := -1;

  For Index := 1 To Domains.ColCount - 1 Do
  Begin
    If Trim(Assignment[Index - 1]) <> NullValue Then
      Continue;

    If Count > CountOfDomainValue(Index) Then
    Begin
      Count := CountOfDomainValue(Index);
      Result := Index;
    End;
  End;

End;

Function SelectUnassignedVaraible(Const Matrix, Domains: TStringGrid;
  Const Assignment: TDomainArray; Policy: TSelectVarType): NodeType;
Var
  Step: ShortInt;
  Index, LowInd, HighInd: Integer;
Begin
  Step := 1;
  LowInd := Low(Assignment);
  HighInd := High(Assignment) + 1;

  If Policy = svLastFirst Then
  Begin
    Step := -1;
    LowInd := High(Assignment);
    HighInd := Low(Assignment) - 1;
  End;

  If Policy = svMostDegree Then
    Exit(MostDegree(Matrix, Assignment) - 1);

  If Policy = svMRV Then
    Exit(MRV(Domains, Assignment) - 1);

  Index := LowInd;
  Result := Index;
  While Index <> HighInd Do
  Begin
    If Trim(Assignment[Index]) = NullValue Then
      Exit(Index);

    Index := Index + Step;
  End;

End;

Procedure ReplaceValueInDomain(Varaible: NodeType; Const Domains: TStringGrid;
  Const Value, Replace: DomainType);

  Function SearchColumn: Integer;
  Var
    Index: Integer;
  Begin
    Result := -1;

    For Index := 1 To Domains.RowCount - 1 Do
      If Domains.Cells[Varaible + 1, Index] = Value Then
      Begin
        Result := Index;
        Exit;
      End;
  End;

Begin
  If SearchColumn <> -1 Then
    Domains.Cells[Varaible + 1, SearchColumn] := Replace;
End;

Function OrderDomainValues(Varaible: NodeType; Const Domains: TStringGrid; Policy: TSelectDomType)
  : TDomainArray;
Var
  Step: ShortInt;
  Index, LowInd, HighInd, Len: Integer;
Begin
  Len := 1;
  Step := 1;

  LowInd := 1;
  HighInd := Domains.RowCount;

  If Policy = sdLastFirst Then
  Begin
    Step := -1;
    LowInd := Domains.RowCount - 1;
    HighInd := 0;
  End;

  Index := LowInd;

  While Index <> HighInd Do
  Begin

    If Trim(Domains.Cells[Varaible + 1, Index]) <> NullValue Then
    Begin
      SetLength(Result, Len);
      Result[Len - 1] := Trim(Domains.Cells[Varaible + 1, Index]);
      Inc(Len);
    End;
    Index := Index + Step;

  End;
End;

Function IsComplete(Const Assignment: TDomainArray): Boolean;
Var
  Index: Integer;
Begin
  Result := True;

  For Index := Low(Assignment) To High(Assignment) Do
  Begin
    If Trim(Assignment[Index]) = NullValue Then
    Begin
      Result := False;
      Exit;
    End;
  End;
End;

Function IsConsistent(Varaible: NodeType; Const Value: DomainType; Const Assignment: TDomainArray;
  Const Matrix: TStringGrid): Boolean;
Var
  Index: Integer;
  TempNode: TNodeArray;
Begin
  Result := True;

  TempNode := Neighbors(Varaible + 1, Matrix);
  For Index := Low(TempNode) To High(TempNode) Do
  Begin
    If SameText(Assignment[TempNode[Index] - 1], Value) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
End;

Function BackTracking(Var Assignment: TDomainArray; Const Matrix, Domains: TStringGrid;
  LogList: TStrings; PolicyVar: TSelectVarType; PolicyDom: TSelectDomType): Boolean;
Var
  Index: Integer;
  Value: DomainType;
  Varaible: NodeType;
  TempDomain: TDomainArray;
Begin
  If IsComplete(Assignment) Then
  Begin
    Result := True;
    Exit;
  End;

  Varaible := SelectUnassignedVaraible(Matrix, Domains, Assignment, PolicyVar);
  TempDomain := OrderDomainValues(Varaible, Domains, PolicyDom);

  For Index := Low(TempDomain) To High(TempDomain) Do
  Begin
    Value := TempDomain[Index];
    LogList.Add(' Select ' + GetNodeName(Varaible + 1) + ' = ' + Value);
    If IsConsistent(Varaible, Value, Assignment, Matrix) Then
    Begin
      Assignment[Varaible] := Value;
      LogList.Add(' Add  ' + GetNodeName(Varaible + 1) + ' = ' + Value);
      ReplaceValueInDomain(Varaible, Domains, Value, NullValue);
      Result := BackTracking(Assignment, Matrix, Domains, LogList, PolicyVar, PolicyDom);
      If Result Then
        Exit;
      Assignment[Varaible] := NullValue;
      ReplaceValueInDomain(Varaible, Domains, NullValue, Value);

      LogList.Add(' Del ' + GetNodeName(Varaible + 1) + ' = ' + Value);
    End
    Else
      LogList.Add(' DeSelect ' + GetNodeName(Varaible + 1) + ' = ' + Value);

  End;
  Result := False;
End;

Procedure ForwardChecking(Const Varaible: NodeType; Const Value: DomainType;
  Const Matrix, Domains: TStringGrid; LogList: TStrings);
Var
  Index: Integer;
  TempNode: TNodeArray;
Begin
  TempNode := Neighbors(Varaible + 1, Matrix);

  For Index := Low(TempNode) To High(TempNode) Do
  Begin
    ReplaceValueInDomain(TempNode[Index] - 1, Domains, Value, NullValue);
    LogList.Add(' Remove  ' + Value + ' From Domain''s ' + GetNodeName(TempNode[Index]));
  End;
End;

Procedure DeForwardChecking(Const Varaible: NodeType; Const Value: DomainType;
  Const Matrix, Domains: TStringGrid; LogList: TStrings);
Var
  Index: Integer;
  TempNode: TNodeArray;
Begin
  TempNode := Neighbors(Varaible + 1, Matrix);

  For Index := Low(TempNode) To High(TempNode) Do
  Begin
    ReplaceValueInDomain(TempNode[Index] - 1, Domains, NullValue, Value);
    LogList.Add(' Return  ' + Value + ' To Domain''s ' + GetNodeName(TempNode[Index]));
  End;
End;

Function BT_ForwardChecking(Var Assignment: TDomainArray; Const Matrix, Domains: TStringGrid;
  LogList: TStrings; PolicyVar: TSelectVarType; PolicyDom: TSelectDomType): Boolean;
Var
  Index: Integer;
  Value: DomainType;
  Varaible: NodeType;
  TempDomain: TDomainArray;
Begin
  If IsComplete(Assignment) Then
  Begin
    Result := True;
    Exit;
  End;

  Varaible := SelectUnassignedVaraible(Matrix, Domains, Assignment, PolicyVar);
  TempDomain := OrderDomainValues(Varaible, Domains, PolicyDom);

  For Index := Low(TempDomain) To High(TempDomain) Do
  Begin
    Value := TempDomain[Index];
    LogList.Add(' Select ' + GetNodeName(Varaible + 1) + ' = ' + Value);
    If IsConsistent(Varaible, Value, Assignment, Matrix) Then
    Begin
      Assignment[Varaible] := Value;
      LogList.Add(' Add  ' + GetNodeName(Varaible + 1) + ' = ' + Value);
      ReplaceValueInDomain(Varaible, Domains, Value, NullValue);

      ForwardChecking(Varaible, Value, Matrix, Domains, LogList);

      Result := BT_ForwardChecking(Assignment, Matrix, Domains, LogList, PolicyVar, PolicyDom);
      If Result Then
        Exit;
      Assignment[Varaible] := NullValue;
      ReplaceValueInDomain(Varaible, Domains, NullValue, Value);
      LogList.Add(' Del ' + GetNodeName(Varaible + 1) + ' = ' + Value);

      DeForwardChecking(Varaible, Value, Matrix, Domains, LogList);
    End
    Else
      LogList.Add(' DeSelect ' + GetNodeName(Varaible + 1) + ' = ' + Value);

  End;
  Result := False;

End;

Procedure FillQueue(Const Varaible: NodeType; Const Matrix, Domains: TStringGrid;
  Var Queue: TArcQueue); overload;
Var
  Col, Len: Integer;
Begin
  Len := 0;

  For Col := 1 To Matrix.ColCount - 1 Do
    If Neighbor(Col, Varaible + 1, Matrix) Then
    Begin
      Inc(Len);
      SetLength(Queue, Len);
      Queue[Len - 1].Xi := Varaible + 1;
      Queue[Len - 1].Xj := Col;
    End;
End;

Procedure FillQueue(Const Matrix: TStringGrid; Var Queue: TArcQueue); overload;
Var
  Col, Row, Len: Integer;
Begin
  Len := 0;

  For Col := 1 To Matrix.ColCount - 1 Do
    For Row := 1 To Col Do
      If Neighbor(Col, Row, Matrix) Then
      Begin
        Inc(Len);
        SetLength(Queue, Len);
        Queue[Len - 1].Xi := Col;
        Queue[Len - 1].Xj := Row;
      End;
End;

Procedure AddToQueue(var Queue: TArcQueue; Xk, Xi: NodeType);
begin
  SetLength(Queue, Length(Queue) + 1);

  Queue[Length(Queue)].Xi := Xk;
  Queue[Length(Queue)].Xj := Xi;
end;

Procedure RemoveFirst(var Queue: TArcQueue; var Xi, Xj: NodeType);
Var
  Idx: Integer;
begin
  Xi := Queue[0].Xi;
  Xj := Queue[0].Xj;

  For Idx := 1 To High(Queue) Do
  Begin
    Queue[Idx - 1].Xi := Queue[Idx].Xi;
    Queue[Idx - 1].Xj := Queue[Idx].Xj;
  End;

  SetLength(Queue, Length(Queue) - 1);
end;

Function IsEmpty(Queue: TArcQueue): Boolean;
Begin
  Result := Length(Queue) = 0;
End;

Function RemoveInconsistentValues(Xi, Xj: NodeType; Const Domains: TStringGrid;
  PolicyDom: TSelectDomType; LogList: TStrings): Boolean;
Var
  X, Y: DomainType;
  DomainXi, DomainXj: TDomainArray;
  NoValue: Boolean;
Begin
  Result := False;
  DomainXi := OrderDomainValues(Xi - 1, Domains, PolicyDom);
  DomainXj := OrderDomainValues(Xj - 1, Domains, PolicyDom);

  For X in DomainXi Do
  Begin
    NoValue := True;
    For Y in DomainXj Do
      If (Y <> X) Then
      Begin
        NoValue := False;
        Break;
      End;

    if NoValue then
    begin
      ReplaceValueInDomain(Xi - 1, Domains, X, NullValue);
      LogList.Add(Format(' Remove %s from domain''s %s for %s->%s',
        [X, GetNodeName(Xi), GetNodeName(Xi), GetNodeName(Xj)]));
      Result := True;
    end;
  End;
End;

procedure AC_3(Const Matrix, Domains: TStringGrid; Varaible: NodeType; PolicyDom: TSelectDomType;
  LogList: TStrings);
Var
  Queue: TArcQueue;
  Xi, Xj, Xk: NodeType;
  TempNodes: TNodeArray;
Begin
  FillQueue(Varaible, Matrix, Domains, Queue);
  LogList.Add('Starting Arc Consistency.');
  While Not IsEmpty(Queue) Do
  Begin
    RemoveFirst(Queue, Xi, Xj);
    if RemoveInconsistentValues(Xi, Xj, Domains, PolicyDom, LogList) then
    begin
      TempNodes := Neighbors(Xi, Matrix);
      For Xk In TempNodes Do
        AddToQueue(Queue, Xk, Xi);
    End;
  End;
  LogList.Add('Ending Arc Consistency.');
End;

Function BT_AC3(Var Assignment: TDomainArray; Const Matrix, Domains: TStringGrid; LogList: TStrings;
  PolicyVar: TSelectVarType; PolicyDom: TSelectDomType): Boolean;
Var
  Index: Integer;
  Value: DomainType;
  Varaible: NodeType;
  TempDomain: TDomainArray;
Begin
  If IsComplete(Assignment) Then
  Begin
    Result := True;
    Exit;
  End;

  Varaible := SelectUnassignedVaraible(Matrix, Domains, Assignment, PolicyVar);
  TempDomain := OrderDomainValues(Varaible, Domains, PolicyDom);

  For Index := Low(TempDomain) To High(TempDomain) Do
  Begin
    Value := TempDomain[Index];
    LogList.Add(' Select ' + GetNodeName(Varaible + 1) + ' = ' + Value);
    If IsConsistent(Varaible, Value, Assignment, Matrix) Then
    Begin
      Assignment[Varaible] := Value;
      LogList.Add(' Add  ' + GetNodeName(Varaible + 1) + ' = ' + Value);
      ReplaceValueInDomain(Varaible, Domains, Value, NullValue);

      CopyMatrix(Domains, TempDomains);

      AC_3(Matrix, Domains, Varaible, PolicyDom, LogList);

      Result := BT_AC3(Assignment, Matrix, Domains, LogList, PolicyVar, PolicyDom);
      If Result Then
        Exit;
      Assignment[Varaible] := NullValue;
      ReplaceValueInDomain(Varaible, Domains, NullValue, Value);
      LogList.Add(' Del ' + GetNodeName(Varaible + 1) + ' = ' + Value);

      CopyMatrix(TempDomains, Domains);
    End
    Else
      LogList.Add(' DeSelect ' + GetNodeName(Varaible + 1) + ' = ' + Value);

  End;
  Result := False;

End;

End.
