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
  Collision_system.unregister(e :> Collision.t );
  Animation_system.unregister(e :> Animation.t);
  Forces_system.unregister(e :> Forces.t);
  Move_system.unregister(e :> Move.t)

let register e =
  On_screen_system.(register (e :> t));
  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Forces_system.( register (e :> t));
  Move_system.(register (e:> t))

let ground_enemy ( pos, tag) : ground_enemy =
  let e = new ground_enemy "ground enemy" in

  let (animation, box) = 
    if tag = Opossum then
      (*w = 70*)
      (Cst.opossum_animation, Rect.{width = 70; height = 50})
    else
      (Cst.slime_animation, Rect.{width = 52; height = 52})
    in

  e#animation#set (animation());
  e#tag#set tag;
  e#position#set pos;
  e#box#set box;

  e#mass#set 30.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#health#set 1;

  e#register#set (fun () ->
    register e
  );
    
  e#unregister#set (fun animates -> 
    delete animates e);

  e#on_screen#set false;
  register e;
  e


