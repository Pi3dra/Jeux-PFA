open Component_defs

type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player: player;
  enemy: enemy list;
  enemy2: enemy2 list;
  enemy3: enemy2 list;
  enemy4: enemy4 list;
  map : string array array;
  texture_tbl: (string , Gfx.surface) Hashtbl.t;
  mutable waiting : int;
}

let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s
