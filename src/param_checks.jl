# uniqueness checks
abstract type Uniqueness end

struct AllUniqueTrait <: Uniqueness end
const AllUnique = AllUniqueTrait()

struct NotUniqueTrait <: Uniqueness end
const NotUnique = NotUniqueTrait()

struct UnkownUniqueTrait <: Uniqueness end
const UnkownUnique = UnkownUniqueTrait()

Uniqueness(::T) where {T} = Uniqueness(T)
Uniqueness(::Type{T}) where {T} = UnkownUnique
Uniqueness(::Type{T}) where {T<:AbstractRange} = AllUnique

function check_index_uniqueness(idx::AbstractIndex, u::Uniqueness=NotUnique)
    return _check_index_uniqueness(keys(idx), u)
end
function check_index_uniqueness(idx, u::Uniqueness=NotUnique)
    return _check_index_uniqueness(idx, u)
end

_check_index_uniqueness(idx, ::AllUniqueTrait) = nothing
function _check_index_uniqueness(idx, ::UnkownUniqueTrait)
    return allunique(idx) ? nothing : _check_index_uniqueness(idx, NotUnique)
end
function _check_index_uniqueness(idx, ::NotUniqueTrait)
    error("all keys of each index must be unique.")
end

# length checks
abstract type AbstractLengthCheck end

struct LengthCheckedTrait <: AbstractLengthCheck end
const LengthChecked = LengthCheckedTrait()

struct LengthNotCheckedTrait <: AbstractLengthCheck end
const LengthNotChecked = LengthNotCheckedTrait()

function check_index_length(axs, idx, lc::AbstractLengthCheck=LengthNotChecked)
    return _check_length(axs, idx, lc)
end

_check_length(axs, idx, ::LengthCheckedTrait) = nothing

function _check_length(axs, idx, ::LengthNotCheckedTrait)
    if length(axs) == length(idx)
        return nothing
    else
        error("Length of parent axes and index must be of equal length, got an
               axis of length $(length(axs)) and index of length $(length(idx)).")
    end
end

# dimensions check
function check_dimensions(parent::AbstractArray{T,N1}, indices::Tuple{Vararg{Any,N2}}) where {T,N1,N2}
    N1 === N2 || error("Parent array has $N1 dimensions but there are $N2 indices.")
    return nothing
end


# all checks
function check_index_params(parent, indices, uc::Uniqueness, lc::AbstractLengthCheck)
    check_dimensions(parent, indices)        # ensure dimensions correspond to indices
    for (axs,idx) in zip(axes(parent),indices)
        check_index_length(axs, idx, lc)     # ensure length of index match axes
        check_index_uniqueness(idx, uc)      # ensure all keys are unique
    end
    return nothing
end
