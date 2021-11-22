with Ada.Text_IO, Ada.Command_Line, Ada.Directories;
with Ada.IO_Exceptions;
with Interpreter;

procedure Main is

   package T_IO renames Ada.Text_IO;
   package Comm_Line renames Ada.Command_Line;
   package Dirs renames Ada.Directories;

   type Index is mod 30_000;
   type Cell is mod 256;

   package I is new Interpreter (Tape_Index => Index, Cell_Size => Cell);

   F         : T_IO.File_Type;
   Size      : Natural;
   Arg_Count : Natural := Comm_Line.Argument_Count;
   Errored   : Boolean;

begin
   case Arg_Count is
      when 0 =>
         T_IO.Put_Line ("BFAda needs at least one sourcefile argument.");
         return;
      when others =>
         for A in 1 .. Arg_Count loop
            Errored := False;
            begin
               Size := Natural (Dirs.Size (Comm_Line.Argument (A)));
            exception
               when E : Ada.IO_Exceptions.Name_Error =>
                  T_IO.Put_Line
                    (T_IO.Standard_Error,
                     "File Error: Can't read file: " & Comm_Line.Argument (A));
                  Errored := True;
            end;
            if not Errored then
               declare
                  Code : String (1 .. Size - 1);
               begin
                  T_IO.Open (F, T_IO.In_File, Comm_Line.Argument (A));
                  T_IO.Get (F, Code);
                  I.Interpret (Code => Code);
                  T_IO.Close (File => F);
               exception
                  when E : Ada.IO_Exceptions.Name_Error =>
                     T_IO.Put_Line
                       (T_IO.Standard_Error,
                        "File Error: Can't read file: " &
                        Comm_Line.Argument (A));
               end;
            end if;
         end loop;
   end case;
end Main;
