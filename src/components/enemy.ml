open Ecs
open Component_defs
open System_defs




let enemy (name, x, y, txt, width, height) =
  let e = new enemy name in
  e#texture#set txt;
  e#tag#set Enemy1;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 30.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#health#set 100;

  Draw_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  Forces_system.(register( e:> t));
  e

  
  let healt enemy = enemy#health#get
  let enemies () =  enemy  Cst.("enemy1", 64*8, 164, paddle_color2, 64, 128)
  let enemies1 () =
    let positions = [
      (64*8, 164);  (* Premier ennemi à la position (64*8, 164) *)
      (64*1, 164); (* Deuxième ennemi à la position (128*8, 164) *)
      (64*3, 164); (* Troisième ennemi à la position (192*8, 164) *)
      (* Ajoute d'autres positions ici si nécessaire *)
    ] in
    List.map (fun (x, y) -> enemy Cst.("enemy1", x, y, paddle_color2, 64, 128)) positions
  
  let enemy () = 
    let Global.{enemy; _ } = Global.get () in
    enemy
    

  let move_enemy enemy  =
    let num =  (Random.int 2)in 
    let enemy_speed_r = Vector.{ x = 0.1; y = 0.} in
    let enemy_speed_l = Vector.{ x = -0.1; y = 0.}in 
    let (ve: Vector.t) = enemy#velocity#get in
    if ve.x   < 1.0 && ve.x > -1.0 then
      if num = 0 then 
      enemy#sum_forces#set (Vector.add enemy_speed_l enemy#sum_forces#get)
    else 
      enemy#sum_forces#set (Vector.add enemy_speed_r enemy#sum_forces#get)

  