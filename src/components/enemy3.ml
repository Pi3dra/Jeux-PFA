(*open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy3 =
  Animation_system.unregister(enemy3 :> Animation.t);
  Collision_system.unregister(enemy3 :> Collision.t );
  Forces_system.unregister(enemy3 :> Forces.t);
  Move_system.unregister(enemy3 :> Move.t)


let enemy3 (name, x, y, animation, width, height) =
  let e = new enemy3 name in
  e#animation#set animation;
  e#tag#set Enemy3; (*SLIME*)
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 30.1 ;
  e#velocity#set Vector.zero;
  e#health#set 1;
  

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  Forces_system.(register( e:> t));
  e#unregister#set (fun () -> 
    delete e;
    let Vector.{x;y} = e#position#get in
    ignore (Animated_prop.animated_prop (int_of_float x, int_of_float y, Cst.death_animation)) );
  e


  let enemies3 () =
    let animation = {
      file = "slimer-idle.png"; 
      start_pos = Vector.zero;
      current_frame = 0; 
      frames = 8; 
      last_frame_time = ref 0.0;
      flip = false;
      frame_duration = 200.0;
      force_animation = false} in

    let positions3 = [
      (64*35, 500);
    ] in
    List.map (fun (x, y) -> enemy3 Cst.("enemy3", x, y, animation, 52, 52)) positions3
  
  let enemy3 () = 
    let Global.{enemy; _ } = Global.get () in
    enemy

*)