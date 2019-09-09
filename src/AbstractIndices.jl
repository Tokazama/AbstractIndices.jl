module AbstractIndices

using Dates

import Base: length, axes, getindex, checkindex
import Base: to_index, OneTo, tail

export AbstractIndex,
       AxisIndex,
       OneToIndex,
       LabelIndex,
       # methods
       axistype,
       indextype,
       axiseltype,
       indexeltype,
       to_axis,
       to_index,
       asindex

include("utils.jl")
include("abstractindex.jl")
include("abstractindicesarray.jl")
include("axisindex.jl")
include("labelindex.jl")
include("onetoindex.jl")
include("asindex.jl")
include("checkbounds.jl")
include("indexing.jl")
#include("show.jl")


end
