unit ServerWebModule;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp;

type
  TServerWM = class(TWebModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TServerWM;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
