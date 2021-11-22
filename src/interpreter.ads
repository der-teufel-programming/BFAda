with Ada.Containers.Vectors;
with Ada.Text_IO;

generic
   type Tape_Index is mod <>;
   type Cell_Size is mod <>;

package Interpreter is

   procedure Interpret (Code : String);

private

   package Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural, Element_Type => Natural, "=" => "=");

   type Tape_Type is array (Tape_Index'Range) of Cell_Size;

   type Interpreter is record
      Tape     : Tape_Type;
      Code_Loc : Natural;
      Tape_Loc : Tape_Index;
      Jumps    : Vectors.Vector;
   end record;

end Interpreter;
