open Component_defs
open System_defs

let delete animated e =
  let tag = e#tag#get in

  if animated then begin 
    let Rect.{width; height} = e#box#get in
    let Vector.{x;y} = e#position#get in
    ignore (Animated_prop.animated_prop ((int_of_float (x )) + width/2 - 20, int_of_float y, Cst.break_animation ()))
  end;

  if tag = BBox || tag = Box then
    Forces_system.unregister(e :> Forces.t);

  Collision_system.unregister(e :> Collision.t);
  Draw_system.unregister(e :> Draw.t);
  Move_system.unregister(e :> Move.t)

let register e =
  let tag = e#tag#get in
  if tag = BBox || tag = Box then
    Forces_system.(register(e :> t));

  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t))
 

let rec wall ((pos: Vector.t), box, txt, tag) =
  let e = new wall "wall" in
  (*Gfx.debug "Init Wall at pos: %f %f \n" pos.x pos.y;*)
  e#texture#set txt;
  e#position#set pos;
  e#box#set box;

  (* infinity mass*)
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#tag#set tag;

  if tag = Falling_Platform then begin
    e#mass#set 10.;
    e#unregister#set (fun animated -> delete animated e);
    e#register#set (fun () -> 
      e#position#set pos;
      register e)
  end
  else if tag = Box then begin
    e#unregister#set (fun animated -> delete animated e);
    e#register#set (fun () -> 
      e#position#set pos;
      register e);
    e#mass#set 30.
  end
  else if tag = BBox then begin
    e#unregister#set (fun animated -> delete animated e);
    e#register#set (fun () -> 
      e#position#set pos;
      register e);
    e#mass#set 80.
  end
  else 
    e#mass#set infinity;
  

  register e;
  e


