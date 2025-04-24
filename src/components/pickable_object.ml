open Component_defs
open System_defs
 
let delete animated e =
    if animated then begin
      let Vector.{x;y} = e#position#get in
      ignore (Animated_prop.animated_prop (int_of_float x, int_of_float y, Cst.item_animation ()))
    end;

    On_screen_system.(unregister (e :> On_screen.t));
    Trigger_system.unregister(e :> Trigger.t);
    Animation_system.unregister(e :> Animation.t)


let register e =
  On_screen_system.(register (e :> t));
  Trigger_system.(register (e :> t));
  Animation_system.(register (e :> t))

(*Seulement utilisée pour les cherries pour le moment*)
let pickable_object (pos, txt) =
  let e = new pickable_object "pickable object" in 
  e#animation#set txt;
  e#position#set pos;
  e#box#set Rect.{width = 42 ; height = 42};

  e#tag#set Cherry;

  e#unregister#set(fun animated -> delete animated e);

  e#register#set (fun () -> register e);
  
  e#on_screen#set false;
  register e;
  e