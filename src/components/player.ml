open Ecs
open Component_defs
open System_defs
open Anim

(*TODO: Fix hitbox to align with player*)
let delete player =
  Collision_system.unregister(player :> Collision.t );
  Animation_system.unregister(player :> Animation.t);
  Forces_system.unregister(player :> Forces.t);
  Move_system.unregister(player :> Move.t)


let player (name, x, y, animation) =
  let e = new player name in
  e#animation#set animation;
  e#tag#set Player;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width = Cst.p_width; height= Cst.p_height };
  

  e#mass#set 30.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#health#set 6;

  let state_tbl = Hashtbl.create 10 in
  Hashtbl.replace state_tbl Idle ();
  e#playerstate#set state_tbl;


  Animation_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  Forces_system.(register( e:> t));
  e#unregister#set (fun () -> delete e);
  e


let players () =  
  let animation = {file = "foxy.png"; 
                   start_pos = Vector.{x = 0.0; y = 50.0}; 
                   current_frame = 0; 
                   frames = 5; 
                   last_frame_time = ref 0.0;
                   flip = false;
                   frame_duration = 100.0;
                   force_animation = false} in

  player  Cst.("player", 64*10, 500, animation)

let player () = 
  let Global.{player; _ } = Global.get () in
  player

let stop_players () = 
  let Global.{player; _ } = Global.get () in
  player#velocity#set Vector.zero

let stop_players_y () = 
  let Global.{player; _ } = Global.get () in
  let v = player#velocity#get in
  player#velocity#set Vector.{x = v.x; y = 0.0}

let move_player player v =
  let (ve: Vector.t) = player#velocity#get in
  if ve.x   < 0.5 && ve.x > -0.5 then
   player#sum_forces#set (Vector.add v player#sum_forces#get)
  else 
    ()

let run_player player  =
  let (ve: Vector.t) = player#velocity#get in
  if ve.x   < 0.5 && ve.x > -0.5  then
    player#velocity#set (Vector.mult 1.256 player#velocity#get )
  else ()

let jump_player player = 
  let state_tbl = player#playerstate#get in

  let x = 
    if Hashtbl.mem state_tbl Left then
      -0.5
    else 
      0.5
  in

  if Hashtbl.mem state_tbl Standing then begin
    Hashtbl.remove state_tbl Standing;
    player#sum_forces#set (Vector.add player#sum_forces#get Vector.{x ; y = -1.5});
  end


let shoot_player player = 
  let (pos: Vector.t) = player#position#get in
  let (box: Rect.t) = player#box#get in
  let v = player#velocity#get in

  if Hashtbl.mem player#playerstate#get Left then
    let sum_forces = Vector.add v Vector.{x = -1.; y = 0.0} in 
    ignore (Bullet.bullet (pos.x -. float_of_int box.width) pos.y  sum_forces)
  else
    let sum_forces = Vector.add v Vector.{x = 1.; y = 0.0} in
    ignore (Bullet.bullet (pos.x +. 2. *.(float_of_int box.width)) pos.y  sum_forces)
    
    
      (* 
      Draw_system.(register (b :> t));
      Collision_system.(register (b :> t));
      Move_system.(register (b :> t));
      Forces_system.(register (b :> t));
      *) 
      

let update_state() =
  let p = player() in

  let states = p#playerstate#get in

  let v = p#velocity#get in

  if Hashtbl.mem states Standing then begin
    Hashtbl.remove states OnAirDown;
    Hashtbl.remove states OnAirUp
  end;

  (*Idle*)
  if v.x = 0.0 then
    Hashtbl.replace states Idle ()
  else 
    Hashtbl.remove states Idle;

  if Hashtbl.mem states OnAirDown then begin
    Hashtbl.remove states Idle;
  end;

  (*OnAirDow*)
  if  v.y > 0.07 then begin
    Hashtbl.replace states OnAirDown ();
    Hashtbl.remove states OnAirUp
  end
  else
    Hashtbl.remove states Standing;

  (*OnAirUp*)
  if v.y < 0.05 && v.y <> 0.0 then 
    Hashtbl.replace states OnAirUp ()
  else
    Hashtbl.remove states Standing


let update_anim () = 
  let p = player() in

  let states = p#playerstate#get in

  if Hashtbl.mem states Idle then
    p#animation#set Cst.idle_animation

  else if Hashtbl.mem states OnAirUp then
    p#animation#set Cst.jumping_animation

  else if Hashtbl.mem states OnAirDown then
    p#animation#set Cst.falling_animation 
  else 
    p#animation#set Cst.running_animation;

  let animation = p#animation#get in

  if Hashtbl.mem states Left then 
    animation.flip <- true 
  else 
    animation.flip <- false





let  state_to_string state =
  match state with 
    | Moving -> "Moving"
    | Crouching -> "Crouching"
    | Standing -> "Standing"
    | OnAirUp -> "OnAirUp"
    | OnAirDown-> "OnAirDown"
    | Idle -> "Idle"
    | Left -> "Left"
    | Right -> "Right"

let  state_to_int state =
  match state with 
  | Moving -> 1
  | Crouching -> 3
  | Standing -> 1
  | OnAirUp -> 5
  | OnAirDown-> 5
  | Idle -> 0
  | Left -> 1
  | Right -> 0

let debug_player player = 
    let v: Vector.t = player#velocity#get in
    let sf:Vector.t = player#sum_forces#get in 
    let p: Vector.t = player#position#get in
    let t = player#tag#get in
    Gfx.debug "Debug: \n
               Vitesse: (%f,%f) \n
               Position: (%f,%f) \n
               Sum_forces (%f,%f) \n
               Tag : %s \n \n
               " v.x v.y
                 p.x p.y
                 sf.x sf.y
                 (Component_defs.tag_tostring t)

let debug_states player = 
  Hashtbl.iter (fun k _ -> Gfx.debug "%s "  (state_to_string k)) player#playerstate#get ;
  Gfx.debug "\n"

