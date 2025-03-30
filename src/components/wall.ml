open Component_defs
open System_defs


let wall (x, y, txt, width, height  ) =
  let e = new wall "wall" in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#box#set Rect.{width = width ; height = height};
  e#mass#set infinity(* infinity mass*);
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;

  (*Testing
    Forces_system.(register (e :> t));
    e#mass#set 30.0;
  *)



  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));

  (*Gfx.debug "Registering wall at %f, %f\n" (float x) (float y);*)

  e




let walls texture_tbl = 
  let count = ref 0 in
  Array.iter ( fun y ->
    Array.iter ( fun block ->
      if block = '#' then count := !count + 1
    ) y;
  ) Cst.map;

  (*
  Hashtbl.iter (fun key _ -> Gfx.debug "Loaded texture: %s \n" key) texture_tbl;
  match Hashtbl.find_opt texture_tbl "piso.png"  with
    | None -> Gfx.debug "None\n"
    | _ -> Gfx.debug "some\n";*)

  let walls = Array.make !count (wall (0, 0, Texture.red, 64, 64)) in 


  let xpos = ref 0 in 
  let ypos = ref 0 in 
  let index = ref 0 in 

  Array.iter ( fun y ->
    Array.iter ( fun block ->
      if block = '#' then begin
        let w = wall (!xpos, !ypos, Texture.red, 64, 64) in
        walls.(!index) <- w;
        index := !index + 1;
      end;
      xpos := !xpos + 64
    ) y;
      xpos := 0 ;
      ypos := !ypos + 64;
  ) Cst.map;
      
