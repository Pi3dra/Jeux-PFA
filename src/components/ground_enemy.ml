open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy =
  Collision_system.unregister(enemy :> Collision.t );
  Animation_system.unregister(enemy :> Animation.t);
  Forces_system.unregister(enemy :> Forces.t);
  Move_system.unregister(enemy :> Move.t)


let ground_enemy (name, x, y, tag) =
  let e = new ground_enemy name in

  let (animation, box) = 
    if tag = Opossum then
      (Cst.opossum_animation, Rect.{width = 70; height = 50})
    else
      (Cst.slime_animation, Rect.{width = 52; height = 52})
    in

  e#animation#set animation;
  e#tag#set tag;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set box;

  e#mass#set 30.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#health#set 1;

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Forces_system.( register (e :> t));
  Move_system.(register (e:> t));

  e#unregister#set (fun () -> 
    delete e;
    let Vector.{x;y} = e#position#get in
    ignore (Animated_prop.animated_prop (int_of_float x, int_of_float y, Cst.death_animation)) );
  e


let move_ground_enemy enemy time =

  match enemy#tag#get with
  | Opossum ->
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
  | Slime ->

      let speed = 0.1 in
      let move_duration = 0.1 in
      let wait_duration = 0.05 in
      (* Total cycle: 4 movements (2 left, 2 right) + 4 waits *)
      let cycle_duration = 4.0 *. move_duration +. 4.0 *. wait_duration in
      
      let time = time /. 10.0 in
      
      (* Calculate phase within the cycle *)
      let phase = mod_float time cycle_duration in
      
      let anim = enemy#animation#get in
      (* Determine velocity based on phase *)
      let enemy_speed =
        if phase < move_duration then begin
          anim.flip <- false;
          Vector.{ x = -.speed; y = 0.0 }
        end
        else if phase < move_duration +. wait_duration then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < 2.0 *. move_duration +. wait_duration then begin
          anim.flip <- false;
          Vector.{ x = -.speed; y = 0.0 }
        end
        else if phase < 2.0 *. move_duration +. 2.0 *. wait_duration then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < 3.0 *. move_duration +. 2.0 *. wait_duration then begin
          anim.flip <- true;
          Vector.{ x = speed; y = 0.0 }
        end
        else if phase < 3.0 *. move_duration +. 3.0 *. wait_duration then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < 4.0 *. move_duration +. 3.0 *. wait_duration then begin
          anim.flip <- true;
          Vector.{ x = speed; y = 0.0 }
        end
        else begin
          Vector.{ x = 0.0; y = 0.0 }
        end
      in
      
      enemy#velocity#set enemy_speed
  | _ -> ()