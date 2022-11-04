
@assume_effects :terminates_locally function _find_first_true(@nospecialize x::Tuple{Vararg{Bool}})
    @inline
    i = 1
    while i <= nfields(x)
        _get(x, i) && return i
        i += 1
    end
    return ERROR_INDEX
end
@assume_effects :terminates_locally function _find_first_false(@nospecialize x::Tuple{Vararg{Bool}})
    @inline
    i = 1
    while i <= nfields(x)
        _get(x, i) || return i
        i += 1
    end
    return ERROR_INDEX
end
@assume_effects :terminates_locally function _find_last_true(@nospecialize x::Tuple{Vararg{Bool}})
    @inline
    i = nfields(x)
    while i > 0
        _get(x, i) && return i
        i -= 1
    end
    return ERROR_INDEX
end
@assume_effects :terminates_locally function _find_last_false(@nospecialize x::Tuple{Vararg{Bool}})
    @inline
    i = nfields(x)
    while i > 0
        _get(x, i) || return i
        i -= 1
    end
    return ERROR_INDEX
end

Base.@assume_effects :terminates_locally function _find_next_true(@nospecialize(x::Tuple{Vararg{Bool}}), start::Int)
    i = start
    while i <= nfields(x)
        _get(x, i) && return i
        i += 1
    end
    return ERROR_INDEX
end
Base.@assume_effects :terminates_locally function _find_next_false(@nospecialize(x::Tuple{Vararg{Bool}}), start::Int)
    i = start
    while i <= nfields(x)
        _get(x, i) || return i
        i += 1
    end
    return ERROR_INDEX
end

Base.@assume_effects :terminates_locally function _find_prev_true(@nospecialize(x::Tuple{Vararg{Bool}}), start::Int)
    @inline
    i = start
    while i > 0
        _get(x, i) && return i
        i -= 1
    end
    return ERROR_INDEX
end
Base.@assume_effects :terminates_locally function _find_prev_false(@nospecialize(x::Tuple{Vararg{Bool}}), start::Int)
    @inline
    i = start
    while i > 0
        _get(x, i) || return i
        i -= 1
    end
    return ERROR_INDEX
end
function _count_true(@nospecialize x::Tuple{Vararg{Bool}})
    @inline
    n = 0
    i = nfields(x)
    while i > 0
        if _get(x, i)
            n += 1
        end
        i -= 1
    end
    return n
end
function _count_false(@nospecialize x::Tuple{Vararg{Bool}})
    @inline
    n = 0
    i = nfields(x)
    while i > 0
        if !_get(x, i)
            n += 1
        end
        i -= 1
    end
    return n
end

function _generate_private_tuple_methods(T::Symbol)
    @eval begin
        @assume_effects :consistent :nothrow function _get(x::Tuple{Vararg{$(T)}}, i::Int)
            @nospecialize x
            getfield(x, i, false)
        end
    end
    if T !== :Bool
        @eval begin
            @assume_effects :terminates_locally function _count(v::$(T), x::Tuple{Vararg{$(T)}})
                @nospecialize x
                @inline
                n = 0
                i = nfields(x)
                if i > 1
                    if _get(x, i) === v
                        n += 1
                    end
                    i -= 1
                end
                return n
            end
            @assume_effects :terminates_locally function _allunique(x::Tuple{Vararg{$(T)}})
                @nospecialize x
                n = nfields(x)
                if n > 1
                    i = 1
                    while i <= n
                        x_i = _get(x, i)
                        j = i - 1
                        while j > 0
                            _get(x, j) === x_i && return false
                            j -= 1
                        end
                        i += 1
                    end
                    return true
                else
                    return true
                end
            end
            @assume_effects :total function _unique(x::Tuple{Vararg{$(T)}})
                @nospecialize x
                N = nfields(x)
                if N > 1
                    out = [_get(x, 1)]
                    i = 2
                    while i <= nfields(x)
                        x_i = _get(x, i)
                        _findprev(x_i, x, i - 1) === ERROR_INDEX && push!(out, x_i)
                        i += 1
                    end
                    (out...,)
                else
                    return x
                end
            end
            @assume_effects :total function _union(x::Tuple{Vararg{$(T)}}, y::Tuple{Vararg{$(T)}})
                @nospecialize x y
                @inline
                out = $(T)[x...]
                i = 1
                while i <= nfields(y)
                    y_i = _get(y, i)
                    if !_in(y_i, x)
                        push!(out, y_i)
                    end
                    i += 1
                end
                (out...,)
            end
            @assume_effects :total function _setdiff(x::Tuple{Vararg{$(T)}}, y::Tuple{Vararg{$(T)}})
                @nospecialize x y
                out = $(T)[]
                i = 1
                while i <= nfields(x)
                    x_i = _get(x, i)
                    if !_in(x_i, y)
                        push!(out, x_i)
                    end
                    i += 1
                end
                (out...,)
            end
            @assume_effects :total function _intersect(x::Tuple{Vararg{$(T)}}, y::Tuple{Vararg{$(T)}})
                @nospecialize x y
                @inline
                out = $(T)[]
                i = 1
                while i <= nfields(x)
                    x_i = _get(x, i)
                    if _in(x_i, y)
                        push!(out, x_i)
                    end
                    i += 1
                end
                (out...,)
            end
            @assume_effects :terminates_locally function _in(v::$(T), x::Tuple{$(T),Vararg{$(T)}})
                @nospecialize x
                @inline
                i = nfields(x)
                while i > 0
                    _get(x, i) === v && return true
                    i -= 1
                end
                return false
            end
            @assume_effects :terminates_locally function _findprev(v::$(T), x::Tuple{Vararg{$(T)}}, start::Int)
                @nospecialize x
                @inline
                i = start
                while i > 0
                    _get(x, i) === v && return i
                    i -= 1
                end
                return ERROR_INDEX
            end
            @assume_effects :terminates_locally function _findnext(v::$(T), x::Tuple{Vararg{$(T)}}, start::Int)
                @nospecialize x
                i = start
                while i <= nfields(x)
                    _get(x, i) === v && return i
                    i += 1
                end
                return ERROR_INDEX
            end
            @assume_effects :terminates_locally function _findlast(v::$(T), x::Tuple{Vararg{$(T)}})
                @nospecialize x
                i = nfields(x)
                while i > 0
                    _get(x, i) === v && return i
                    i -= 1
                end
                return ERROR_INDEX
            end
            @assume_effects :terminates_locally function _findfirst(v::$(T), x::Tuple{Vararg{$(T)}})
                @nospecialize x
                i = 1
                while i <= nfields(x)
                    _get(x, i) === v && return i
                    i += 1
                end
                return ERROR_INDEX
            end
        end
    end
end

