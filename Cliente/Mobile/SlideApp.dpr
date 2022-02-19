program SlideApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'FormMain\uMain.pas' {Frm_Main},
  uBase in 'FormBase\uBase.pas' {FormBase},
  uLogin in 'UN.Login\uLogin.pas' {Frm_Login},
  uClientModule in '..\Lib.DataSnap.Client\uClientModule.pas' {DM_DataSnap: TDataModule},
  Lib_General in '..\Lib.General\Lib_General.pas',
  DS_Functions in '..\Lib.DataSnap.Client\DS_Functions.pas',
  uHome in 'UN.Home\uHome.pas' {Frm_Home},
  uNewMass in 'UN.Mass\uNewMass.pas' {Frm_New_Mass},
  uMass in '..\Classes\uMass.pas',
  uSong in 'UN.Song\uSong.pas' {Frm_Songs},
  uMassList in 'UN.Mass\uMassList.pas' {Frm_Mass};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.CreateForm(TDM_DataSnap, DM_DataSnap);
  Application.Run;
  ReportMemoryLeaksOnShutdown := True;
end.
