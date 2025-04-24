open Ecs
open Component_defs
open System_defs
open Anim

let delete animates boss =
  if animates then begin
    let Vector.{x;y} = boss#position#get in
    ignore (Animated_prop.animated_prop (int_of_float x, int_of_float y, Cst.death_animation()))
  end; 

  On_screen_system.unregister(boss :> On_screen.t);
  Collision_system.unregister(boss :> Collision.t );
  Animation_system.unregister(boss :> Animation.t);
  Forces_system.unregister(boss :> Forces.t);
  Move_system.unregister(boss :> Move.t)

let register e =
  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Forces_system.( register (e :> t));
  Move_system.(register (e:> t));
  On_screen_system.(register (e :> t))

  let boss2 ( pos, tag) : boss2 =
    let e = new boss2 "boss2" in
  
    let (animation, box) = 
      if tag = Boss then
        (*w = 70*)
        (Cst.boss_animation, Rect.{width = 200; height = 100})
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
    e#health#set 200;
  
    e#register#set (fun () ->
      register e
    );
  
    (*
    e#move_func#set ( fun dt -> (move_ground_enemy e dt));*)
      
    e#unregister#set (fun animates -> 
      delete animates e);
  
    e#on_screen#set false;
    register e;
    e


    let move_boss (boss:movable) time =
      let time = time /. 1000.0 in (* Convert milliseconds to seconds *)
      match boss#tag#get with
      | Boss ->
          let speed = 1.3 in
          let period = 3.0 in (* 4 seconds *)
          let phase = mod_float time period /. period in
          let direction = if phase < 0.5 then -2.0 else 2.0 in
          let anim = boss#animation#get in
    
          anim.flip <- direction > 0.0;
    
          let enemy_speed = Vector.{ 
            x = direction *. speed; 
            y = 0.0
          } in
    
          boss#velocity#set enemy_speed
      | _ -> ()