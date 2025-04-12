open Ecs
open Component_defs
open System_defs

let delete enemy2 =
  Collision_system.unregister(enemy2 :> Collision.t );
  Draw_system.unregister(enemy2 :> Draw.t);
  Forces_system.unregister(enemy2 :> Forces.t);
  Move_system.unregister(enemy2 :> Move.t)


let enemy2 (name, x, y, txt, width, height) =
  let e = new enemy name in
  e#texture#set txt;
  e#tag#set Enemy2;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 30.1 ;
  e#velocity#set Vector.zero;
  (*e#sum_forces#set Vector.zero;*)
  e#health#set 100;
  

  Draw_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  (*Forces_system.(register( e:> t));*)
  e#unregister#set (fun () -> delete e);
  e

  let enemies21() =  enemy2  Cst.("enemy2", 64*8, 200, paddle_color3, 64, 64)
  let enemies2 () =
    let positions2 = [
      (64*4, 400);
      (64*1, 400);
      (64*7, 400);

      (* Ajoute d'autres positions ici si nécessaire *)
    ] in
    List.map (fun (x, y) -> enemy2 Cst.("enemy2", x, y, paddle_color3, 64, 64)) positions2
  
  let enemy2 () = 
    let Global.{enemy; _ } = Global.get () in
    enemy


    let move_enemy2 enemy =
      let num =  (Random.int 2)in 
    let enemy_speed_r = Vector.{ x = 0.1; y = 0.1} in
    let enemy_speed_l = Vector.{ x = -0.1; y = -0.1}in 
      if num = 0 then 
      enemy#velocity#set (Vector.add enemy_speed_l enemy#velocity#get)
    else 
      enemy#velocity#set (Vector.add enemy_speed_r enemy#velocity#get)

    
  
  