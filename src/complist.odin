package sodecs

CompList :: struct {
	data:       rawptr,                            // Is actually a map[Entity]T
	remove_key: proc(ptr: rawptr, entity: Entity), // remove an entity from keys
	destroy:    proc(ptr: rawptr),                 // Delete the type erased map
}
