open Component_defs

type t = collidable



let init _ = ()

let respawn player =
  player#position#set (player#last_checkpoint#get);
  player#health#set 6;
  player#velocity#set Vector.zero;
  player#sum_forces#set Vector.zero;

  let Global.{respawneables; is_sdl} = Global.get() in

  (*On respawn les enemis/plateformes/cerises etc
  Pour des raisons qui me depassent cela declenche un segafult sous sdl
  mais marche parfaitement sous js
  *)
  if not is_sdl then begin
    List.iter (fun enemy -> enemy#unregister#get false) respawneables;
    List.iter (fun enemy -> enemy#register#get () ) respawneables;
  end



let damage_player player dt =
  if dt -. player#last_damage_time#get >= 500. then begin
    if player#health#get - 1 <= 0 then
      respawn player
    else begin
      player#animation#set (Cst.hurt_animation());
      player#health#set (player#health#get - 1);
      player#last_damage_time#set dt
    end
  end

  let damage_player_spike player dt =
    if dt -. player#last_damage_time#get >= 500. then begin
      let new_health = player#health#get - 500 in
      if new_health <= 0 then
        respawn player
      else begin
        player#animation#set (Cst.hurt_animation());
        player#health#set new_health;
        player#last_damage_time#set dt
      end
    end
  

let damage entity =
  if entity#health#get - 1 <= 0 then
    entity#unregister#get true
  else
    entity#health#set (entity#health#get - 1)

let iter_pairs f s =
  let rec loop s1 =
    match s1 () with
    | Seq.Nil -> ()
    | Seq.Cons(e1, s1') ->
        if e1#on_screen#get then
        Seq.iter (fun e2 ->
          (* On ignore les collisions:
            - Wall et Wall
            - Falling_Platform et Falling_Platform *)
          if e2#on_screen#get && not (
            (e1#tag#get = Wall && e2#tag#get = Wall) ||
            (e1#tag#get = Falling_Platform && e2#tag#get = Falling_Platform)
          ) then
            f e1 e2
        ) s1';
        loop s1'
  in
  loop s


let handle_player_enemy_collision dt enemy enemy_tag (pn: Vector.t) negate_pn =
  let Global.{player} = Global.get() in
    match enemy_tag with
    | Opossum | Eagle | Slime | Ghost | Spike | Boss->
    (* ===== Collision par le haut ===== *)
      if pn.y > 0.0 then begin
        damage enemy;
        let vertical_rebound_strength = 0.8 in
        player#velocity#set (Vector.add player#velocity#get Vector.{x = 0.0; y = -.vertical_rebound_strength});

            (* Special case: Spike *)
        if enemy_tag = Spike then begin
          damage_player_spike player dt
          end;
      end

      (* ===== Collision par le bas ===== *)
      else if pn.y < 0.0 then begin
        damage_player player dt
      end

      (* ===== Collision par les cotes ===== *)
      else begin         
        let horizontal_rebound_strength = 0.8 in
        let rebound_pn = if negate_pn then Vector.neg pn else pn in
    
        let velocity =
            Vector.{x = horizontal_rebound_strength *. (Float.copy_sign 1.0 rebound_pn.x); y = 0.} in
    
        let velocity2 = if not negate_pn then Vector.neg velocity else velocity in

        let rebound_velocity = Vector.{x = velocity2.x; y = -0.3} in
    
        player#animation#set (Cst.hurt_animation());
        player#velocity#set (Vector.add player#velocity#get rebound_velocity);
        damage_player player dt

      end

      | _ -> ()

let update dt el =
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

          (*On evite les collisions par dessous de certaines plateformes*)
          match (e1#tag#get, e2#tag#get) with
          | (Player, Falling_Platform) when pn.y >= 0.0 || v1.y <= 0.3 -> () 
          | (Falling_Platform, Player) when pn.y <= 0.0 || v2.y <= 0.3-> () 
          | (Player, Platform) when pn.y >= 0.0 || v1.y <= 0.00 -> () 
          | (Platform, Player) when pn.y <= 0.0 || v2.y <= 0.00-> () 
          | _ ->
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
              let inv_mass = (1.0 /. m1) +. (1.0 /. m2) in
              let j = Vector.dot (Vector.mult (-1.0 /.inv_mass) vdiff) n in
              let nv1 = Vector.add v1 (Vector.mult (j/.m1) n) in
              let nv2 = Vector.sub v2 (Vector.mult (j/.m2) n) in
              e1#velocity#set nv1;
              e2#velocity#set nv2;

              match (e1#tag#get, e2#tag#get) with
              (*choses sur lesquelles on peut sauter*)
              | (Player, Wall) | (Player , Box) | (Player , BBox) ->
                let pn = Rect.penetration_vector pdiff rdiff in
                if pn.y < 0.0 then 
                  Hashtbl.replace player#playerstate#get Standing ();
              | (Wall, Player) | (Box, Player) | (BBox, Player )->
                let pn = Rect.penetration_vector pdiff rdiff in
                if pn.y > 0.0 then 
                  Hashtbl.replace player#playerstate#get Standing ();
                
              (*Choses sur lesquelles on peut passer par dessous*)
              | (Player, Falling_Platform) | (Player, Platform)->
                let pn = Rect.penetration_vector pdiff rdiff in
                if pn.y < 0.0 then 
                  Hashtbl.replace player#playerstate#get Standing ();
                if e2#tag#get = Falling_Platform then
                  Hashtbl.replace player#playerstate#get Boosted ();

              | (Falling_Platform, Player) | (Platform, Player) ->
                let pn = Rect.penetration_vector pdiff rdiff in
                if pn.y > 0.0 then 
                  Hashtbl.replace player#playerstate#get Standing ();
                if e1#tag#get = Falling_Platform then
                  Hashtbl.replace player#playerstate#get Boosted ();


              (*Choses qui se cassent*)
              | (Falling_Platform, _) ->
                e1#unregister#get true
              | (_, Falling_Platform) ->
                e2#unregister#get true
              | (Box,Spike) | (BBox , Spike) ->
                e1#unregister#get true
              | (Spike,Box) | (Spike, BBox) ->
                e2#unregister#get true

              | (enemy, Player) ->
                handle_player_enemy_collision dt e1 enemy pn true
              | (Player, enemy) ->
                  let inverse_pn = Vector.mult (-.1.0) pn in
                handle_player_enemy_collision dt e2 enemy inverse_pn false

              | (_, _) -> ()
        end
      end)