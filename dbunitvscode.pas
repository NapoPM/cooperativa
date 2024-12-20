unit DBUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, ODBCConn;

var
  ODBCConnection: TODBCConnection;
  SQLTransaction: TSQLTransaction;

procedure IniciarDB(const HostName, DatabaseName, UserName, Password: String);
procedure CerrarDB;

implementation

procedure IniciarDB(const HostName, DatabaseName, UserName, Password: String);
begin
  // Crear objetos de conexión y transacción
  ODBCConnection := TODBCConnection.Create(nil);
  SQLTransaction := TSQLTransaction.Create(nil);

  // Configuración de conexión
  ODBCConnection.Driver := 'ODBC Driver 17 for SQL Server'; // Ajustar según la versión instalada
  ODBCConnection.HostName := HostName;                     // Dirección del servidor (e.g., 'localhost')
  ODBCConnection.DatabaseName := DatabaseName;             // Nombre de la base de datos (e.g., 'SimpleCRUD')
  ODBCConnection.UserName := UserName;                     // Usuario del servidor
  ODBCConnection.Password := Password;                     // Contraseña del usuario
  ODBCConnection.Transaction := SQLTransaction;

  // Intentar conectar a la base de datos
  try
    ODBCConnection.Connected := True;
    SQLTransaction.StartTransaction;
  except
    on E: Exception do
    begin
      // Liberar recursos si ocurre un error
      ODBCConnection.Free;
      SQLTransaction.Free;
      raise Exception.Create('Error al conectar a la base de datos: ' + E.Message);
    end;
  end;
end;

procedure CerrarDB;
begin
  // Desconectar y liberar recursos
  if Assigned(ODBCConnection) then
  begin
    if ODBCConnection.Connected then
    begin
      try
        SQLTransaction.Commit; // Confirmar transacción
      except
        on E: Exception do
          raise Exception.Create('Error al confirmar la transacción: ' + E.Message);
      end;

      ODBCConnection.Connected := False; // Desconectar
    end;
    FreeAndNil(ODBCConnection);
  end;

  if Assigned(SQLTransaction) then
    FreeAndNil(SQLTransaction);
end;

end.
