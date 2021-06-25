program Strzelanka_Siekanka_pr;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  { you can add units after this }
  Strzelanka_Siekanka, GLScene_OpenAL;

{$R *.res}

begin

  RequireDerivedFormResource := True;
  Application.Title := 'Strzelanka Siekanka z Eris Kallisti Dyskordia';
  Application.Scaled := True;
  Application.Initialize();
  Application.CreateForm( TStrzelanka_Siekanka_Form, Strzelanka_Siekanka_Form );
  Application.Run();

end.

