program Demo;

uses
  madExcept,
  madLinkDisAsm,
  Vcl.Forms,
  Form1 in 'Form1.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
