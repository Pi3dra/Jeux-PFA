open Ecs
open Component_defs
open System_defs
open Anim

let delete enemy3 =
  Animation_system.unregister(enemy3 :> Animation.t);
  Collision_system.unregister(enemy3 :> Collision.t );
  Forces_system.unregister(enemy3 :> Forces.t);
  Move_system.unregister(enemy3 :> Move.t)


let enemy3 (name, x, y, animation, width, height) =
  let e = new enemy3 name in
  e#animation#set animation;
  e#tag#set Enemy3;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  

  e#mass#set 30.1 ;
  e#velocity#set Vector.zero;
  e#health#set 1;
  

  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  Forces_system.(register( e:> t));
  e#unregister#set (fun () -> delete e);
  e


  let enemies3 () =
    let animation = {
      file = "slimer-idle.png"; 
      start_pos = Vector.zero;
      current_pos = Vector.zero;
      current_frame = 0; 
      frames = 8; 
      last_frame_time = ref 0.0;
      flip = false;
      frame_duration = 200.0} in

    let positions3 = [
      (64*25, 500);
    ] in
    List.map (fun (x, y) -> enemy3 Cst.("enemy3", x, y, animation, 52, 52)) positions3
  
  let enemy3 () = 
    let Global.{enemy; _ } = Global.get () in
    enemy

    let move_enemy3 enemy time =
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