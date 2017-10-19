struct Entity{S,D,I} # state, definition, identification
    state::S
    def::D
    id::I
end
Entity{S,D,I}(entity::Entity{S,D,I}, s::S) = Entity(s, entity.def, entity.id)

Base.:(==){S,D,I}(a::Entity{S,D,I}, b::Entity{S,D,I}) = a.state == b.state && a.def == b.def && a.id == b.id