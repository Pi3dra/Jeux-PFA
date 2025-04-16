open Ecs
open Component_defs
open System_defs

let delete bullet flag=
  if not flag then begin
    Collision_system.unregister(bullet :> Collision.t );
    Draw_system.unregister(bullet :> Draw.t);
    Move_system.unregister(bullet :> Move.t);
    Gfx.debug "Removing bullet";
    bullet#remove_tag#set true
  end  

let create_texture () =
    let Global.{texture_tbl} = Global.get () in
  
    match Hashtbl.find_opt texture_tbl "piso.png" with
      None -> Anim.red
     | Some t -> Anim.Image t
  

let bullet x y velocity =
  let e = new bullet "bullet" in
  e#texture#set (create_texture()); (*A cambiar*)
  e#position#set Vector.{x = x; y = y};
  e#box#set Rect.{width = 10 ; height = 10}; (*meter en cst*)
  e#tag#set Bullet;

  e#velocity#set Vector.{x = velocity.x; y = 0.0};
  e#mass#set 20.5; (*meter en cst*)
  e#unregister#set (fun () -> delete e e#remove_tag#get);
  
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));



  

