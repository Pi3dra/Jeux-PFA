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

  


  


let props texture_tbl =
  let props = ref [] in
  let xpos = ref 0 in 
  let ypos = ref 0 in 
    
  Array.iter (fun y ->
    Array.iter (fun block ->
      if not(Cst.str_of_ints block) && block <> "  " then begin
        let w = prop (!xpos, !ypos, init_texture texture_tbl block) in
        props := w :: !props
      end;
      xpos := !xpos + Cst.w_width
    ) y;
    xpos := 0;
    ypos := !ypos + Cst.w_height
  ) Cst.map;
      
