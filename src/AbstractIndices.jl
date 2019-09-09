module AbstractIndices

using Dates

import Base: length, axes, getindex, checkindex, checkbounds
import Base: to_index, OneTo, tail, show

export AbstractIndex,
       AxisIndex,
       OneToIndex,
       LabelIndex,
       IndicesArray,
       # methods
       axistype,
       indextype,
       axiseltype,
       indexeltype,
       to_axis,
       to_index,
       stepindex,
       asindex

include("utils.jl")
include("abstractindex.jl")
include("abstractindicesarray.jl")
include("axisindex.jl")
include("labelindex.jl")
include("onetoindex.jl")
include("indicesarray.jl")
include("asindex.jl")
include("checkbounds.jl")
include("indexing.jl")
include("show.jl")


end
