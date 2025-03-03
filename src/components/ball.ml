(*open Ecs
open Component_defs
open System_defs

(*futuras balas*)

let random_v b =
  let a = Random.float (Float.pi/.2.0) -. (Float.pi /. 4.0) in
  let v = Vector.{x = cos a; y = sin a} in
  let v = Vector.mult 5.0 (Vector.normalize v) in
  if b then v else Vector.{ v with x = -. v.x }


let restart () =
  let global = Global.get () in
  if global.waiting <> 0 then begin
    let v = random_v (global.waiting = 1) in
    global.waiting <- 0;
    global.ball#kuchao#set v;   (* à remplacer question 7.6
          la vitesse de global.ball à v   
    *)
  end
let ball ctx font =
  let e = new ball () in
  let y_orig = float Cst.ball_v_offset in
  e#texture#set Cst.ball_color;
  e#position#set Vector.{x = float Cst.ball_left_x; y = y_orig};
  e#box#set Rect.{width = Cst.ball_size; height = Cst.ball_size};
  e#kuchao#set Vector.zero;

  e#resolve#set (fun n t ->
    match t#tag#get with
      Wall.HWall _ | Player.Player ->
        let v = e#kuchao#get in
        e#kuchao#set Vector.{ x = v.x*.n.x; y = v.y*.n.y }

      | Wall.VWall (i,_) ->
        restart();
        if i = 2 then
          
          e#position#set Vector.{x = float Cst.ball_left_x; y = y_orig}
        else

          e#position#set Vector.{x = float Cst.ball_right_x; y = y_orig}

      | _ -> ()

  );
  (* Question 7.6 rajouter velocity *)

  Draw_system.(register (e :>t));
  Collision_system.(register (e :> t));
  Move_system.(register (e:>t));
  (* Question 7.6 enregistrer auprès du Move_system *)
  e
*)
