open Ecs
open Component_defs
open System_defs

let bullet x y sum_forces ctx font =
  let e = new bullet "bullet" in
  e#texture#set Cst.paddle_color; (*A cambiar*)
  e#position#set Vector.{x = x; y = y};
  e#box#set Rect.{width = 5 ; height = 5}; (*meter en cst*)

  e#velocity#set Vector.zero;
  e#mass#set 1.5;
  e#sum_forces#set sum_forces;

  (* Question 7.6 rajouter velocity *)

  Draw_system.(register (e :>t));
  Collision_system.(register (e :> t));
  Move_system.(register (e:>t));
  (* Question 7.6 enregistrer auprès du Move_system *)
  e

