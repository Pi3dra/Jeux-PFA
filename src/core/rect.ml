open Vector
type t = { width : int; height : int }


let mdiff v1 r1 v2 r2 =
  (* We use the Minkowski difference of Box1 and Box2 *)
  let x = v1.x -. v2.x -. float r2.width in
  let y = v1.y -. v2.y -. float r2.height in
  let h = r1.height + r2.height in
  let w = r1.width + r2.width in
  ({ x; y }, { width = w; height = h })

let has_origin v r =
  v.x < 0.0
  && v.x +. float r.width > 0.0
  && v.y < 0.0
  && v.y +. float r.height > 0.0

let intersect v1 r1 v2 r2 =
  let v, r = mdiff v1 r1 v2 r2 in
  has_origin v r
