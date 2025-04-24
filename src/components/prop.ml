open Component_defs
open System_defs


let prop (pos, box ,txt) =
  let e = new prop "prop" in
  e#texture#set txt;
  e#position#set pos;
  e#box#set box;
  e#on_screen#set true;

  Draw_system.(register (e :> t));
  e


