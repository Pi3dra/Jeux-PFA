open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy =
  Animation_system.unregister(enemy :> Animation.t);
  Collision_system.unregister(enemy :> Collision.t );
  Forces_system.unregister(enemy :> Forces.t);
  Move_system.unregister(enemy :> Move.t)


let enemy4 (name, x, y, animation, width, height) =
  let e = new enemy4 name in
  e#animation#set animation;
  e#tag#set Enemy4;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 40.1 ;
  e#velocity#set Vector.zero;
  e#health#set 1;
    (*Forces_system.(register( e:> t));*)

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  (*Forces_system.(register( e:> t));*)
  e#unregister#set (fun () -> delete e);
  e


let enemies4 () =
  let animation = {
    file = "ghost.png"; 
    start_pos = Vector.zero;
    current_pos = Vector.zero;
    current_frame = 0; 
    frames = 6; 
    last_frame_time = ref 0.0;
    flip = false;
    frame_duration = 200.0} in

  let positions2 = [
    (64*20, 400);
    (64*25, 400);

      (* Ajoute d'autres positions ici si nécessaire *)
  ] in
  List.map (fun (x, y) -> enemy4 Cst.("enemy2", x, y, animation, 75, 75)) positions2
  
let enemy4 () = 
  let Global.{enemy; _ } = Global.get () in
  enemy

let move_enemy4 enemy time =
  let amplitude = 1.1 in  
  let frequency = 50.0 in   
  let horizontal_speed = 0.05 in  (* Speed for left/right motion *)
  let switch_duration = 1.0 in    (* Time to switch direction, in scaled time *)
  let time = time /. 10.0 in      (* Match time scaling from move_enemy3 *)
    (* Determine direction based on time *)

  let anim = enemy#animation#get in
  let direction = 
    if mod_float time (2.0 *. switch_duration) < switch_duration 
    then begin
      anim.flip <- false;
      1.0  (* Move right *)
    end
    else begin
      anim.flip <- true;
      -1.0 (* Move left *)
    end
  in



  let enemy_speed = Vector.{ 
    x = direction *. horizontal_speed ; 
    y = amplitude *. cos (frequency *. time) /. 5.
  } in
  enemy#velocity#set enemy_speed
  
      