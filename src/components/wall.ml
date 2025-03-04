open Component_defs
open System_defs


let wall (x, y, txt, width, height  ) =
  let e = new wall "wall" in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#box#set Rect.{width = width ; height = height};
  e#mass#set infinity (* infinity mass*);
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;


  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  (*Forces_system.(register (e :> t));*)
  Move_system.(register (e :> t));

  (*Gfx.debug "Registering wall at %f, %f\n" (float x) (float y);*)

  e




let walls () = 
  let count = ref 0 in
  Array.iter ( fun y ->
    Array.iter ( fun block ->
      if block = '#' then count := !count + 1
    ) y;
  ) Cst.map;

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
      
