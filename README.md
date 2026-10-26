# Sodecs
Sodecs (simple odin ecs) is a simple ecs architecture for games written in odin

>[!Warning] Disclaimer
> sodecs is meant to be **simple, not fast**, if you are looking for an eficient 
> architecture to build your higly performant game on top of, use something else 
> entirely

# Using it in your projects
Grab the `src/` folder and put it in your proyect. Import the sodecs module and you are good to go!

The following is an example of how to write a simple ecs program using sodecs:
```odin
package main

import "sodecs"

main :: proc() {
    world := sodecs.create_world()
    defer sodecs.delete_world(&world)

    entity := sodecs.create_entity(&world)
    sodecs.add_component(&world, entity, cast(Name)"Arthur Dent")
    sodecs.register_system(&world, display_names)

    for true {
        sodecs.update_world(&world, 0)
    }
}

Name :: distinct string

display_names :: proc(world: ^sodecs.World, _: f32) {
    for ent,name in sodecs.component_list(Name, world) {
        fmt.printfln("The entity with id %d is named %s", ent, name)
    }
}
```

>[!Note] Further usage instructions 
> Deeper usage instructions coming soon, also I will add some examples to `examples/`
