open System_defs
open Component_defs
open Ecs

(*
TODO: Make player shoot balls and destory them on collision*)



let update dt =

  (*
  let Global.{texture_tbl} = Global.get () in
  Hashtbl.iter (fun k v -> Gfx.debug "%s " k ) texture_tbl;
  Gfx.debug "\n";
  *)
  
  (*Gitanada, lanzar un update para actualizar nada mas las texturas
  Wall.walls texture_tbl;
  *)

    (*
  let p = Player.player() in
  Player.update_anim();
   Player.debug_states(Player.player());
     let (v:Vector.t) = p#velocity#get in
  Gfx.debug "%f %f  " v.x v.y;
  *)

  (*Movement enemy1*)
  let Global.{enemy;enemy2 } = Global.get () in
  let current_time = Sys.time () in

  List.iter (fun enemy -> Enemy.move_enemy enemy current_time) enemy;

  (*Movement enemy2*)

  List.iter (fun enemy -> Enemy2.move_enemy2 enemy current_time) enemy2;



  let () = Input.handle_input () in
  (*playersate*)
  Player.update_state();
  Player.update_anim();
 
  Collision_system.update dt;
  Forces_system.update dt;
  Move_system.update dt;
  Draw_system.update dt;
  Animation_system.update dt;
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


    (*Apparament ça ne charge pas avant.*)
  let _walls = Wall.walls texture_tbl in
  let enemy2 = Enemy2.enemies2() in
  let player = Player.players() in

  let enemy = Enemy.enemies1 texture_tbl in



  let _props = Prop.props texture_tbl in

  let global = Global.{ window; ctx; player;enemy;enemy2; map = Cst.map; texture_tbl;waiting = 1; } in
  Global.set global;



  Gfx.main_loop update (fun () -> ())
