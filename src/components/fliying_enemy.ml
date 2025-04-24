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

let move_fliying_enemy (enemy:movable) time =
  let time = time /. 1000.0 in (*ms vers s*)
  match enemy#tag#get with
  | Ghost ->
      let amplitude = 0.2 in
      let frequency = 2.0 in 
      let horizontal_speed = 0.05 in
      let switch_duration = 8.0 in 

      let anim = enemy#animation#get in
      let direction = 
        if mod_float time (2.0 *. switch_duration) < switch_duration then begin
          if anim.flip then anim.flip <- false; 
          1.0
        end
        else begin
          if not anim.flip then anim.flip <- true; 
          -1.0
        end
      in

      let enemy_speed = Vector.{ 
        x = direction *. horizontal_speed;
        y = amplitude *. cos (frequency *. time) 
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


      