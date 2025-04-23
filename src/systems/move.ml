open Component_defs

type t = movable

let init _ = ()
let dt = 1000. /. 60.

let update _dt el =
  let Global.{move_g;move_f;move_b} = Global.get () in
  Seq.iter
    (fun (e : t) ->
      let v = e#velocity#get in
      let p = e#position#get in
      let np = Vector.add p (Vector.mult dt v) in
      e#position#set np;

      
      if e#tag#get = Opossum || e#tag#get = Slime then
        move_g e  _dt
      else if e#tag#get = Boss then
        move_b e _dt
      else
        move_f e _dt
      ) 
    el
