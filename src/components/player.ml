open Ecs
open Component_defs
open System_defs


let player (name, x, y, txt, width, height) =
  let e = new player name in
  e#texture#set txt;
  e#tag#set Player;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  
  e#playerstate#set Standing;

  e#mass#set 30.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;


  (* Rajouter velocity question 7.5 *)
  Draw_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  Forces_system.(register( e:> t));
  (* Question 7.5 enregistrer auprès du Move_system *)
  e

let players () =  player  Cst.("player", 64*6, 164, paddle_color, 64, 128)

let player () = 
  let Global.{player; _ } = Global.get () in
  player

let stop_players () = 
  let Global.{player; _ } = Global.get () in
  player#velocity#set Vector.zero

let move_player player v =
  let (ve: Vector.t) = player#velocity#get in
  if ve.x   < 1.0 && ve.x > -1.0 then
   player#sum_forces#set (Vector.add v player#sum_forces#get)
  else 
    ()

let run_player player  =
  let (ve: Vector.t) = player#velocity#get in
  if ve.x   < 1.0 && ve.x > -1.0  then
    player#velocity#set (Vector.mult 1.256 player#velocity#get )
  else ()

let jump_player player = 
  if player#playerstate#get = OnGround then begin
    player#sum_forces#set (Vector.add player#sum_forces#get Vector.{x = 0.; y = -1.5});
    player#playerstate#set OnAir
  end

let crouch_player player = 
  match player#playerstate#get with
  | Crouching -> ()
  | _ -> 
    let pos = player#position#get in
    let pbox = player#box#get in
    player#position#set (Vector.{x = pos.x ; y = pos.y +. 64.});
    player#box#set Rect.{width = pbox.width; height = pbox.height/2};
    player#playerstate#set Crouching

    let shoot_player player = 
      let (pos: Vector.t) = player#position#get in
      let sum_forces = Vector.{x = 1.; y = 0.0} in
      (*
      Gfx.debug "Before shooting: Player tag = %s\n" (Component_defs.tag_tostring player#tag#get);*)
      let b = Bullet.bullet (pos.x +. 70.0) pos.y sum_forces in
    
      (* Debugging prints 

      Gfx.debug "Bullet created with tag = %s\n" (Component_defs.tag_tostring b#tag#get);*)
    
      Draw_system.(register (b :> t));
      Collision_system.(register (b :> t));
      Move_system.(register (b :> t));
      Forces_system.(register (b :> t));
  
      (*
      Gfx.debug "After shooting: Player tag = %s\n" (Component_defs.tag_tostring player#tag#get);*)
      ()

let on_ground player =
  let v : Vector.t = player#velocity#get in 
  let epsilon = 1e-1 in (* Adjust depending on precision needs *)
  if abs_float v.y < epsilon then
    player#playerstate#set OnGround
  else
    player#playerstate#set OnAir

let  state_to_string player =
  match player#playerstate#get with 
    | Crouching -> "Crouching"
    | Standing -> "Standing"
    | OnAir -> "On air"
    | OnGround -> "On Ground"

let debug_player player = 
    let v: Vector.t = player#velocity#get in
    let sf:Vector.t = player#sum_forces#get in 
    let p: Vector.t = player#position#get in
    let t = player#tag#get in
    Gfx.debug "Debug: \n
               Vitesse: (%f,%f) \n
               Position: (%f,%f) \n
               Sum_forces (%f,%f) \n
               State: %s \n
               Tag : %s \n \n
               " v.x v.y
                 p.x p.y
                 sf.x sf.y
                 (state_to_string player)
                 (Component_defs.tag_tostring t)



let stand_player player = 
  match player#playerstate#get with
  | Crouching -> 
    let pos = player#position#get in
    let pbox = player#box#get in
    player#position#set (Vector.{x = pos.x ; y = pos.y -. 64.});
    player#box#set Rect.{width = pbox.width; height = pbox.height*2};
    player#playerstate#set Standing;
  | _ -> ()
