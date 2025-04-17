open Component_defs

type t = collidable

let init _ = ()

let rec iter_pairs f s =
  match s () with
    Seq.Nil -> ()
  | Seq.Cons(e, s') ->
    Seq.iter (fun e' -> f e e') s';
    iter_pairs f s'


let handle_player_enemy_collision player_entity enemy_entity enemy_tag (pn: Vector.t) negate_pn =
  match enemy_tag with
  | Enemy1 | Enemy2 | Enemy3 | Enemy4 ->
      (* Collision top down*)
      if pn.y > 0.0 then begin
        
        let enemy_health = enemy_entity#health#get in
        let new_enemy_health = enemy_health - 1 in

        if new_enemy_health <= 0 then
          enemy_entity#unregister#get ()
        else
          enemy_entity#health#set new_enemy_health;
          Gfx.debug "%d \n" enemy_entity#health#get ;

        let vertical_rebound_strength = 1.5 in
        player_entity#velocity#set (Vector.add player_entity#velocity#get
          Vector.{x = 0.0; y = -.vertical_rebound_strength})

      (*Reste des collisions: faire du degat*)
      end else begin
        let current_health = player_entity#health#get in
        let new_health = current_health - 1 in
        if new_health <= 0 then 
          player_entity#unregister#get ()
        else begin
          player_entity#health#set new_health;
          let horizontal_rebound_strength = 0.5 in
          let rebound_pn = if negate_pn then Vector.neg pn else pn in
          let rebound_velocity =
            if abs_float pn.x > abs_float pn.y then
              Vector.{x = horizontal_rebound_strength *. (Float.copy_sign 1.0 rebound_pn.x); y = 0.0}
            else
              Vector.mult horizontal_rebound_strength rebound_pn
          in
          player_entity#velocity#set (Vector.add player_entity#velocity#get rebound_velocity)
        end
      end
  | _ -> ()

let update _ el =
  let Global.{player} = Global.get () in
  el
  |> iter_pairs (fun (e1:t) (e2:t) ->
      let m1 = e1#mass#get in
      let m2 = e2#mass#get in
      if Float.is_finite m1 || Float.is_finite m2 then begin
        let p1 = e1#position#get in
        let b1 = e1#box#get in
        let p2 = e2#position#get in
        let b2 = e2#box#get in
        let pdiff, rdiff = Rect.mdiff p2 b2 p1 b1 in
        if Rect.has_origin pdiff rdiff then begin
          let v1 = e1#velocity#get in
          let v2 = e2#velocity#get in
          let pn = Rect.penetration_vector pdiff rdiff in
          let nv1 = Vector.norm v1 in
          let nv2 = Vector.norm v2 in
          let sv = nv1 +. nv2 in
          let n1, n2 =
            if Float.is_infinite m1 then 0.0, 1.0
            else if Float.is_infinite m2 then 1.0, 0.0
            else nv1 /. sv, nv2 /. sv
          in
          let p1 = Vector.add p1 (Vector.mult n1 pn) in
          let p2 = Vector.sub p2 (Vector.mult n2 pn) in
          e1#position#set p1;
          e2#position#set p2;
          let n = Vector.normalize pn in
          let vdiff = Vector.sub v1 v2 in
          let e = 0. in
          let inv_mass = (1.0 /. m1) +. (1.0 /. m2) in
          let j = Vector.dot (Vector.mult (-.(1.0 +. e)/.inv_mass) vdiff) n in
          let nv1 = Vector.add v1 (Vector.mult (j/.m1) n) in
          let nv2 = Vector.sub v2 (Vector.mult (j/.m2) n) in
          e1#velocity#set nv1;
          e2#velocity#set nv2;

          match (e1#tag#get, e2#tag#get) with
          | (Player, Wall) ->
              let offset = Vector.{x = 0.0; y = -0.5} in
              let pn = Rect.penetration_vector pdiff rdiff in
              if pn.y < 0.0 then 
                Hashtbl.replace player#playerstate#get Standing ();
                e1#position#set (Vector.add e1#position#get offset)

          | (Wall, Player) ->
              let offset = Vector.{x = 0.0; y = 0.01} in
              let pn = Rect.penetration_vector pdiff rdiff in
              if pn.y > 0.0 then 
                Hashtbl.replace player#playerstate#get Standing ();
                e2#position#set (Vector.add e2#position#get offset)

          | (Bullet, Enemy1) ->
              let current_health = e2#health#get in
              let new_health = current_health - 50 in
              if new_health <= 0 then begin
                e2#unregister#get ();
                e1#unregister#get ()
              end else begin
                e2#health#set new_health;
                e1#unregister#get ()
              end
          
          | (Enemy1, Bullet) ->
              let current_health = e1#health#get in
              let new_health = current_health - 50 in
              if new_health <= 0 then begin
                e2#unregister#get ();
                e1#unregister#get ()
              end else begin
                e1#health#set new_health;
                e2#unregister#get ()
              end

          | (enemy, Player) ->
              Gfx.debug "case1 pn: %f %f \n" pn.x pn.y;
              handle_player_enemy_collision e2 e1 enemy pn true
            
          | (Player, enemy) ->
            Gfx.debug "case2 pn: %f %f \n" pn.x pn.y;
              let inverse_pn = Vector.mult (-.1.0) pn in
              handle_player_enemy_collision e1 e2 enemy inverse_pn false

          | (Bullet, _) -> 
              e1#unregister#get ()
          | (_, Bullet) ->
              e2#unregister#get ()

          | (_, _) -> ()
        end
      end)