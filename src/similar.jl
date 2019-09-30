#=
similar_type(::SA) where {SA<:StaticArray} = similar_type(SA,eltype(SA))
similar_type(::Type{SA}) where {SA<:StaticArray} = similar_type(SA,eltype(SA))

similar_type(::SA,::Type{T}) where {SA<:StaticArray,T} = similar_type(SA,T,Size(SA))
similar_type(::Type{SA},::Type{T}) where {SA<:StaticArray,T} = similar_type(SA,T,Size(SA))

similar_type(::A,s::Size{S}) where {A<:AbstractArray,S} = similar_type(A,eltype(A),s)
similar_type(::Type{A},s::Size{S}) where {A<:AbstractArray,S} = similar_type(A,eltype(A),s)

similar_type(::A,::Type{T},s::Size{S}) where {A<:AbstractArray,T,S} = similar_type(A,T,s)

# We should be able to deal with SOneTo axes
similar_type(s::SOneTo) = similar_type(typeof(s))
similar_type(::Type{SOneTo{n}}) where {n} = similar_type(SOneTo{n}, Int, Size(n))

similar_type(::A, shape::Tuple{SOneTo, Vararg{SOneTo}}) where {A<:AbstractArray} = similar_type(A, eltype(A), shape)
similar_type(::Type{A}, shape::Tuple{SOneTo, Vararg{SOneTo}}) where {A<:AbstractArray} = similar_type(A, eltype(A), shape)

similar_type(::A,::Type{T}, shape::Tuple{SOneTo, Vararg{SOneTo}}) where {A<:AbstractArray,T} = similar_type(A, T, Size(last.(shape)))
similar_type(::Type{A},::Type{T}, shape::Tuple{SOneTo, Vararg{SOneTo}}) where {A<:AbstractArray,T} = similar_type(A, T, Size(last.(shape)))

similar_type(::Type{A},::Type{T},s::Size{S}) where {A<:AbstractArray,T,S} = default_similar_type(T,s,length_val(s))
similar_type(::Type{
default_similar_type(::Type{T}, s::Size{S}, ::Type{Val{D}}) where {T,S,D} = SArray{Tuple{S...},T,D,prod(s)}

similar_type(::Type{SA},::Type{T},s::Size{S}) where {SA<:Union{MVector,MMatrix,MArray},T,S} = mutable_similar_type(T,s,length_val(s))

mutable_similar_type(::Type{T}, s::Size{S}, ::Type{Val{D}}) where {T,S,D} = MArray{Tuple{S...},T,D,prod(s)}
=#
function Base.similar(
    a::IndicesArray{T,N,A,D,F},
    eltype::Type=T,
    new_axes::Tuple{Vararg{Union{<:AbstractIndex,AbstractPosition}}}=axes(a)
   ) where {T,N,A,D,F}

    return IndicesArray(similar(parent(a), eltype, length.(new_axes)), new_axes)
end

function similar_type(::A, new_axes::Type=axestype(A), new_parent::Type=parenttype(A)) where {A<:IndicesArray}
    IndicesArray{eltype(new_parent),ndims(new_parent),new_axes,new_parent}
end

#function Base.similar(A::AbstractArray, ::Type{T}, inds::Tuple{AbstractIndex,Vararg{AbstractIndex}}) where T
#    B = similar(A, T, map(length, inds))
#    IndicesArray(B, map(asindex, axes(B), inds))
#end

#function Base.similar(::Type{Array{T,N}}, ::Type{T}, inds::Tuple{AbstractIndex,Vararg{AbstractIndex}}) where {T,N}
#    B = similar(A, T, map(length, inds))
#    IndicesArray(B, map(asindex, axes(B), inds))
#end

function Base.similar(::Type{T}, dims::DimOrIndex...) where {T<:AbstractArray}
    similar(T, dims)
end

function Base.similar(
    ::Type{T},
    shape::Tuple{<:DimOrIndex,Vararg{<:DimOrIndex}}
   ) where {T<:AbstractArray}
    IndicesArray(similar(T, length.(shape)), shape)
end


# FIXME: this is an unexported function from base
#Base.to_shape(r::AbstractUnitRange) = r
#=
TODO: this is the original function from base. It would be nice to emulate it
      in some that is performant and doesn't restrict to only Arrays

function Base.similar(
    ::Type{T},
    shape::Tuple{Union{Integer, OneTo}, Vararg{Union{Integer, OneTo}}}
   ) where {T<:AbstractArray}
    similar(T, to_shape(shape))
end

similar(::Base.Broadcast.Broadcasted{Base.Broadcast.DefaultArrayStyle{1},
                                     Tuple{Tuple{NamedIndex{:a,Int64,Int64,OneTo{Int64},OneTo{Int64},OneToIndex{Int64,Int64,OneTo{Int64}}}}},typeof(+),Tuple{IndicesArray{Float64,1,Tuple{NamedIndex{:a,Int64,Int64,OneTo{Int64},OneTo{Int64},OneToIndex{Int64,Int64,OneTo{Int64}}}},Array{Float64,1},false},IndicesArray{Float64,1,Tuple{NamedIndex{:a,Int64,Int64,OneTo{Int64},OneTo{Int64},OneToIndex{Int64,Int64,OneTo{Int64}}}},Array{Float64,1},false}}}, ::Type{Float64}) at ./broadcast.jl:196

similar(::Type{Array{Float64,N} where N},
        ::Tuple{Tuple{NamedIndex{:a,Int64,Int64,OneTo{Int64},OneTo{Int64},
                                 OneToIndex{Int64,Int64,OneTo{Int64}}}}})

Base.Broadcast.Broadcasted{Base.Broadcast.DefaultArrayStyle{2},
                           Nothing,
                           typeof(+),
                           Tuple{IndicesArray{Float64,2,
                                              Tuple{NamedIndex{:x,Int64,Int64,OneTo{Int64},OneTo{Int64},
                                                               OneToIndex{Int64,Int64,OneTo{Int64}}},
                                                    NamedIndex{:_,Int64,Int64,OneTo{Int64},OneTo{Int64},
                                                               OneToIndex{Int64,Int64,OneTo{Int64}}}},
                                              Array{Float64,2},false},
                                 IndicesArray{Float64,2,
                                              Tuple{NamedIndex{:_,Int64,Int64,OneTo{Int64},OneTo{Int64},
                                                               OneToIndex{Int64,Int64,OneTo{Int64}}},
                                                    NamedIndex{:y,Int64,Int64,OneTo{Int64},OneTo{Int64},
                                                               OneToIndex{Int64,Int64,OneTo{Int64}}}},
                                              Array{Float64,2},false}}}) at ./broadcast.jl:798

=#
