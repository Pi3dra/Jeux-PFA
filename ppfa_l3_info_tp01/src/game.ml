(* entity*)

type entity = int


(*Components*)
type texture =
    Color of Gfx.color
  | Image of Gfx.surface


type animation = {
  n_frames : int;
  frames: texture list;
  mutable current_frame: int;
}

type body = {
  mutable x : int;
  mutable y : int;
  (*Hitbox*)
  mutable width : int;
  mutable height: int;
}

type health = int
type damage = int  

let color r g b a = Color (Gfx.color r g b a ) 
let white = color 255 255 255 255 
let events = Hashtbl.create 16   


type block = {
  (*Blocs peuvent bouger*)
  mutable x: int;
  mutable y: int; 

  height: int;
  width: int;

  (*Etat de l'animation si il y en a 0 sinon*)
  animation_state : int;
  animation : texture array option;
}

type entity = {
  (*Blocs peuvent bouger*)
  mutable x: int;
  mutable y: int;
  mutable health: int;

  height: int;
  width: int;

  (*Etat de l'animation si il y en a 0 sinon*)
  animation_state : int;
  animation : texture array option;
}


(*TODO:  one's static and the other one isn't
  separate function for animating entities from drawing rectangles
*)



type state = Idle | Left | Right (*add logic for jumping later*) 


type config = {
  (* Informations des touches *)
  key_left: string;
  key_up : string;
  key_down : string;
  key_right : string;

  (* Informations de fenêtre *)
  window : Gfx.window;
  surface : Gfx.surface;
  context : Gfx.context;

  (*Temps *)
  mutable last_dt : float;
  mutable state: int;

  (**)
  mutable flipped: bool;
  mutable x: int;
  mutable y: int;
  textures : texture array;
}


(* On crée une fenêtre *)

let draw_rect config texture (position: int*int) w h flipped =
  Gfx.set_color config.context (Gfx.color 255 0 0 255);
  Gfx.fill_rect config.context config.surface  40 40 10 10;

  let size = 32 in
  
  (*handles flipping doit etre dehors*)
  Gfx.set_transform config.context 0.0 flipped false;
  match texture with
  | Color c -> 
    begin

    Gfx.set_color config.context c;
    Gfx.fill_rect config.context config.surface (fst position) (snd position) w h;
    Gfx.reset_transform config.context
    end;
  | Image i -> 
    (*blit_full ctx dst src sx sy sw sh dx dy dw dh copies 
    the surface extracted from src at point (sx, sy) with dimensions (sw, sh)
     on surface dst at point (dx,dy) scaling it to dw width and dh height*)

    Gfx.blit_full config.context config.surface i 
    (config.state*size) (3*size) size size  (*Three indicates the number of the animation*)
    (fst position) (snd position) (size) (size) (*Upscaling is trash as it isnt bilinear*)
  





let update cfg dt = 
  begin
    match Gfx.poll_event () with
      Gfx.NoEvent -> ()
    | Gfx.KeyDown s -> Gfx.debug "%s@\n%!" s; Hashtbl.replace events s ()
    | Gfx.KeyUp s -> Hashtbl.remove events s
    | _ -> ()
  end;
  
  if Hashtbl.mem events cfg.key_left then begin
    cfg.x <- cfg.x - 5;
    cfg.flipped <- true;
  end;
  if Hashtbl.mem events cfg.key_right then begin
    cfg.x <- cfg.x + 5;
    cfg.flipped <- false;
  end;
  if Hashtbl.mem events cfg.key_up then cfg.y <- cfg.y - 5;
  if Hashtbl.mem events cfg.key_down then cfg.y <- cfg.y + 5;

  if dt -. cfg.last_dt > 100. then begin
    cfg.last_dt <- dt;
    cfg.state <- (cfg.state + 1) mod 8 (*n frames*);
  end;

  let w_size = Gfx.get_window_size(cfg.window) in
  draw_rect cfg white (0,0) (fst w_size) (snd w_size) cfg.flipped; 
  draw_rect cfg (cfg.textures.(0)) (cfg.x,cfg.y) 30 30 cfg.flipped; 

  None
  


let run keys =
(* Question 4.2.1 *)
let window = Gfx.create "game_canvas:800x600:" in
let surface = Gfx.get_surface window in
let context = Gfx.get_context window in

(* Question 4.3.1 *)
let tile_set_r = Gfx.load_file "resources/files/tile_set.txt" in
Gfx.main_loop
  (fun _dt -> Gfx.get_resource_opt tile_set_r)
  (fun txt ->
     let images_r =
       txt
       |> String.split_on_char '\n'
       |> List.filter (fun s -> s <> "") (* retire les lignes vides *)
       |> List.map (fun s -> Gfx.load_image context ("resources/images/" ^ s))
     in
     Gfx.main_loop (fun _dt ->
         if List.for_all Gfx.resource_ready images_r then
           Some (List.map Gfx.get_resource images_r)
         else None
       )
       (fun images ->
          let textures = images
                         |> List.map (fun img -> Image img)
                         |> Array.of_list
          in


          let cfg = {
            (* Question 4.2.3 *)
            key_left = keys.(0);
            key_right = keys.(1);
            key_up = keys.(2);
            key_down = keys.(3);
            window = window;
            surface = surface;
            context = context;
            (* Question 4.2.4 *)
            last_dt = 0.0;
            textures = textures; (* réutilise textures défini plus haut *)
            state = 0;
            (* Question 4.2.5 *)
            flipped = false;
            x = 100;
            y = 100;
          }
          in Gfx.main_loop (update cfg) (fun () -> ())
       ))