open Anim

(* Camera offset: adjust to position player on screen *)
let camera_offset = Vector.{ x = float_of_int ( Cst.window_width / 2); y = float_of_int (2*Cst.window_height/3  ) } 

let get_camera_pos () =
  let Global.{player} = Global.get () in
  let player_pos = player#position#get in
  Vector.{ x = player_pos.x -. camera_offset.x; y = player_pos.y -. camera_offset.y }

let draw ctx dst pos box src (animation: Anim.t option) =

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
    | Animation c ->
        let animm = match animation with
          | None -> Anim.default_anim "tileset.png"
          | Some animation -> animation
        in
        let origin = animm.start_pos in
        let frame = animm.current_frame in
        let ox = int_of_float origin.Vector.x in
        let oy = int_of_float origin.Vector.y in

        (*
        if animm.file = "foxy.png" then
          Gfx.debug "current frame : %d \n " frame;*)
        Gfx.blit_full ctx dst c (frame * width + ox) oy width height screen_x screen_y width height

    | Tileset (img,pos,dim) ->
        let ox = int_of_float pos.x in
        let oy = int_of_float pos.y in

        match dim with 
        | None ->
          Gfx.blit_full ctx dst img ox oy width height screen_x screen_y width height
        | Some d ->
          let dx = int_of_float d.x in
          let dy = int_of_float d.y in
          Gfx.blit_full ctx dst img ox oy dx dy screen_x screen_y dx dy
          
