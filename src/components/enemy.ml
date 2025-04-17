open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy =
  Collision_system.unregister(enemy :> Collision.t );
  Animation_system.unregister(enemy :> Animation.t);
  Forces_system.unregister(enemy :> Forces.t);
  Move_system.unregister(enemy :> Move.t)


let enemy (name, x, y, animation, width, height) =
  let e = new enemy name in
  e#animation#set animation;
  e#tag#set Enemy1;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 30.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#health#set 1;

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Forces_system.( register (e :> t));
  Move_system.(register (e:> t));
  e#unregister#set (fun () -> delete e);
  e

  
let healt enemy = enemy#health#get

(*TODO: ANIMATE THIS*)
let enemies1 texture_tbl =
  let animation = {
    file = "Opossum.png"; 
    start_pos = Vector.zero;
    current_pos = Vector.zero;
    current_frame = 0; 
    frames = 6; 
    last_frame_time = ref 0.0;
    flip = false;
    frame_duration = 200.0} in
  let positions = [
    (64*14, 500); (* Premier ennemi à la position (64*8, 164) *)
    (* Ajoute d'autres positions ici si nécessaire *)
  ] in

  (*TODO: REVERSE AND SHAVE PIXELS*)
  List.map (fun (x, y) -> enemy Cst.("enemy1", x, y,animation, 70, 56)) positions
  

let move_enemy enemy time =
  let speed = 0.1 in  
  let period = 2.0 in    
  let phase = mod_float time period /. period in
  let direction = if phase < 0.5 then -2.0 else 2.0 in
  let anim = enemy#animation#get in

  if direction < 0. then
    anim.flip <- false
  else
    anim.flip <- true;


  let enemy_speed = Vector.{ 
    x = direction *. speed; 
    y = 0.0
  } in
    
  enemy#velocity#set enemy_speed
  