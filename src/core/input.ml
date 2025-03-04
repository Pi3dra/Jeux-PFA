open Gfx
let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s= Hashtbl.replace key_table s ()
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let release_action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action
let register_release key action = Hashtbl.replace release_action_table key action

let handle_input () =
  let () =
    match Gfx.poll_event () with
    | KeyDown s -> 
        (*Gfx.debug "KeyDown: %s"  s;*)
        (*Player.(debug_player( player()));*)
        set_key s
    | KeyUp s ->
        unset_key s;
        if Hashtbl.mem release_action_table s then begin
          let release_action = Hashtbl.find release_action_table s in
          release_action ()
        end;
        Player.stop_players()
    | Quit -> exit 0
    | _ -> ()
  in
  Hashtbl.iter (fun key action ->
      if has_key key then action ()) action_table

  let () =  
    register "a" (fun () -> Player.(move_player (player()) Cst.player_speed_l));
    register "d" (fun () -> Player.(move_player (player()) Cst.player_speed_r));
    register "Shift" (fun () -> Player.(run_player (player()) ));
    register "s" (fun () -> Player.(crouch_player (player()) ));
    register "z" (fun () -> Player.(stand_player (player()) ));
    register " " (fun () -> Player.(jump_player (player())));

    register_release "s" (fun () -> Player.(stand_player (player()) ));
  
