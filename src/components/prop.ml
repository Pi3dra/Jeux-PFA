open Component_defs
open System_defs



let prop (x, y, txt) =
  let e = new prop "prop" in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width = 238; height = 222};

  Draw_system.(register (e :> t));
  e

let init_texture texture_tbl str =
  let (file,box,pos) = Cst.char_to_prop str in


  match pos with 

  None ->
    begin
      match Hashtbl.find_opt texture_tbl file with
        None -> Anim.red
        | Some t ->  Anim.Tileset(t,Vector.zero,Some box )
    end;

  | Some p -> 
    begin
      match Hashtbl.find_opt texture_tbl file with
        None -> Anim.red
        | Some t ->  Anim.Tileset(t,p,Some box )
    end


