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

  let boss ( pos, tag) : boss =
    let e = new boss "boss" in
  
    let (animation, box) = 
      if tag = Boss then
        (*w = 70*)
        (Cst.boss_animation, Rect.{width = 126; height = 104})
      else
        (Cst.slime_animation, Rect.{width = 52; height = 52})
      in
  
    e#animation#set (animation());
    e#tag#set Boss;
    e#position#set pos;
    e#box#set box;
  
    e#mass#set 30.0 ;
    e#velocity#set Vector.zero;
    e#sum_forces#set Vector.zero;
    e#health#set 5;
  
    e#register#set (fun () ->
      register e
    );
  
    
    e#on_screen#set false;
    e#unregister#set (fun animates -> 
      delete animates e);
  
    register e;
    e

    let move_boss (boss:movable) time =
      let time = time /. 1000.0 in
      match boss#tag#get with
      | Boss ->
          let speed = 0.8 in
          let cycle = 3.4 in
          let phase = mod_float time cycle in
          let direction = 
            if phase < 0.7 then 2.0
            else if phase < 1.7 then 0.0
            else if phase < 2.4 then -2.0
            else 0.0
          in
          let anim = boss#animation#get in
          anim.flip <- phase < 1.7;
          let enemy_speed = Vector.{ 
            x = direction *. speed; 
            y = 0.0
          } in
          boss#velocity#set enemy_speed
      | _ -> ()