
type t = {
  file: string;
  start_pos: Vector.t;
  mutable current_pos: Vector.t;
  mutable current_frame: int;
  frames: int;
  mutable last_frame_time : float ref; 
  mutable flip: bool;
  frame_duration: float;
}
  
type tex =
    Image of Gfx.surface
  | Color of Gfx.color
  | Animation of Gfx.surface (*TODO: Modifier ceci pour passer une animation*)
  | Tileset of (Gfx.surface * Vector.t * Vector.t option)

let blue = Color (Gfx.color 0 0 255 255)
let red = Color (Gfx.color 255 0 0 255)

let yellow = Color (Gfx.color 255 255 0 255)
  
  
let default_anim file = {
  file;
  start_pos = Vector.zero;
  current_pos = Vector.zero;
  current_frame = 0;
  frames = 0;
  last_frame_time = ref 0.0;
  flip = false;
  frame_duration = 100.0
}
