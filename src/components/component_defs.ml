open Ecs
                (*Lista animaciones, Width, height, fps, number of frames*)
type animation = Gfx.surface list * int * int *int 

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
  let r = Component.init (Texture.Color (Gfx.color 0 0 0 255)) in
  object
    method texture = r
  end

class health () =
  let r = Component.init 0 in
  object
    method health  = r
  end

class removable () =
  let r = Component.init (fun ()->()) in
  object 
    method unregister = r
end


type tag = No_tag | Player | Bullet | Enemy1 | Enemy2

let tag_tostring t =
  match t with
  | No_tag -> "No_tag"
  | Player -> "Player"
  | Bullet -> "Bullet"
  | _ -> "None"


class tagged ()  =
  let r = Component.init No_tag in
  object
    method tag = r
  end
(*
class resolver  =
  let r = Component.init (fun (_ : Vector.t) (_ : tagged) -> ) in
  object
    method resolve = r
  end
*)
  (*velocity*)
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




type state = Standing | Crouching | OnAir | OnGround

class playerstate =
let r = Component.init Standing in
object
  method playerstate = r 
end
(** Interfaces : ici on liste simplement les types des classes dont on hérite
    si deux classes définissent les mêmes méthodes, celles de la classe écrite
    après sont utilisées (héritage multiple).
*)


class  collidable () =
  object
    inherit Entity.t () 
    inherit tagged()
    inherit removable()
    inherit position ()
    inherit velocity () 
    inherit box ()
    inherit mass ()
    inherit health ()
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

class  movable () =
  object
  inherit Entity.t ()
  inherit position ()
  inherit velocity ()
  end

(** Entités :
    Ici, dans inherit, on appelle les constructeurs pour qu'ils initialisent
    leur partie de l'objet, d'où la présence de l'argument 
*)
class player name =
  object
    inherit Entity.t ~name ()
    inherit playerstate

    inherit drawable ()
    inherit physics () 
    inherit collidable ()
    inherit movable ()
  end

class enemy name =
  object
    inherit Entity.t ~name()
    inherit drawable()
    inherit physics()
    inherit collidable()
    inherit movable()
  end

class enemy2 name =
  object
    inherit Entity.t ~name()
    inherit drawable()
    inherit physics()
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

    inherit drawable () 
    inherit collidable ()
    inherit physics ()
end
