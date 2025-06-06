type t = { x : float; y : float }

let add a b = { x = a.x +. b.x; y = a.y +. b.y }
let sub a b = { x = a.x -. b.x; y = a.y -. b.y }

let neg v = { x = -.v.x ; y = -.v.y}

let mult k a = { x = k*. a.x; y = k*. a.y }

let k_add k a = { x = k +. a.x; y = k +. a.y }

let dot a b =  a.x *. b.x +. a.y *. b.y
let norm a = sqrt(dot a a)
let normalize a = 
  let tenpo = norm a in 
   {x = a.x/.tenpo ; y = a.y/.tenpo}
   
let pp fmt a = Format.fprintf fmt "(%f, %f)" a.x a.y

let zero = { x = 0.0; y = 0.0 }
let is_zero v = v.x = 0.0 && v.y = 0.0