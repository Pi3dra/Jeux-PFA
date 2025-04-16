open Ecs
open Component_defs

type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255

let update _dt el =
  let Global.{window; ctx; texture_tbl; player} = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in
  Gfx.set_color ctx white;
  Gfx.fill_rect ctx surface 0 0 ww wh;


  (*TODO: SCALE THIS BEFOREHAND*)
  let scaling = 5 in
  let bg_width = scaling * 384 in
  let bg_height = scaling * 240 in

  let m_width = 2*176 in
  let m_height = 2*368 in
  (* Parallax factor: smaller values make the background move slower *)
  let parallax_factor = 0.1 in

  (* Get player position *)
  let player_pos = player#position#get in
  let player_x = player_pos.x in
  let player_y = player_pos.y in

  (* Calculate base parallax offset relative to player *)
  let base_bg_x = - 200. -.player_x *. parallax_factor in
  let base_bg_x2 = - 200. -.player_x *. 0.2 in
  let base_bg_y = - 200. -.player_y *. parallax_factor in

  (* Draw the background, repeating 10 times left and 10 times right *)
  let draw_background x y =
    match Hashtbl.find_opt texture_tbl "back.png" with
    | None ->
        Texture.draw ctx surface
          (Vector.{x; y})
          (Rect.{width = bg_width; height = bg_height})
          (Anim.Color (Gfx.color 255 255 255 255))
          None
    | Some t ->
        Texture.draw ctx surface
          (Vector.{x; y})
          (Rect.{width = bg_width; height = bg_height})
          (Anim.Image t)
          None
  in

  let draw_middle x y =
    match Hashtbl.find_opt texture_tbl "middle.png" with
    | None ->
        Texture.draw ctx surface
          (Vector.{x; y})
          (Rect.{width = bg_width; height = bg_height})
          (Anim.Color (Gfx.color 255 255 255 255))
          None
    | Some t ->
        Texture.draw ctx surface
          (Vector.{x; y})
          (Rect.{width = m_width; height = m_height})
          (Anim.Image t)
          None
  in

  (* Repeat background 10 times left, 10 times right, and once at base position *)
  for i = -10 to 10 do
    let offset_x = base_bg_x +. float_of_int (i * bg_width) in

    let offest_x2 = base_bg_x2 +. float_of_int (i * m_width) in
    (* Optionally repeat vertically if needed; here we draw at base_bg_y *)
    draw_background offset_x base_bg_y;
    draw_middle offest_x2 (base_bg_y +. 600.)
  done;

  (* Draw foreground elements as before *)
  Seq.iter (fun (e:t) ->
      let pos = e#position#get in
      let box = e#box#get in
      let txt = e#texture#get in
      Texture.draw ctx surface pos box txt None
    ) el