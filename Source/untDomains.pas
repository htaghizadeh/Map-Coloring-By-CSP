Unit untDomains;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList;

Type
  TfrmDomains = Class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lstDomains: TListBox;
    btnDelete: TSpeedButton;
    btnAppend: TSpeedButton;
    btnEdit: TSpeedButton;
    ActionList1: TActionList;
    actAppend: TAction;
    actDelete: TAction;
    actEdit: TAction;
    Procedure btnAppendClick(Sender: TObject);
    Procedure btnDeleteClick(Sender: TObject);
    Procedure btnEditClick(Sender: TObject);
    Procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstDomainsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lstDomainsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure lstDomainsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  End;

Var
  frmDomains: TfrmDomains;
  StartingPoint: TPoint;

Implementation

Uses untMain;

{$R *.dfm}

Procedure TfrmDomains.btnAppendClick(Sender: TObject);
Var
  Temp: String;
Begin
  Temp := InputBox('Domain', 'Please, enter color name', 'Blue');
  If lstDomains.Items.IndexOf(Temp) = -1 Then
    lstDomains.AddItem(Temp, Nil);
End;

Procedure TfrmDomains.btnDeleteClick(Sender: TObject);
Begin
  lstDomains.DeleteSelected;
End;

Procedure TfrmDomains.btnEditClick(Sender: TObject);
Var
  Temp: String;
Begin
  If lstDomains.ItemIndex = -1 Then
    Exit;

  Temp := InputBox('Domain', 'Please, enter color name', lstDomains.Items[lstDomains.ItemIndex]);
  If lstDomains.Items.IndexOf(Temp) = -1 Then
    lstDomains.Items[lstDomains.ItemIndex] := Temp;
End;

Procedure TfrmDomains.btnOKClick(Sender: TObject);
Var
  Col, Row: Integer;
Begin
  frmMain.mtxDomain.RowCount := lstDomains.Count + 1;

  For Col := 1 To frmMain.mtxDomain.ColCount - 1 Do
  Begin
    For Row := 1 To frmMain.mtxDomain.RowCount - 1 Do
    Begin
      frmMain.mtxDomain.Cells[Col, Row] := lstDomains.Items[Row - 1];
    End;
  End;
End;

procedure TfrmDomains.FormShow(Sender: TObject);
begin
  lstDomains.DragMode := dmAutomatic;
end;

procedure TfrmDomains.lstDomainsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DropPosition, StartPosition: Integer;
  DropPoint: TPoint;
begin
  DropPoint.X := X;
  DropPoint.Y := Y;
  with Source as TListBox do
  begin
    StartPosition := ItemAtPos(StartingPoint, True);
    DropPosition := ItemAtPos(DropPoint, True);

    Items.Move(StartPosition, DropPosition);
  end;
end;

procedure TfrmDomains.lstDomainsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := Source = lstDomains;
end;

procedure TfrmDomains.lstDomainsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  StartingPoint.X := X;
  StartingPoint.Y := Y;
end;

End.
