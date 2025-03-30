open Ecs
open Component_defs

type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255



let update _dt el =
  let Global.{window;ctx;texture_tbl} = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in
  Gfx.set_color ctx white;
  Gfx.fill_rect ctx surface 0 0 ww wh;

  (*Player.(debug_player (player()));
  ceci ne marche pas jsp pourquoi
   *)

  (*
   let piso = Hashtbl.find_opt texture_tbl "piso.png" in
   match piso with
   | Some img -> 
      Texture.draw ctx surface (Vector.{x = 0. ; y = 0. }) (Rect.{width = 64; height = 64}) (Texture.Image(img));
      (*Gfx.blit_scale ctx surface img 0 0 64 64*)
   | None -> ();   
   *)

  (*Hashtbl.iter (fun k v -> Gfx.debug "%s" k) texture_tbl;
  Gfx.debug("lol\n");*)
  Seq.iter (fun (e:t) -> 
      let pos = e#position#get in
      let box = e#box#get in
      let txt = e#texture#get in
      Texture.draw ctx surface pos box txt
    ) el;



  (*Mover a constantes*)
   (*
  let current_map = (Global.get()).map in 
  let xpos = ref 0.0 in
  let ypos = ref 0.0 in 

 

  Array.iter ( fun y ->
    Array.iter ( fun block ->
      if block = '#' then begin
        let pos = Vector.{ x = !xpos; y = !ypos} in 
        let box = Rect.{width = 64; height = 64} in
        let txt = Texture.black in
        Texture.draw ctx surface pos box  txt
      end;
      xpos := !xpos +. 64.
    ) y;
      xpos := 0. ;
      ypos := !ypos +. 64.;
  ) current_map;
*)
  Gfx.commit ctx
