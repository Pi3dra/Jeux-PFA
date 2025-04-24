open Component_defs

type t = movable

let init _ = ()
let dt = 1000. /. 60.

let is_enemy tag =
  match tag with
  | Opossum | Eagle | Ghost | Slime | Boss -> true
  | _ -> false

let move_ground_enemy (enemy:movable) time =
  let time = time /. 1000.0 in 
  match enemy#tag#get with
  | Opossum ->
      let speed = 0.1 in
      let period = 4.0 in 
      let phase = mod_float time period /. period in
      let direction = if phase < 0.5 then -2.0 else 2.0 in
      let anim = enemy#animation#get in

      anim.flip <- direction > 0.0;

      let enemy_speed = Vector.{ 
        x = direction *. speed; 
        y = 0.0
      } in

      enemy#velocity#set enemy_speed

  | Slime ->
      let speed = 0.1 in
      let move_duration = 0.5 in
      let wait_duration = 0.5 in
      let cycle_duration = 4.0 *. move_duration +. 4.0 *. wait_duration in
      let phase = mod_float time cycle_duration /. cycle_duration in
      let anim = enemy#animation#get in
      let enemy_speed =
        if phase < (move_duration /. cycle_duration) then begin
          anim.flip <- false;
          Vector.{ x = -.speed; y = 0.0 }
        end
        else if phase < ((move_duration +. wait_duration) /. cycle_duration) then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < ((2.0 *. move_duration +. wait_duration) /. cycle_duration) then begin
          anim.flip <- false;
          Vector.{ x = -.speed; y = 0.0 }
        end
        else if phase < ((2.0 *. move_duration +. 2.0 *. wait_duration) /. cycle_duration) then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < ((3.0 *. move_duration +. 2.0 *. wait_duration) /. cycle_duration) then begin
          anim.flip <- true;
          Vector.{ x = speed; y = 0.0 }
        end
        else if phase < ((3.0 *. move_duration +. 3.0 *. wait_duration) /. cycle_duration) then begin
          Vector.{ x = 0.0; y = 0.0 }
        end
        else if phase < ((4.0 *. move_duration +. 3.0 *. wait_duration) /. cycle_duration) then begin
          anim.flip <- true;
          Vector.{ x = speed; y = 0.0 }
        end
        else begin
          Vector.{ x = 0.0; y = 0.0 }
        end
      in

      enemy#velocity#set enemy_speed
  | _ -> ()

  
let move_fliying_enemy (enemy:movable) time =
  let time = time /. 1000.0 in 
  match enemy#tag#get with
  | Ghost ->
      let amplitude = 0.2 in
      let frequency = 2.0 in 
      let horizontal_speed = 0.05 in
      let switch_duration = 8.0 in 

      let anim = enemy#animation#get in
      let direction = 
        if mod_float time (2.0 *. switch_duration) < switch_duration then begin
          if anim.flip then anim.flip <- false; 
          1.0
        end
        else begin
          if not anim.flip then anim.flip <- true; 
          -1.0
        end
      in

      let enemy_speed = Vector.{ 
        x = direction *. horizontal_speed;
        y = amplitude *. cos (frequency *. time) 
      } in
      enemy#velocity#set enemy_speed

  | Eagle ->
      let amplitude = 0.1 in 
      let frequency = 2.0 in  
      let enemy_speed = Vector.{ 
        x = amplitude *. cos (frequency *. time);
        y = amplitude *. sin (frequency *. time)
      } in
      enemy#velocity#set enemy_speed
  | _ -> ()

let move_boss (boss:movable) time =
  let time = time /. 1000.0 in
  match boss#tag#get with
  | Boss ->
      let speed = 0.8 in
      let cycle = 3.4 in
      let phase = mod_float time cycle in
      let direction = 
        if phase < 0.7 then 2.0
        else if phase < 1.7 then 0.0
        else if phase < 2.4 then -2.0
        else 0.0
      in
      let anim = boss#animation#get in
      anim.flip <- phase < 1.7;
      let enemy_speed = Vector.{ 
        x = direction *. speed; 
        y = 0.0
      } in
      boss#velocity#set enemy_speed
  | _ -> ()
  
let update _dt el =
  Seq.iter
    (fun (e : t) ->
      if (e#on_screen#get) || is_enemy (e#tag#get ) then begin 
        let v = e#velocity#get in
        let p = e#position#get in
        let np = Vector.add p (Vector.mult dt v) in
        e#position#set np;
      
        if e#tag#get = Opossum || e#tag#get = Slime then
          move_ground_enemy e  _dt
        else if e#tag#get = Boss then
          move_boss e _dt
        else
          move_fliying_enemy e _dt
      end

      )
        
    el
