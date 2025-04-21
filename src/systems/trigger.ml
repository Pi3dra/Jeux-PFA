open Component_defs

type t = triggerable

let init _ = ()

let rec iter_pairs f s =
  match s () with
    Seq.Nil -> ()
  | Seq.Cons(e, s') ->
      Seq.iter (fun e' -> f e e') s';
      iter_pairs f s'


let check_collision p1 b1 p2 b2 =
  let pdiff, rdiff = Rect.mdiff p2 b2 p1 b1 in
  if Rect.has_origin pdiff rdiff then
    Some (Rect.penetration_vector pdiff rdiff)
  else
    None

let handle_player_cherry p c =
  if p#health#get < 6 then
    p#health#set (p#health#get + 1);
  c#unregister#get true

let handle_player_checkpoint p c =
  let (c_box: Rect.t) = c#box#get in
  let width = float_of_int c_box.width in
  let height = float_of_int c_box.height in

  let c_pos = c#position#get in
  p#last_checkpoint#set Vector.{x = c_pos.x +. (width/.2.) -. (float_of_int Cst.p_width)/.2.; 
                                y = c_pos.y +. height -. float_of_int Cst.p_height }

let update _ el =
  let Global.{player} = Global.get () in
  el
  |> iter_pairs (fun (e1:t) (e2:t) ->
      let p1 = e1#position#get in
      let b1 = e1#box#get in
      let p2 = e2#position#get in
      let b2 = e2#box#get in
      match check_collision p1 b1 p2 b2 with
      | Some pn ->
          let tag1 = e1#tag#get in
          let tag2 = e2#tag#get in
          begin
          match (tag1,tag2) with
          
          | (Player,Cherry) ->
            handle_player_cherry player e2
          | (Cherry, Player) ->
            handle_player_cherry player e1  

          | (Player,Checkpoint) ->
            handle_player_checkpoint player e2
          | (Checkpoint, Player) ->
            handle_player_checkpoint player e1  
            
          | _ -> ()
          end;

      | None -> ()
    )

