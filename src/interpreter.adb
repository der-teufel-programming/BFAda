with Ada.IO_Exceptions;

package body Interpreter is

   procedure Inc_Code_Loc (I : in out Interpreter) is
   begin
      I.Code_Loc := I.Code_Loc + 1;
   end Inc_Code_Loc;
   pragma Inline_Always (Inc_Code_Loc);

   procedure Interpret (Code : String) is
      I         : Interpreter := ((others => 0), 1, 0, Vectors.Empty_Vector);
      Instr     : Character;
      Inp       : Character;
      Brk_Count : Natural;
      use Ada.Text_IO;
   begin
      while I.Code_Loc <= Code'Length loop
         Instr := Code (I.Code_Loc);
         case Instr is
            when '+' =>
               I.Tape (I.Tape_Loc) := I.Tape (I.Tape_Loc) + 1;
            when '-' =>
               I.Tape (I.Tape_Loc) := I.Tape (I.Tape_Loc) - 1;
            when '>' =>
               I.Tape_Loc := I.Tape_Loc + 1;
            when '<' =>
               I.Tape_Loc := I.Tape_Loc - 1;
            when '.' =>
               Put (Character'Val (I.Tape (I.Tape_Loc)));
            when ',' =>
               begin
                  Get (Inp);
               exception
                  when E : Ada.IO_Exceptions.End_Error =>
                     Inp := Character'Val (0);
               end;
               I.Tape (I.Tape_Loc) := Character'Pos (Inp);
            when '[' =>
               case I.Tape (I.Tape_Loc) is
                  when 0 =>
                     declare
                        Start_Index : Natural := I.Code_Loc;
                     begin
                        Inc_Code_Loc (I);
                        Brk_Count := 1;
                        while Brk_Count /= 0 loop
                           Instr := Code (I.Code_Loc);
                           case Instr is
                              when '[' =>
                                 Brk_Count := Brk_Count + 1;
                              when ']' =>
                                 Brk_Count := Brk_Count - 1;
                              when others =>
                                 null;
                           end case;
                           Inc_Code_Loc (I);
                        end loop;
                     exception
                        when E : Constraint_Error =>
                           Put_Line
                             (Standard_Error,
                              "Code Error: Missing `]` after `[` at index:" &
                              Natural'Image (Start_Index - 1));
                     end;
                  when others =>
                     Vectors.Append (I.Jumps, I.Code_Loc);
               end case;
            when ']' =>
               begin
                  case I.Tape (I.Tape_Loc) is
                     when 0 =>
                        Vectors.Delete_Last (I.Jumps);
                     when others =>
                        I.Code_Loc := Vectors.Last_Element (I.Jumps);
                  end case;
               exception
                  when E : Constraint_Error =>
                     Put_Line
                       (Standard_Error,
                        "Code Error: Missing `[` before `]` at index:" &
                        Natural'Image (I.Code_Loc - 1));
               end;
            when others =>
               null;
         end case;

         Inc_Code_Loc (I);

      end loop;
   end Interpret;

end Interpreter;
