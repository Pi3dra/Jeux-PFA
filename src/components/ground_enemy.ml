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

let move_ground_enemy (enemy:movable) time =
  let time = time /. 1000.0 in (* Convert milliseconds to seconds *)
  match enemy#tag#get with
  | Opossum ->
      let speed = 0.1 in
      let period = 4.0 in (* 4 seconds *)
      let phase = mod_float time period /. period in
      let direction = if phase < 0.5 then -2.0 else 2.0 in
      let anim = enemy#animation#get in

      anim.flip <- direction > 0.0;

      let enemy_speed = Vector.{ 
        x = direction *. speed; 
        y = 0.0
      } in

      enemy#velocity#set enemy_speed

  | Slime ->
      let speed = 0.1 in
      let move_duration = 0.5 in
      let wait_duration = 0.5 in
      let cycle_duration = 4.0 *. move_duration +. 4.0 *. wait_duration in
      let phase = mod_float time cycle_duration /. cycle_duration in
      let anim = enemy#animation#get in
      let enemy_speed =
        if phase < (move_duration /. cycle_duration) then begin
          anim.flip <- false;
          Vector.{ x = -.speed; y = 0.0 }
        end
        else if phase < ((move_duration +. wait_duration) /. cycle_duration) then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < ((2.0 *. move_duration +. wait_duration) /. cycle_duration) then begin
          anim.flip <- false;
          Vector.{ x = -.speed; y = 0.0 }
        end
        else if phase < ((2.0 *. move_duration +. 2.0 *. wait_duration) /. cycle_duration) then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < ((3.0 *. move_duration +. 2.0 *. wait_duration) /. cycle_duration) then begin
          anim.flip <- true;
          Vector.{ x = speed; y = 0.0 }
        end
        else if phase < ((3.0 *. move_duration +. 3.0 *. wait_duration) /. cycle_duration) then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < ((4.0 *. move_duration +. 3.0 *. wait_duration) /. cycle_duration) then begin
          anim.flip <- true;
          Vector.{ x = speed; y = 0.0 }
        end
        else begin
          Vector.{ x = 0.0; y = 0.0 }
        end
      in

      enemy#velocity#set enemy_speed
  | _ -> ()

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


