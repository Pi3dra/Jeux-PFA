open Ecs

class position () =
  let r = Component.init Vector.zero in
  object
    method position = r
  end

class box  () =
  let r = Component.init Rect.{width = 0; height = 0} in
  object
    method box = r
  end

class texture  () =
  let r = Component.init (Anim.Img "tileset.png") in
  object
    method texture = r
  end

class animation () =
  let r = Component.init( Anim.default_anim "atlas.png") in
  object 
    method animation = r
end

class health () =
  let r = Component.init 0 in
  object
    method health  = r
  end

class removable () =
  let r = Component.init (fun (a:bool)->()) in
  object 
    method unregister = r
end

class respawnable () =
  let r = Component.init (fun ()->()) in
  object 
    method register = r
end




type tag = Wall | No_tag | Player | Bullet | Opossum | Eagle | Slime | Ghost | Spike
          | Remove_on_end | Cherry | Removed | Checkpoint | Falling_Platform | Platform | Box | BBox


class tagged ()  =
  let r = Component.init No_tag in
  object
    method tag = r
  end

class velocity () =
  let r = Component.init (Vector.zero) in
  object 
    method velocity = r
  end

class mass () =
  let r = Component.init 0.0 in 
  object 
    method mass = r
  end

class sum_forces () =
  let r = Component.init (Vector.zero) in 
  object 
    method sum_forces = r
  end

class id =
  let r = Component.init 0 in
  object
    method id = r
  end


type state = Moving | Standing | Crouching | OnAirUp | OnAirDown | Idle | Left | Right | Boosted

class playerstate =
  let r = Component.init (Hashtbl.create 10 : (state, unit) Hashtbl.t) in
object
  method playerstate = r
end

class last_checkpoint () = 
  let r = Component.init (Vector.zero) in
  object
    method last_checkpoint = r
  end

class last_damage_time () =
  let r = Component.init (0.) in
  object
    method last_damage_time = r
  end



(** Interfaces : ici on liste simplement les types des classes dont on hérite
    si deux classes définissent les mêmes méthodes, celles de la classe écrite
    après sont utilisées (héritage multiple).
*)

class respawns () =
  object
  inherit respawnable ()
  inherit removable ()
  end


class  collidable () =
  object
    inherit Entity.t () 
    inherit respawnable()
    inherit tagged()
    inherit removable()
    inherit position ()
    inherit velocity () 
    inherit box ()
    inherit mass ()
    inherit health ()
  end

class triggerable () =
  object
    inherit Entity.t ()
    inherit tagged ()
    inherit removable ()
    inherit position ()
    inherit box ()
  end

class  physics () =
  object
    inherit Entity.t ()
    inherit tagged ()
    inherit mass ()
    inherit sum_forces ()
    inherit velocity ()
  end

class  drawable () =
  object
    inherit Entity.t ()
    inherit position () 
    inherit box ()
    inherit texture ()
  end

class  animated() =
  object
    inherit Entity.t ()
    inherit tagged ()
    inherit removable ()
    inherit position () 
    inherit box ()
    inherit animation ()
  end

class  movable () =
  object
  inherit Entity.t ()
  inherit position ()
  inherit velocity ()
  inherit animated()
  inherit tagged () (*CHANGED*)
  end

(** Entités :
    Ici, dans inherit, on appelle les constructeurs pour qu'ils initialisent
    leur partie de l'objet, d'où la présence de l'argument 
*)
class player name =
  object
    inherit Entity.t ~name ()
    inherit playerstate 

    inherit animated ()
    inherit physics () 
    inherit collidable ()
    inherit movable ()
    inherit last_checkpoint () 
    inherit last_damage_time()
  end

  class ground_enemy name =
  object
    inherit Entity.t ~name()
    inherit respawns()
    inherit animated()
    inherit physics()
    inherit collidable()
    inherit movable()
  end

class fliying_enemy name =
  object
    inherit Entity.t ~name()
    inherit respawns()
    inherit animated()
    inherit collidable()
    inherit movable()
  end


class bullet name = 
  object
    inherit Entity.t ~name ()

    inherit drawable ()
    inherit physics ()
    inherit collidable ()
    inherit movable ()

  end

class wall name =
  object
    inherit Entity.t ~name ()
    inherit respawns()
    inherit tagged ()
    inherit drawable () 
    inherit animated()
    inherit collidable ()
    inherit physics ()
end

class prop name =
  object
    inherit Entity.t ~name ()
    inherit drawable () 
end

class animated_prop name =
  object
    inherit Entity.t ~name ()
    inherit tagged ()
    inherit removable ()
    inherit animated () 
end

class pickable_object name =
  object
  inherit Entity.t ~name ()
  inherit respawns()
  inherit triggerable ()
  inherit animated ()
  end

class checkpoint name =
  object
  inherit Entity.t ~name ()
  inherit triggerable ()
  inherit drawable ()
  end


class platform name =
  object
    inherit Entity.t ~name ()
    inherit tagged ()
    inherit drawable()
    inherit collidable ()
  end