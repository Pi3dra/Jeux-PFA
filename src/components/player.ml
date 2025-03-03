open Ecs
open Component_defs
open System_defs

type tag += Player

let player (name, x, y, txt, width, height) =
  let e = new player name in
  e#texture#set txt;
  e#tag#set Player;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  
  e#playerstate#set Standing;

  e#mass#set 5.0 ;
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;


  (* Rajouter velocity question 7.5 *)
  Draw_system.(register (e :> t));
  Collision_system.( register (e :> t));
  Move_system.(register (e:> t));
  Forces_system.(register( e:> t));
  (* Question 7.5 enregistrer auprès du Move_system *)
  e

let players () =  player  Cst.("player", 64*6, 100, paddle_color, 64, 128)

let player () = 
  let Global.{player; _ } = Global.get () in
  player

let stop_players () = 
  let Global.{player; _ } = Global.get () in
  player#velocity#set Vector.zero

let move_player player v =
  player#velocity#set v

let run_player player  =
  player#velocity#set (Vector.mult 2. player#velocity#get )

let crouch_player player = 
  match player#playerstate#get with
  | Crouching -> ()
  | _ -> 
    let pos = player#position#get in
    let pbox = player#box#get in
    player#position#set (Vector.{x = pos.x ; y = pos.y +. 64.});
    player#box#set Rect.{width = pbox.width; height = pbox.height/2};
    player#playerstate#set Crouching

let stand_player player = 
  match player#playerstate#get with
  | Standing -> ()
  | Crouching -> 
    let pos = player#position#get in
    let pbox = player#box#get in
    player#position#set (Vector.{x = pos.x ; y = pos.y -. 64.});
    player#box#set Rect.{width = pbox.width; height = pbox.height*2};
    player#playerstate#set Standing;
  
