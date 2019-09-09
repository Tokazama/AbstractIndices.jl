"""
    SemanticDimension
"""
struct SemanticDimension{D} end

const Sagittal = SemanticDimension{:sagittal}()

const Axial = SemanticDimension{:axial}()

const Coronal = SemanticDimension{:coronal}()

const Time = SemanticDimension{:time}()

"""
    SemanticPosition
"""
struct SemanticPosition{P,D} end

dimension(::S) where {S<:SemanticPosition} = dimension(S)
dimension(::Type{SemanticPosition{S,D}}) where {S,D} = D

const Left = SemanticPosition{:left,Sagittal}()
const Right = SemanticPosition{:right,Sagittal}()

const Superior = SemanticPosition{:superior,Axial}()
const Inferior = SemanticPosition{:inferior,Axial}()

const Anterior = SemanticPosition{:anterior,Coronal}()
const Posterior = SemanticPosition{:posterior,Coronal}()

"""
    SemanticOrder
"""
struct Semanticorder{F,D}

    function Semanticorder{F,L}() where {F,L}
        dimension(F) === dimension(L) || error("first and last semantic positions must come from same dimension.")
        new{F,L}()
    end
end

