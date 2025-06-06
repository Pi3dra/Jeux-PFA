open Component_defs

type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player: player;
  respawneables: respawns list;
  texture_tbl: (string , Gfx.surface) Hashtbl.t;
  is_sdl: bool;
  mutable waiting : int;
}

let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s
