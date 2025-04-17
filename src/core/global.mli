open Component_defs
(* A module to initialize and retrieve the global state *)
type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player : player;
  enemy: enemy list;
  enemy2: enemy2 list;
  enemy3: enemy3 list;
  enemy4: enemy4 list;
  map : string array array;
  texture_tbl : (string, Gfx.surface) Hashtbl.t;
  mutable waiting : int;
}

val get : unit -> t
val set : t -> unit
