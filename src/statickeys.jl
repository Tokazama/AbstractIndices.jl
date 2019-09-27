"""
    StaticKeys

A set of unique keys that are known at compile time for indexing. A
`StaticKeys` index always refers back to a one based indexing system.
"""
struct StaticKeys{Keys,N,K} <: AbstractIndex{K,Int,NTuple{N,K},OneTo{Int}}

    function StaticKeys{Keys,N,K}(::CheckedUnique{false}) where {Keys,N,K}
        allunique(Keys) || error("Not all elements in keys were unique.")
        eltype(Keys) <: K || error("eltype of $(Keys) does not match provided keytype $(K)")
        new{Keys,N,K}()
    end

    function StaticKeys{Keys,N,K}(::CheckedUnique{true}) where {Keys,N,K}
        eltype(Keys) <: K || error("eltype of $(Keys) does not match provided keytype $(K)")
        new{Keys,N,K}()
    end
end

StaticKeys(Keys::NTuple{N,K}) where {N,K} = StaticKeys{Keys,N,K}(CheckedUniqueFalse)

IndexingStyle(::Type{<:StaticKeys}) = IndexBaseOne

values(sk::StaticKeys) = OneTo(length(sk))
keys(sk::StaticKeys{Keys}) where {Keys} = Keys
length(sk::StaticKeys{Keys,N,K}) where {Keys,N,K} = N

Base.allunique(::StaticKeys) = true  # determined at time of construction

# TODO This always needs to be Int. Should there be a warning if anything else is called
Base.similar(sk::StaticKeys{Keys,N,K}, vs::Type=Int) where {Keys,N,K} = copy(sk)

asindex(ks::NTuple{N,Symbol}, ::IndexBaseOne) where {N} = StaticKeys(Tuple(ks))
