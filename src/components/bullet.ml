open Ecs
open Component_defs
open System_defs

let delete bullet =
  Collision_system.unregister(bullet :> Collision.t );
  Draw_system.unregister(bullet :> Draw.t);
  Forces_system.unregister(bullet :> Forces.t);
  Move_system.unregister(bullet :> Move.t)


let bullet x y sum_forces  =
  let e = new bullet "bullet" in
  e#texture#set Cst.paddle_color; (*A cambiar*)
  e#position#set Vector.{x = x; y = y};
  e#box#set Rect.{width = 10 ; height = 10}; (*meter en cst*)
  e#tag#set Bullet;


  e#velocity#set Vector.zero;
  e#mass#set 20.5; (*meter en cst*)
  e#sum_forces#set sum_forces;
  e#unregister#set (fun () -> delete e);
  e

  

