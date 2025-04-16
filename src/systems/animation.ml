open Ecs
open Component_defs
open Anim

type t = animated

let init _ = ()

let last_dt = ref 0.0  

let update dt el =
  let Global.{window; ctx; texture_tbl} = Global.get () in
  let surface = Gfx.get_surface window in

  let delta_time = dt -. !last_dt in
  last_dt := dt; 

  Seq.iter (fun (e : t) -> 
    let pos = e#position#get in
    let box = e#box#get in
    let anim = e#animation#get in

    let tileset = anim.file in

    let loaded_texture = 
      match tileset with  
      | "Red" -> red
      | key -> 
          match Hashtbl.find_opt texture_tbl key with
          | Some img -> Animation(img)
          | None -> red
    in

    anim.last_frame_time := !(anim.last_frame_time) +. delta_time;

    if !(anim.last_frame_time) >= anim.frame_duration then begin
      anim.last_frame_time := !(anim.last_frame_time) -. anim.frame_duration;  
      
      anim.current_frame <- 
        if anim.current_frame + 1 >= anim.frames then 
          0
        else 
          anim.current_frame + 1;
    end;

    if anim.flip then  
      Gfx.set_transform ctx 0.0 true false;
    
    Texture.draw ctx surface pos box loaded_texture (Some anim);

    Gfx.reset_transform ctx
  ) el;

  Gfx.commit ctx