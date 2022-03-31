unit LibGeneral;

interface
  function Encrypt(Text : String; Key : Integer):String;
  function Decrypt(Text : String; Key : Integer):String;

implementation

uses
  System.SysUtils;

/// <summary> Encrypt the password
/// </summary>
function Encrypt(Text : String; Key : Integer):String;
var
  Cont : integer;
  Return : string;
  //retorn ASCII characters
  function AsciiToInt(Caracter: Char): Integer;
  var
    i: Integer;
  begin
    i := 32;
    while i < 255 do begin
      if Chr(i) = Caracter then
        Break;
      i := i + 1;
    end;
    Result := i;
  end;
begin
  if (Trim(Text)=EmptyStr) or (Key=0) then begin
    Result := Text;
  end else begin
    Return := '';
    for Cont:=1 to Length(Text) do begin
      Return := Return + chr(asciitoint(Text[Cont])+Key);
    end;
    Result := Return;
  end;
end;

/// <summary> Decrypt the password
/// </summary>
function Decrypt(Text : String; Key : Integer):String;
var
  Cont : integer;
  Return : string;
  //retorn ASCII characters
  function AsciiToInt(Caracter: Char): Integer;
  var
    i: Integer;
  begin
    i := 32;
    while i < 255 do begin
      if Chr(i) = Caracter then
        Break;
      i := i + 1;
    end;
    Result := i;
  end;
begin
  if (Trim(Text)=EmptyStr) or (Key = 0) then begin
    Result := Text;
  end else begin
    Return := '';
    for cont:=1 to length(Text) do begin
      Return := Return+chr(asciitoint(Text[Cont])-Key);
    end;
    Result := Return;
  end;
end;

end.
