open Component_defs
open System_defs

let delete e =
  Animation_system.unregister(e :> Animation.t)

let animated_prop (x, y, animation) =
  let e = new animated_prop "prop" in
  e#animation#set animation;
  e#tag#set Remove_on_end;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width = 64; height = 64};
  e#unregister#set (fun () -> 
                    animation.current_frame <- 0;
                    delete e);
  Animation_system.(register (e :> t));
  e

(*
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

*)