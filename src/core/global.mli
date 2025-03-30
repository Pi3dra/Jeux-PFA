open Component_defs
(* A module to initialize and retrieve the global state *)
type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player : player;
  enemy: enemy list;
  map : char array array;
  texture_tbl : (string, Gfx.surface) Hashtbl.t;
  mutable waiting : int;
}

val get : unit -> t
val set : t -> unit
