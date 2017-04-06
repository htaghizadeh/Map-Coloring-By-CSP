Program AI;

Uses
  Forms,
  untMain In 'untMain.pas' {frmMain},
  Utils In 'Utils.pas',
  untDomains In 'untDomains.pas' {frmDomains};

{$R *.res}

{programmer   hossein taghizadeh}

Begin
  Application.Initialize;
  Application.Title := 'CSP Solver';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmDomains, frmDomains);
  Application.Run;
End.

