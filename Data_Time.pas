unit Data_Time;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd;

  function GetFullTime(): String;
  function ExtractMSec(Time: String): Double;
  function ExtractDateTime(Time: String): TDateTime;

implementation

function GetFullTime(): String;
begin
    Result := FormatDateTime('yy:mm:dd:hh:mm:ss.zzz', Now);
end;

function ExtractMSec(Time: String): Double;
var
 Value : Double;
 Sec: String;
begin
    Sec := Time.Substring(15,6);
    Result := StrToInt(Sec.Substring(0,2)) + (StrToInt(Sec.Substring(3,3))/1000);
end;

function ExtractDateTime(Time: String): TDateTime;
var
  settings :TFormatSettings;
begin
    settings := TFormatSettings.Create;
    settings.ShortDateFormat := 'yy:mm:dd';
    settings.ShortTimeFormat := 'hh:mm:ss.zzz';
    settings.DateSeparator:=':';
    settings.TimeSeparator:=':';
    settings.DecimalSeparator := '.';
    Result := StrToDateTime(Time,settings);
end;

end.
