open Component_defs
open System_defs
 

let checkpoint (pos) =
  let e = new checkpoint "checkpoint" in 

  (*Mettre alpha a 255 pour debug*)
  e#texture#set (Anim.Clr (Gfx.color 255 0 0 0));
  e#position#set pos;
  e#box#set Rect.{width = 32*4 ; height = 32*4};

  e#tag#set Checkpoint;
    

  Trigger_system.(register (e :> t));
  Draw_system.(register (e :> t));
  e