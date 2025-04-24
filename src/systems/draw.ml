open Ecs
open Component_defs

type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255
let red = Anim.Color (Gfx.color 255 0 0 255) 

let update _dt el =
  let Global.{window; ctx; texture_tbl; player} = Global.get () in

  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in
  Gfx.set_color ctx white;
  Gfx.fill_rect ctx surface 0 0 ww wh;

  (* ============= Dessin Background =============*)
  let scaling = 5 in

  let bg_width = scaling * 384 in
  let bg_height = scaling * 240 in

  let m_width = 2 * 176 in
  let m_height = 2 * 368 in

  let parallax_factor = 0.1 in

  let Vector.{x;y} = player#position#get in
  let player_x = x in
  let player_y = y in

  let base_bg_x = -200. -. player_x *. parallax_factor in

  let base_m = -200. -. player_x *. 0.2 in
  let base_bg_y = -200. -. player_y *. parallax_factor in


  (*Dessiner textures manquantes*)
  let fallback x y width height =
    Texture.draw ctx surface (Vector.{x;y}) (Rect.{width;height}) red 
  in

  (*TODO: Merge this into a func*)
  let draw_background x y =
    match Hashtbl.find_opt texture_tbl "back.png" with
    | None ->
      fallback x y bg_width bg_height;
    | Some t ->
        Texture.draw ctx surface
          (Vector.{x; y})
          (Rect.{width = bg_width; height = bg_height})
          (Anim.Image t)
          
  in

  let draw_middle x y =
    match Hashtbl.find_opt texture_tbl "middle.png" with
    | None ->
      fallback x y m_width m_height;
    | Some t ->
        Texture.draw ctx surface
        (Vector.{x; y})
        (Rect.{width = m_width; height = m_height})
        (Anim.Image t)
     
  in

  for i = -10 to 10 do
    let offset_x = base_bg_x +. float_of_int (i * bg_width) in
    draw_background offset_x base_bg_y;
  done;

  for i = -40 to 40 do
    let offset_m = base_m +. float_of_int (i * m_width) in
    draw_middle offset_m (base_bg_y +. 600.)
  done;

 (*============= Dessin Monde/Entités =============*)


 
 Seq.iter (fun (e:t) ->
   let pos = e#position#get in
   let box = e#box#get in

   if e#on_screen#get then begin
     let txt = e#texture#get in
     match txt with  
     | Img file ->
         begin
         match Hashtbl.find_opt texture_tbl file with
           | None -> fallback pos.x pos.y box.width box.height
           | Some texture -> Texture.draw ctx surface pos box (Anim.Tileset (texture, Rect.{width = 0; height = 0}, None)) 
         end
     | Tst (file, tilesetpos) ->
         begin
         match Hashtbl.find_opt texture_tbl file with
           | None -> fallback pos.x pos.y box.width box.height
           | Some texture -> Texture.draw ctx surface pos box (Anim.Tileset (texture, tilesetpos, None)) 
         end
     | Clr c -> Texture.draw ctx surface pos box (Anim.Color c)
   end
 ) el;
  (*============= Dessin UI (coeurs lol) =============*)

  let start_pos = Vector.{x=10.; y=10.} in
  let playerhealth = player#health#get in
  let heart_states = match playerhealth with
    | 1 -> ["h"; "e"; "e"]
    | 2 -> ["f"; "e"; "e"]
    | 3 -> ["f"; "h"; "e"]
    | 4 -> ["f"; "f"; "e"]
    | 5 -> ["f"; "f"; "h"]
    | 6 -> ["f"; "f"; "f"]
    | _ -> ["e"; "e"; "e"]
  in

  let draw_heart state pos =
    let camera_pos = Texture.get_camera_pos () in
    let heart_pos = Vector.{ x = pos.x +. camera_pos.x; y = pos.y +. camera_pos.y } in
    let sprite_pos = match state with
      | "f" -> Rect.{width = 0 ; height = 0}
      | "h" -> Rect.{width = 32 ; height = 0}
      | "e" -> Rect.{width = 64 ; height = 0}
      | _ -> Rect.{width = 0; height = 0}
    in
    
    let heart_size = Rect.{width=32; height=32} in
    
    
    match Hashtbl.find_opt texture_tbl "heart-sprites.png" with
    | Some t ->
        Texture.draw ctx surface heart_pos
          (Rect.{width=32; height=32})
          (Anim.Tileset (t, sprite_pos, Some heart_size))
    | None ->
      fallback heart_pos.x heart_pos.y 32 32;
  in

  List.iteri (fun i state ->
    let pos = Vector.{x=start_pos.x +. float_of_int (i * 38); y=start_pos.y} in
    draw_heart state pos
  ) heart_states;
  
  (*Gfx.commit ctx*)