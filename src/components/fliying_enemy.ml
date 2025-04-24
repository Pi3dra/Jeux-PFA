open Ecs
open Component_defs
open System_defs
open Anim

let delete animates e =
  if animates then begin
    let Vector.{x;y} = e#position#get in
    ignore (Animated_prop.animated_prop (int_of_float x, int_of_float y, Cst.death_animation()))
  end;

  On_screen_system.unregister(e :> On_screen.t);
  Animation_system.unregister(e :> Animation.t);
  Collision_system.unregister(e :> Collision.t );
  Move_system.unregister(e :> Move.t)

let register e =
  On_screen_system.(register (e :> t));
  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t))
    

let rec fliying_enemy ( pos , tag) =
  let e = new fliying_enemy "fliying enemy" in

  let (animation, box) = 
    if tag = Ghost then
      (Cst.ghost_aimation, Rect.{width = 75; height = 75 })
    else 
      (Cst.eagle_animation, Rect.{width = 78; height = 78})
  in

  e#animation#set (animation());
  e#tag#set tag; (*Ghost*)
  e#position#set pos;
  e#box#set box;
  

  e#mass#set 40.1 ;
  e#velocity#set Vector.zero;
  e#health#set 1;

  e#register#set (fun () ->
    register e
  );

  e#unregister#set (fun animates -> 
    delete animates e);

  e#on_screen#set false;
  register e;
  e


      