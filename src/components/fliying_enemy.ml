open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy =
  Animation_system.unregister(enemy :> Animation.t);
  Collision_system.unregister(enemy :> Collision.t );
  Forces_system.unregister(enemy :> Forces.t);
  Move_system.unregister(enemy :> Move.t)

(*TODO: Try and remove physics*)

let fliying_enemy (name, x, y, tag) =
  let e = new fliying_enemy name in

  let (animation, box) = 
    if tag = Ghost then
      (Cst.ghost_aimation, Rect.{width = 75; height = 75 })
    else 
      (Cst.eagle_animation, Rect.{width = 78; height = 78})
  in

  e#animation#set animation;
  e#tag#set tag; (*Ghost*)
  e#position#set Vector.{x = float x; y = float y};
  e#box#set box;
  

  e#mass#set 40.1 ;
  e#velocity#set Vector.zero;
  e#health#set 1;

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  

  e#unregister#set (fun () -> 
    delete e;
    let Vector.{x;y} = e#position#get in
    ignore (Animated_prop.animated_prop (int_of_float x, int_of_float y, Cst.death_animation)) );
  e

(*
let enemies4 () =
  let animation = {
    file = "ghost.png"; 
    start_pos = Vector.zero;
    current_frame = 0; 
    frames = 6; 
    last_frame_time = ref 0.0;
    flip = false;
    frame_duration = 200.0;
    force_animation = false} in

  let positions2 = [
    (64*20, 400);
    (64*25, 400);

      (* Ajoute d'autres positions ici si nécessaire *)
  ] in
  List.map (fun (x, y) -> enemy4 Cst.("enemy2", x, y, animation, 75, 75)) positions2
 
let enemy4 () = 
  let Global.{enemy; _ } = Global.get () in
  enemy
*)

let move_fliying_enemy enemy time =
  match enemy#tag#get with
  | Ghost ->
    let amplitude = 1.1 in  
    let frequency = 50.0 in   
    let horizontal_speed = 0.05 in  
    let switch_duration = 1.0 in    
    let time = time /. 10.0 in      

    let anim = enemy#animation#get in
    let direction = 
      if mod_float time (2.0 *. switch_duration) < switch_duration 
      then begin
        anim.flip <- false;
        1.0  
      end
      else begin
        anim.flip <- true;
        -1.0 
      end
    in

    let enemy_speed = Vector.{ 
      x = direction *. horizontal_speed ; 
      y = amplitude *. cos (frequency *. time) /. 5.
    } in
    enemy#velocity#set enemy_speed

  | Eagle -> 
    let amplitude = 0.1 in  
    let frequency = 2.0 in   
    let enemy_speed = Vector.{ 
      x = amplitude *. cos (frequency *. time); 
      y = amplitude *. sin (frequency *. time) 
    } in
    enemy#velocity#set enemy_speed

  | _ -> ()
  
      