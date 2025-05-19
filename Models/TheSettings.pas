unit TheSettings;

interface

uses SysUtils;

type
  TSettingsSingleton = class(TObject)
  private
    FDBFileName: string;
    class var FInstance: TSettingsSingleton;
  public
    class function GetInstance(): TSettingsSingleton;
    class procedure DestroyInstance;
    property DBFileName: string read FDBFileName write FDBFileName;
  end;

  TSettings = class of TSettingsSingleton;

var
  Settings: TSettings;

implementation


class procedure TSettingsSingleton.DestroyInstance;
begin
  if Assigned(FInstance) then FInstance.Free;
end;

class function TSettingsSingleton.GetInstance(): TSettingsSingleton;
begin
  if not Assigned(FInstance) then begin
    FInstance := TSettingsSingleton.Create();
    FInstance.FDBFileName := 'hik_events.db';
  end;
  Result := FInstance;
end;

end.
