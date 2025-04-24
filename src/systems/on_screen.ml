open Component_defs

type t = loadable

let init _ = ()

let update _dt el =
  Seq.iter
    (fun (e : t) ->
      let camera_pos = Texture.get_camera_pos () in
      let screen_width = float_of_int Cst.window_width in
      let screen_height = float_of_int Cst.window_height in

      let is_on_screen entity =
        let pos = entity#position#get in
        let box = entity#box#get in
        let x = pos.Vector.x in
        let y = pos.Vector.y in
        let Rect.{width; height} = box in
        let right = x +. float_of_int width in
        let bottom = y +. float_of_int height in
        let left = x in
        let top = y in
        let cam_x = camera_pos.Vector.x in
        let cam_y = camera_pos.Vector.y in
        right >= cam_x && left <= cam_x +. screen_width &&
        bottom >= cam_y && top <= cam_y +. screen_height
      in

      let on_screen =  is_on_screen e in
      e#on_screen#set on_screen;
      )
    el
