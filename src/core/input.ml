open Gfx
open Component_defs
open Player


let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s = Hashtbl.replace key_table s ""
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let release_action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action
let register_release key action = Hashtbl.replace release_action_table key action

let handle_input () =
  let () =
    match Gfx.poll_event () with
    | KeyDown s -> 
        set_key s
    | KeyUp s ->
        unset_key s;
        if Hashtbl.mem release_action_table s then begin
          let release_action = Hashtbl.find release_action_table s in
          release_action ()
        end;
        let p = Player.player() in
        if s <> " " && not (Hashtbl.mem p#playerstate#get OnAirDown) && not (Hashtbl.mem p#playerstate#get OnAirUp) then
          Player.stop_players()
    | Quit -> exit 0
    | _ -> ()
  in
  Hashtbl.iter (fun key action ->
      if has_key key then action ()) action_table

let last_jump = ref 0.0 
let z_released = ref true 

let () =  
  register "a" (fun () -> 
      let player = Player.player() in
      Player.move_player player Cst.player_speed_l;
      Hashtbl.replace player#playerstate#get Left ();
      Hashtbl.remove player#playerstate#get Right
  );
  register "d" (fun () -> 
      let player = Player.player() in
      Player.move_player player Cst.player_speed_r;
      Hashtbl.replace player#playerstate#get Right ();
      Hashtbl.remove player#playerstate#get Left
  );
  register "Shift" (fun () -> Player.(run_player (player())));

  register " " (fun () -> 
    let time = Sys.time () in
    let cd = 0.1 in 
    if time -. !last_jump >= cd && !z_released && Hashtbl.mem (Player.player())#playerstate#get Standing then begin
      last_jump := time;
      z_released := false;
      Player.(jump_player (player()))
    end
  );

  register_release " " (fun () -> 
    z_released := true 
  );