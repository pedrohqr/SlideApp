unit DM_SlideCreator;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DSServer, 
  Datasnap.DSAuth, Datasnap.DSProviderDataModuleAdapter, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, frxClass, frxDBSet,
  frxExportBaseDialog, frxExportPPTX, frxExportPDF, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Phys.IBBase, FireDAC.Comp.UI;

type
  TDSSlideCreator = class(TDSServerModule)
    frxPPTXExport: TfrxPPTXExport;
    frxDBDataset: TfrxDBDataset;
    QuerySlide: TFDQuery;
    frxPDFExport: TfrxPDFExport;
    frxReportPPTX: TfrxReport;
    FDConnection1: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    procedure DSServerModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  DSSlideCreator : TDSSlideCreator;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uDMDB;

{$R *.dfm}

procedure TDSSlideCreator.DSServerModuleCreate(Sender: TObject);
begin
  QuerySlide.Connection := DMDB.FDConn;
end;

end.

