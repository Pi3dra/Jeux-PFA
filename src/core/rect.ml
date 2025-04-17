open Vector
type t = { width : int; height : int }


let mdiff v1 r1 v2 r2 =
  (* We use the Minkowski difference of Box1 and Box2 *)
  let x = v1.x -. v2.x -. float r2.width in
  let y = v1.y -. v2.y -. float r2.height in
  let h = r1.height + r2.height in
  let w = r1.width + r2.width in
  ({ x; y }, { width = w; height = h })

let min_norm v1 v2 =
    if Vector.norm v1 <= Vector.norm v2 then v1 else v2
  

let penetration_vector s_pos s_rect =
    let n0 = Vector.{ x = 0.0; y = s_pos.y } in
    let n1 = min_norm n0 Vector.{ x = 0.0; y = float s_rect.height +. s_pos.y } in
    let n2 = min_norm n1 Vector.{ x = s_pos.x; y = 0.0 } in
    min_norm n2 Vector.{ x = float s_rect.width +. s_pos.x; y = 0.0 }


  
let has_origin v r =
  v.x < 0.0
  && v.x +. float r.width > 0.0
  && v.y < 0.0
  && v.y +. float r.height > 0.0
    

let has_origin v r =
  v.x < 0.0
  && v.x +. float r.width > 0.0
  && v.y < 0.0
  && v.y +. float r.height > 0.0

let intersect v1 r1 v2 r2 =
  let v, r = mdiff v1 r1 v2 r2 in
  has_origin v r
