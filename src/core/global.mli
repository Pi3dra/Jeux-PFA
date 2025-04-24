open Component_defs
(* A module to initialize and retrieve the global state *)
type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player : player;
  respawneables: respawns list;
  texture_tbl : (string, Gfx.surface) Hashtbl.t;
  is_sdl:bool;
  mutable waiting : int;
}

val get : unit -> t
val set : t -> unit
