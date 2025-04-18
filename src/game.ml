open System_defs
open Component_defs
open Ecs



let init_everything_everywhere_all_at_once texture_tbl=
    (*let walls = ref [] in*)
    let xpos = ref 0 in 
    let ypos = ref 0 in 

    let g_enemies = ref [] in
    let f_enemies = ref [] in
      
    Array.iter (fun y ->
      Array.iter (fun block ->

        (*Cet if peut etre ajoute a la fonction wall*)
        if block = "21" || block = "22" || block = "23" then
          ignore (Wall.wall (!xpos, !ypos, Wall.init_texture texture_tbl block, true))
        else if Cst.str_of_ints block  then 
          ignore (Wall.wall (!xpos, !ypos, Wall.init_texture texture_tbl block, false))

        else if block = "OP" || block = "SL" then
          g_enemies := (Ground_enemy.ground_enemy ("ge",!xpos ,!ypos, Cst.char_to_tag block)) :: !g_enemies
        else if block = "GH" || block = "EA" then
          f_enemies := (Fliying_enemy.fliying_enemy ("fe", !xpos ,!ypos, Cst.char_to_tag block)) :: !f_enemies

        else if not(Cst.str_of_ints block) && block <> "  " then
          ignore (Prop.prop (!xpos, !ypos, Prop.init_texture texture_tbl block));

        xpos := !xpos + Cst.w_width
      ) y;
      xpos := 0;
      ypos := !ypos + Cst.w_height
    ) Cst.map;

  (!g_enemies,!f_enemies)

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
  let Global.{ground_enemies;fliying_enemies; player } = Global.get () in
  let current_time = Sys.time () in

  List.iter (fun enemy -> Ground_enemy.move_ground_enemy enemy current_time) ground_enemies;
  List.iter (fun enemy -> Fliying_enemy.move_fliying_enemy enemy current_time) fliying_enemies;


  let () = Input.handle_input () in
  (*playersate*)
  Player.update_state();

  if Anim.can_change_anim player#animation#get then
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

  (*
  let _walls = Wall.walls texture_tbl in
  let enemy = Enemy.enemies1 texture_tbl in
  let enemy2 = Enemy2.enemies2() in
  let enemy3 = Enemy3.enemies3() in
  let enemy4 = Enemy4.enemies4() in*)
  let (ground_enemies, fliying_enemies) = 
         init_everything_everywhere_all_at_once texture_tbl in

  let player = Player.players() in
  (*let _props = Prop.props texture_tbl in*)

  let global = Global.{ window; ctx; player;ground_enemies;fliying_enemies; map = Cst.map; texture_tbl;waiting = 1; } in
  Global.set global;



  Gfx.main_loop update (fun () -> ())
