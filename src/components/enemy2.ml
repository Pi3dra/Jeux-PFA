open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy2 =
  Animation_system.unregister(enemy2 :> Animation.t);
  Collision_system.unregister(enemy2 :> Collision.t );
  Move_system.unregister(enemy2 :> Move.t)


let enemy2 (name, x, y, animation, width, height) =
  let e = new enemy2 name in
  e#animation#set animation;
  e#tag#set Enemy2;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 30.1 ;
  e#velocity#set Vector.zero;
  e#health#set 100;
  

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  e#unregister#set (fun () -> delete e);
  e


  let enemies2 () =
    let animation = {
      file = "eagle-attack.png"; 
      start_pos = Vector.zero;
      current_pos = Vector.zero;
      current_frame = 0; 
      frames = 4; 
      last_frame_time = ref 0.0;
      flip = false;
      frame_duration = 200.0} in

    let positions2 = [
      (64*8, 300);
      (64*11, 300);

      (* Ajoute d'autres positions ici si nécessaire *)
    ] in
    List.map (fun (x, y) -> enemy2 Cst.("enemy2", x, y, animation, 78, 78)) positions2
  
  let enemy2 () = 
    let Global.{enemy; _ } = Global.get () in
    enemy

let move_enemy2 enemy time =
  let amplitude = 0.1 in  
  let frequency = 2.0 in   
  let enemy_speed = Vector.{ 
    x = amplitude *. cos (frequency *. time); 
    y = amplitude *. sin (frequency *. time) 
  } in
  enemy#velocity#set enemy_speed
