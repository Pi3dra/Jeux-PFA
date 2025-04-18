open Component_defs
open System_defs



let wall (x, y, txt, spike) =
  let e = new wall "wall" in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width = Cst.w_width; height = Cst.w_height};

  e#mass#set infinity(* infinity mass*);
  e#velocity#set Vector.zero;
  e#sum_forces#set Vector.zero;
  
  if spike then
    e#tag#set Spike
  else 
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
  
