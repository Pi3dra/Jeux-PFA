(*
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
V                               V
V  1                         2  V
V  1 B                       2  V
V  1                         2  V
V  1                         2  V
V                               V
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*)


  let map = 
[|
 [|'#';' ';' ';' ';' '; ' ' ;' ';' ';' ';' ';' '; ' ' ;'#';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';' ';' ';' ';' '; ' ' ;'#';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';' ';' ';' ';' '; ' ' ;'#';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';' ';' ';' ';' '; ' ' ;'#';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';' ';' ';' ';'#'; ' ' ;'#';|];
 [|'#';'#';'#';'#';'#'; '#' ;'#';'#';'#';'#';'#'; '#' ;'#';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';|];
 [|'#';' ';' ';' ';' '; ' ' ;' ';|];
 [|'#';'#';'#';'#';'#'; '#' ;'#';|]; |] 


let window_width = 800
let window_height = 600


let paddle_color = Texture.blue
let paddle_color2 = Texture.red


let player_speed_r = Vector.{ x = 0.1; y = 0.}
let player_speed_l = Vector.{ x = -0.1; y = 0.}


let font_name = if Gfx.backend = "js" then "monospace" else "resources/images/monospace.ttf"
let font_color = Gfx.color 0 0 0 255
