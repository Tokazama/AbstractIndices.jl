

"""
    StaticKeys

"""
struct StaticKeys{Keys,K} <: AbstractIndex{K,Int}

    function StaticKeys{Keys,K}() where {Keys,K}
        eltype(Keys) <: K || error("eltype of $(Keys) is not match provided keytype $(K)")
        new{Keys,K}()
    end
end

StaticKeys(Keys::NTuple{N,K}) where {N,K} = StaticKeys{Keys,K}()


values(sk::StaticKeys) = OneTo(length(sk))
keys(sk::StaticKeys{Keys}) where {Keys} = Keys
length(sk::StaticKeys) = length(keys(sk))
