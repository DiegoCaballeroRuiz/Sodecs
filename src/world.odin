package sodecs

import "core:container/queue"

World :: struct {
	// Entities
	next_entity_id:          Entity,
	available_entity_spaces: queue.Queue(Entity),

	// Systems
	logic_systems:           [dynamic]proc(world: ^World, dt: f32),
	render_systems:          [dynamic]proc(world: ^World),

	// Components
	components:              map[typeid]CompList,
}


create_world :: proc() -> World {
	world := World{}
	queue.init(&world.available_entity_spaces)

	return world
}

update_world :: proc(world: ^World, dt: f32) {
	for system in world.logic_systems do system(world, dt)
}

render_world :: proc(world: ^World) {
	for system in world.render_systems do system(world)
}

register_logic_system :: proc(world: ^World, system: proc(_: ^World, _: f32)) {
	append(&world.logic_systems, system)
}

register_render_system :: proc(world: ^World, system: proc(_: ^World)) {
	append(&world.render_systems, system)
}

register_system :: proc {
	register_logic_system,
	register_render_system,
}

create_entity :: proc(world: ^World) -> Entity {
	new_entity: Entity

	if queue.len(world.available_entity_spaces) != 0 {
		new_entity = queue.pop_front(&world.available_entity_spaces)
	} else {
		new_entity = world.next_entity_id
		world.next_entity_id += 1
	}

	return new_entity
}

kill_entity :: proc(world: ^World, entity: Entity) {
	// Enqueue free entity
	queue.push_back(&world.available_entity_spaces, entity)

	// Delete all of the entity's components
    for _, complist in world.components {
        complist.remove_key(complist.data, entity)
    }
}

delete_world :: proc(world: ^World) {
	// Free entity data
	queue.destroy(&world.available_entity_spaces)

	// Free system data
	delete(world.logic_systems)
	delete(world.render_systems)

	// Free component data
    for _, complist in world.components {
        complist.destroy(complist.data)
    }
    delete(world.components)
}

component_list :: proc($T: typeid, world: ^World) -> ^map[Entity]T {
    // If the map is initialized, return it
	if complist, ok := world.components[T]; ok {
		return cast(^map[Entity]T)complist.data
	}

    // Initialize the map
	complist := new(map[Entity]T)
	complist^ = make(map[Entity]T)

    // Create the remove and destroy functions
	world.components[T] = CompList {
		data = complist,
		remove_key = proc(p: rawptr, e: Entity) {
			m := cast(^map[Entity]T)p
			delete_key(m, e)
		},
		destroy = proc(p: rawptr) {
			m := cast(^map[Entity]T)p
			delete(m^)
			free(m)
		},
	}

	return complist
}

get_component :: proc($T: typeid, world: ^World, entity: Entity) -> (T, bool) {
	complist := component_list(T, world)
	return complist[entity]
}


add_component :: proc(world: ^World, entity: Entity, component: $T) {
	comp_list := component_list(T, world)
	comp_list[entity] = component
}
