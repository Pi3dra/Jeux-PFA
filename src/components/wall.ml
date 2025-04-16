open Component_defs
open System_defs



let wall (x, y, txt) =
  let e = new wall "wall" in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width = Cst.w_width; height = Cst.w_height};

  e#mass#set infinity(* infinity mass*);
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  e#tag#set Wall;


  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  e

let init_texture texture_tbl str =
  let pos = Cst.char_to_vect str in

  match Hashtbl.find_opt texture_tbl "tileset.png" with
    None -> Anim.red
    | Some t -> Anim.Tileset (t,pos,None)
  


let walls texture_tbl =
  let walls = ref [] in
  let xpos = ref 0 in 
  let ypos = ref 0 in 
    
  Array.iter (fun y ->
    Array.iter (fun block ->
      if Cst.str_of_ints block  then begin
        let w = wall (!xpos, !ypos, init_texture texture_tbl block) in
        walls := w :: !walls
      end;
      xpos := !xpos + Cst.w_width
    ) y;
    xpos := 0;
    ypos := !ypos + Cst.w_height
  ) Cst.map;
      
