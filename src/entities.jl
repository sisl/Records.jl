immutable Entity{S,D,I} # state, definition, identification
    state::S
    def::D
    id::I
end
Entity{S,D,I}(entity::Entity{S,D,I}, s::S) = Entity(s, entity.def, entity.id)