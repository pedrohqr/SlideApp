unit DM_SlideCreator;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DSServer, 
  Datasnap.DSAuth, Datasnap.DSProviderDataModuleAdapter, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, frxDBSet,
  frxExportBaseDialog, frxExportPPTX, frxExportPDF, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Phys.IBBase, FireDAC.Comp.UI,
  frxClass;

type
  TDSSlideCreator = class(TDSServerModule)
    frxPPTXExport: TfrxPPTXExport;
    frxDBDS_Song1: TfrxDBDataset;
    frxReportPPTX: TfrxReport;
    frxDBDS_Mass: TfrxDBDataset;
    frxDBDS_Song2: TfrxDBDataset;
    frxDBDS_Song3: TfrxDBDataset;
    frxDBDS_Song4: TfrxDBDataset;
    frxDBDS_EPrayer: TfrxDBDataset;
    frxDBDS_Init_Pray: TfrxDBDataset;
    frxPDFExport: TfrxPDFExport;
    frxReportPDF: TfrxReport;
    frxDBDS_PDF: TfrxDBDataset;
  private
    { Private declarations }
  public

  end;

var
  DSSlideCreator : TDSSlideCreator;

implementation

uses
  Vcl.Dialogs, Vcl.Graphics;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.

