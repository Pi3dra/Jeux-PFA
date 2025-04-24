
open Ecs

module Collision_system = System.Make(Collision)

module Draw_system = System.Make(Draw)

module Move_system = System.Make(Move)

module Forces_system = System.Make(Forces)

module Animation_system = System.Make(Animation)

module On_screen_system = System.Make(On_screen)

module Trigger_system = System.Make(Trigger)
