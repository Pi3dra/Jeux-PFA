open System_defs
open Component_defs
open Ecs

(*
TODO: Make camera track player 
TODO: Make player shoot balls and destory them on collision*)



let update dt =

  (*TODO:
    ici faire une fonction update player, afin de savoir l'etat du joueur 
  s'il peut sauter etc etc
  
  *) (*
  Player.debug_player ( Player.player());*)
  
  
  let Global.{enemy; enemy2;_ } = Global.get () in
   
  Player.on_ground( Player.player());
  List.iter Enemy.move_enemy (enemy);
  List.iter Enemy2.move_enemy2 (enemy2);
 
  let () = Input.handle_input () in
  Collision_system.update dt;
  Forces_system.update dt;
  Move_system.update dt;
  Draw_system.update dt;
  None

let run () =
  let window_spec = 
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in
  (*Ici on peut faire un hastbl avec toutes les textures*)
  
  (*ici on peut charger les mapes*)
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in
  (*
  let font = Gfx.load_font Cst.font_name "" 128 in*)

  let player = Player.players() in
  let enemy = Enemy.enemies1() in
  let enemy2 = Enemy2.enemies2() in

  (* Load the tileset file *)
  let tileset = Gfx.load_file "resources/tileset.txt" in

  (* Create a hashtable to store images *)
  let texture_tbl = Hashtbl.create 10 in

  

  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt tileset)
    (fun txt ->
       (*Gfx.debug("loop1");*)
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

  let _walls = Wall.walls texture_tbl in

  let global = Global.{ window; ctx; player;enemy;enemy2; map = Cst.map; texture_tbl;waiting = 1; } in
  Global.set global;
  Gfx.main_loop update (fun () -> ())
