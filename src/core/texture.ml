open Anim


let camera_offset = Vector.{ x = float_of_int ( Cst.window_width / 2); y = float_of_int (Cst.window_height/2  ) } 

let get_camera_pos () =
  let Global.{player} = Global.get () in
  let player_pos = player#position#get in
  
  let tile_size = 32 in
  let map_width = (Array.length Cst.map.(0)) * tile_size in
  let map_height = (Array.length Cst.map) * tile_size in 
  
  let screen_width = Cst.window_width in
  let screen_height = Cst.window_height in
  
  let desired_x = player_pos.x -. camera_offset.x in
  let desired_y = player_pos.y -. camera_offset.y in
  
  let clamped_x = max 0. (min desired_x (float_of_int (map_width - screen_width))) in
  let clamped_y = max 0. (min desired_y (float_of_int (map_height - screen_height))) in
  
  Vector.{ x = clamped_x; y = clamped_y }


let draw ctx dst pos box src =

  let camera_pos = get_camera_pos () in
  let screen_x = int_of_float (pos.Vector.x -. camera_pos.x) in
  let screen_y = int_of_float (pos.Vector.y -. camera_pos.y) in
  let Rect.{width; height} = box in

  match src with
    | Image img ->
        Gfx.blit_scale ctx dst img screen_x screen_y width height
    | Color c ->
        Gfx.set_color ctx c;
        Gfx.fill_rect ctx dst screen_x screen_y width height
    | Animation (anim,spritesheet) ->
        let origin = anim.start_pos in
        let frame = anim.current_frame in
        let ox = int_of_float origin.Vector.x in
        let oy = int_of_float origin.Vector.y in
        Gfx.blit_full ctx dst spritesheet (frame * width + ox) oy width height screen_x screen_y width height

    | Tileset (img,pos,_) ->
        let ox = pos.width in
        let oy = pos.height in
        Gfx.blit_full ctx dst img ox oy width height screen_x screen_y width height;