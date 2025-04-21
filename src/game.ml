open System_defs
open Component_defs
open Ecs
open Anim


let init_everything_everywhere_all_at_once () =
  let xpos = ref 0 in
  let ypos = ref 0 in
  let respawneables = ref [] in

  Array.iter
    (fun y ->
      Array.iter
        (fun block ->
          let pos = Vector.{ x = float_of_int !xpos; y = float_of_int !ypos } in

          (*TODO: Merge into wall func?*)
          if block = "00" then
            let txt_metadata, box = Cst.char_to_block block in
            ignore (Prop.prop (pos, box, txt_metadata))

          (*Checkpoint*)
          else if block = "CP" then
            ignore (Checkpoint.checkpoint(pos))

          (*Cherries*)
          else if block = "ch" then
            respawneables := (Pickable_object.pickable_object( pos, Cst.cherry_animation ()) :> respawns) :: !respawneables

          (*Murs/plateformes*)
          else if Cst.str_of_ints block then begin
            let txt_metadata, box = Cst.char_to_block block in

            let tag =
              match block with
              | "21" | "22" | "23" -> Spike
              | "31" -> Falling_Platform
              | "41" | "42"| "43"| "44" -> Platform
              | "51" -> Box
              | "52" -> BBox
              | _ -> Wall
            in

            if tag == Falling_Platform || tag == Box || tag == BBox then begin
              respawneables := ((Wall.wall (pos, box, txt_metadata, tag)) :> respawns) :: !respawneables
            end
            else
              ignore (Wall.wall (pos, box, txt_metadata, tag))
          end

          (*Ennemis*)
          else if block = "OP" || block = "SL" then
            let tag = Cst.char_to_tag block in
            respawneables := (Ground_enemy.ground_enemy (pos, tag):> respawns) :: !respawneables

          else if block = "GH" || block = "EA" then
            let tag = Cst.char_to_tag block in
            respawneables := (Fliying_enemy.fliying_enemy (pos, tag) :> respawns) :: !respawneables

          (*Props Background*)
          else if not (Cst.str_of_ints block) && block <> "  " then begin
            let txt_metadata, box = Cst.char_to_prop block in 
            
            let needs_block = 
              match block with
              | "p1" | "p2" | "p3" | "p4" -> true
              | _ -> false
            in

            if needs_block then begin
              let box = Rect.{width = 32; height = 28} in
              let tpos = Rect.{width = 0; height = 0} in
              ignore (Wall.wall (pos, box, (Anim.Tst("tileset.png",tpos)), Wall))
            end;

              ignore (Prop.prop (pos, box, txt_metadata))
          end;

          xpos := !xpos + Cst.w_width
        )
        y;
      xpos := 0;
      ypos := !ypos + Cst.w_height
    )
    Cst.map;

  (!respawneables)

let update dt =

  

  let Global.{respawneables; player } = Global.get () in

  Player.update_state();
  if Anim.can_change_anim player#animation#get then
    Player.update_anim();
 
  Collision_system.update dt;
  Forces_system.update dt;
  let () = Input.handle_input () in
  Move_system.update dt;
  Trigger_system.update dt;
  Draw_system.update dt;
  Animation_system.update dt;

  None

let run is_sdl =
  let window_spec = 
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in

  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in
  let tileset = Gfx.load_file "resources/tileset.txt" in
  let texture_tbl = Hashtbl.create 10 in

  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt tileset)
    (fun txt ->
       let image_files =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "")
       in

       let images_r =
         image_files
         |> List.map (fun filename -> 
              let image = Gfx.load_image ctx ("resources/images/" ^ filename) in
              (filename, image)
            )
       in

       Gfx.main_loop 
         (fun _dt ->
            if List.for_all (fun (_, img) -> Gfx.resource_ready img) images_r then
              Some (List.map (fun (filename, img) -> (filename, Gfx.get_resource img)) images_r)
            else 
              None
         )
         (fun images ->
           List.iter (fun (filename, img) -> Hashtbl.add texture_tbl filename img) images;
         )
    );


  let respawneables = init_everything_everywhere_all_at_once () in
  let player = Player.players() in

  

  let global = Global.{ window; ctx; player; respawneables;
                        move_g = Ground_enemy.move_ground_enemy ;
                        move_f = Fliying_enemy.move_fliying_enemy;
                        texture_tbl;waiting = 1; is_sdl;} in
  Global.set global;

  Gfx.main_loop update (fun () -> ())
