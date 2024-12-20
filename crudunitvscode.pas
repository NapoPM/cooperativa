unit CRUDUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, DBUnit;

procedure InsertarAfiliado(const Nombre, Apellido, DNI, Direccion: String);
procedure ActualizarAfiliado(const Id: Integer; const Nombre, Apellido, DNI, Direccion: String);
procedure EliminarAfiliado(const Id: Integer);
procedure MostrarAfiliado(List: TStrings);

implementation

procedure InsertarAfiliado(const Nombre, Apellido, DNI, Direccion: String);
var
  SQLQuery: TSQLQuery;
begin
  SQLQuery := TSQLQuery.Create(nil);
  try
    SQLQuery.DataBase := ODBCConnection; // Usar conexión global de DBUnit
    SQLQuery.SQL.Text := 'INSERT INTO Afiliados (Nombre, Apellido, DNI, Direccion) ' +
                         'VALUES (:Nombre, :Apellido, :DNI, :Direccion)';
    SQLQuery.Params.ParamByName('Nombre').AsString := Nombre;
    SQLQuery.Params.ParamByName('Apellido').AsString := Apellido;
    SQLQuery.Params.ParamByName('DNI').AsString := DNI;
    SQLQuery.Params.ParamByName('Direccion').AsString := Direccion;
    SQLQuery.ExecSQL;
    SQLTransaction.Commit;
  finally
    SQLQuery.Free;
  end;
end;

procedure ActualizarAfiliado(const Id: Integer; const Nombre, Apellido, DNI, Direccion: String);
var
  SQLQuery: TSQLQuery;
begin
  SQLQuery := TSQLQuery.Create(nil);
  try
    SQLQuery.DataBase := ODBCConnection; // Usar conexión global de DBUnit
    SQLQuery.SQL.Text := 'UPDATE Afiliados SET Nombre = :Nombre, Apellido = :Apellido, DNI = :DNI, Direccion = :Direccion ' +
                         'WHERE ID = :Id';
    SQLQuery.Params.ParamByName('Nombre').AsString := Nombre;
    SQLQuery.Params.ParamByName('Apellido').AsString := Apellido;
    SQLQuery.Params.ParamByName('DNI').AsString := DNI;
    SQLQuery.Params.ParamByName('Direccion').AsString := Direccion;
    SQLQuery.Params.ParamByName('Id').AsInteger := Id;
    SQLQuery.ExecSQL;
    SQLTransaction.Commit;
  finally
    SQLQuery.Free;
  end;
end;

procedure EliminarAfiliado(const Id: Integer);
var
  SQLQuery: TSQLQuery;
begin
  SQLQuery := TSQLQuery.Create(nil);
  try
    SQLQuery.DataBase := ODBCConnection; // Usar conexión global de DBUnit
    SQLQuery.SQL.Text := 'DELETE FROM Afiliados WHERE ID = :Id';
    SQLQuery.Params.ParamByName('Id').AsInteger := Id;
    SQLQuery.ExecSQL;
    SQLTransaction.Commit;
  finally
    SQLQuery.Free;
  end;
end;

procedure MostrarAfiliado(List: TStrings);
var
  SQLQuery: TSQLQuery;
begin
  SQLQuery := TSQLQuery.Create(nil);
  try
    SQLQuery.DataBase := ODBCConnection; // Usar conexión global de DBUnit
    SQLQuery.SQL.Text := 'SELECT * FROM Afiliados';
    SQLQuery.Open;
    List.Clear;

    while not SQLQuery.EOF do
    begin
      // Agregar datos en formato: "ID - Nombre Apellido - DNI - Dirección"
      List.Add(Format('%d - %s %s - %s - %s', [
        SQLQuery.FieldByName('ID').AsInteger,
        SQLQuery.FieldByName('Nombre').AsString,
        SQLQuery.FieldByName('Apellido').AsString,
        SQLQuery.FieldByName('DNI').AsString,
        SQLQuery.FieldByName('Direccion').AsString
      ]));
      SQLQuery.Next;
    end;
  finally
    SQLQuery.Free;
  end;
end;
end.
