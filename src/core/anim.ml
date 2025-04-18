
type t = {
  file: string;
  start_pos: Vector.t;
  mutable current_frame: int;
  frames: int;
  mutable last_frame_time : float ref; 
  mutable flip: bool;
  frame_duration: float;
  force_animation: bool;
}
  
type tex =
    Image of Gfx.surface
  | Color of Gfx.color
  | Animation of Gfx.surface 
  | Tileset of (Gfx.surface * Vector.t * Vector.t option)

let blue = Color (Gfx.color 0 0 255 255)
let red = Color (Gfx.color 255 0 0 255)
let yellow = Color (Gfx.color 255 255 0 255)
  
  
let can_change_anim anim =
  if anim.current_frame = anim.frames - 1 && anim.force_animation then begin
    anim.current_frame <- 0;
    true
  end
  else if anim.force_animation then
    false
  else
    true

let default_anim file = {
  file;
  start_pos = Vector.zero;
  current_frame = 0;
  frames = 0;
  last_frame_time = ref 0.0;
  flip = false;
  frame_duration = 100.0;
  force_animation = false
}
