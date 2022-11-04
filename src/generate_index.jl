
function _generate_index_type_methods(T::Symbol, itype::Symbol)
    @eval begin
        Base.eltype(@nospecialize x::Union{Type{<:$(itype){$(T)}},$(itype){$(T)}}) = $(T)
        @assume_effects :consistent :nothrow function _get(x::$(itype){$(T)}, i::Int)
            @nospecialize x
            getfield(_tuple(x), i, false)
        end
        function Base.getindex(x::$(itype){$(T)}, i::Int)
            @nospecialize x
            @boundscheck (1 > i || i > _length(x)) && throw(BoundsError(x, i))
            _get(x, i)
        end

        function Base.reverse(x::$(itype){$(T)})
            @nospecialize x
            $(itype){$(T)}(x, reverse(_tuple(x)))
        end
        @inline function Base.vcat(x::$(itype){$(T)}, y::$(itype){$(T)})
            @nospecialize x y
            $(itype){$(T)}((tuple(x)..., _tuple(y)...))
        end
        function Base.empty(x::$(itype){$(T)})
            @nospecialize x
            $(itype){$(T)}(())
        end
    end

    # for al types but `Bool` theses methods are the same but we need to specialize on the
    # eltype for inference
    if T !== :Bool
        @eval begin
            function Base.findfirst(f::Eq{$(T)}, x::$(itype){$(T)})
                @nospecialize x
                findfirst(f.x, x)
            end
            function Base.findfirst(v::$(T), x::$(itype){$(T)})
                @nospecialize x
                i = _findfirst(v, _tuple(x))
                i === ERROR_INDEX ? nothing : i
            end
            @inline function Base.findlast(f::Eq{$(T)}, x::$(itype){$(T)})
                @nospecialize x
                findlast(f.x, x)
            end
            @inline function Base.findlast(v::$(T), x::$(itype){$(T)})
                @nospecialize x
                i = _findlast(v, _tuple(x))
                i === ERROR_INDEX ? nothing : i
            end
            @inline function Base.findnext(v::$(T), x::$(itype){$(T)}, start::Int)
                @nospecialize x
                i = _findnext(v, _tuple(x), start < 1 ? 1 : start)
                i === ERROR_INDEX ? nothing : i
            end
            function Base.findprev(f::Eq{$(T)}, x::$(itype){$(T)}, start::Int)
                @nospecialize x
                findprev(f.x, x, start)
            end
            @inline function Base.findprev(v::$(T), x::$(itype){$(T)}, start::Int)
                @nospecialize x
                n = _length(x)
                i = _findprev(v, _tuple(x), start > n ? n : start)
                i === ERROR_INDEX ? nothing : i
            end
            function Base.in(v::$(T), x::$(itype){$(T)})
                @nospecialize x
                _in(v, _tuple(x))
            end
            function Base.count(f::Eq, x::$(itype){$(T)})
                @nospecialize x
                Base.count(f.x, x)
            end
            function Base.count(v::$(T), x::$(itype){$(T)})
                @nospecialize x
                _count(v, _tuple(x))
            end

            function Base.allunique(x::$(itype){$(T)})
                @nospecialize x
                _allunique(_tuple(x))
            end
            function Base.unique(x::$(itype){$(T)})
                @nospecialize x
                $(itype){$(T)}(_unique(_tuple(x)))
            end
            function Base.union(x::$(itype){$(T)}, y::$(itype){$(T)})
                @nospecialize x y
                $(itype){$(T)}(_union(_unique(_tuple(x)), _unique(_tuple(y))))
            end
            @inline function Base.setdiff(x::$(itype){$(T)}, y::$(itype){$(T)})
                @nospecialize x y
                $(itype){$(T)}(_setdiff(_unique(_tuple(x)), _unique(_tuple(y))))
            end
            @inline function Base.intersect(x::$(itype){$(T)}, y::$(itype){$(T)})
                @nospecialize x y
                $(itype){$(T)}(_intersect(_tuple(x), _tuple(y)))
            end
        end
    else
        @eval begin
            @inline function Base.count(::typeof(!), x::$(itype){Bool})
                @nospecialize x
                _count_false(_tuple(x))
            end
            @inline function Base.count(x::$(itype){Bool})
                @nospecialize x
                _count_true(_tuple(x))
            end
            @inline function Base.findprev(x::$(itype){Bool}, start::Int)
                @nospecialize x
                i = _find_prev_true(_tuple(x), start > n ? n : start)
                i === ERROR_INDEX ? nothing : i
            end
            @inline function Base.findprev(::typeof(!), x::$(itype){Bool}, start::Int)
                @nospecialize x
                i = _find_prev_false(_tuple(x), start > n ? n : start)
                i === ERROR_INDEX ? nothing : i
            end
            @inline function Base.findnext(x::$(itype){Bool}, start::Int)
                @nospecialize x
                i = _find_next_true(_tuple(x), start < 1 ? 1 : start)
                i === ERROR_INDEX ? nothing : i
            end
            @inline function Base.findnext(::typeof(!), x::$(itype){Bool}, start::Int)
                @nospecialize x
                i = _find_next_false(_tuple(x), start < 1 ? 1 : start)
                i === ERROR_INDEX ? nothing : i
            end
            @inline function Base.findfirst(x::$(itype){Bool})
                @nospecialize x
                _find_first_true(_tuple(x))
            end
            @inline function Base.findfirst(::typeof(!), x::$(itype){Bool})
                @nospecialize x
                _find_first_false(_tuple(x))
            end
            @inline function Base.findlast(x::$(itype){Bool})
                @nospecialize x
                _find_last_true(_tuple(x))
            end
            @inline function Base.findlast(::typeof(!), x::$(itype){Bool})
                @nospecialize x
                _find_last_false(_tuple(x))
            end
        end
    end
end

# methods that are specific to the index wrapper but not eltype
function _generate_index_methods(itype::Symbol)
    @eval begin
        @assume_effects :nothrow :consistent function _tuple(x::$(itype))
            @nospecialize
            getfield(x, :data)
        end
        function Base.Tuple(x::$(itype))
            @nospecialize x
            _tuple(x)
        end
        @assume_effects :total function _length(x::$(itype))
            @nospecialize x
            nfields(_tuple(x))
        end
        function Base.length(x::$(itype))
            @nospecialize x
            _length(x)
        end
        function Base.lastindex(x::$(itype))
            @nospecialize x
            _length(x)
        end
        function Base.size(x::$(itype))
            @nospecialize x
            (_length(x),)
        end
        function Base.axes(x::$(itype))
            @nospecialize x
            (Base.OneTo(_length(x)),)
        end
    end
end

#=
struct SubIndex{T,P,I} <: AbstractVector{T}
    parent::P
    indices::I

    global function _SubNames(@nospecialize(p), @nospecialize(i))
        new{eltype(p),typeof(p),typeof(i)}(p, i)
    end
end

_parent(@nospecialize x::SubIndex) = getfield(x, :parent)
_indices(@nospecialize x::SubIndex) = getfield(x, :indices)
=#


