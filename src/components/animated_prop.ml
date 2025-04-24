open Component_defs
open System_defs

let delete animated e =
  On_screen_system.unregister(e :> On_screen.t);
  Animation_system.unregister(e :> Animation.t)

let animated_prop (x, y, animation) =
  let e = new animated_prop "prop" in
  e#animation#set animation;
  e#tag#set Remove_on_end;
  e#position#set Vector.{x = float x; y = float y};

  if animation.file = "death.png" then
    e#box#set Rect.{width = 64; height = 64}
  else if animation.file = "item-break.png" then
    e#box#set Rect.{width = 40; height = 41}
  else 
    e#box#set Rect.{width = 32; height = 32}
  ;
  
  e#unregister#set (fun animated -> delete animated e);
  e#on_screen#set false;

  On_screen_system.(register (e :> t));
  Animation_system.(register (e :> t));
  e
