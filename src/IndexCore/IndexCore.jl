module IndexCore

using StaticRanges

using Base: OneTo,
            to_index,
            tail,
            axes,
            broadcasted,
            AbstractCartesianIndex,
            @propagate_inbounds,
            @_propagate_inbounds_meta

using StaticRanges:
    can_set_length,
    can_set_first,
    can_set_last,
    ForwardOrdering,
    ReverseOrdering,
    ContinuousTrait,
    Continuous,
    DiscreteTrait,
    Discrete,
    similar_type,
    OneToRange,
    AbstractStepRange,
    AbstractStepRangeLen,
    AbstractLinRange,
    StaticUnitRange,
    Length,
    Size

export
    # Types
    AbstractIndex,
    AbstractLengthCheck,
    AllUniqueTrait,
    AllUnique,
    Index,
    LengthCheckedTrait,
    LengthChecked,
    LengthNotCheckedTrait,
    LengthNotChecked,
    NotUniqueTrait,
    SimpleIndex,
    Uniqueness,
    UnkownUnique,
    UnkownUniqueTrait,
    # methods
    append_axes,
    append_axes!,
    append_axis,
    append_axis!,
    append_keys,
    append_values,
    axes2length,
    axes2size,
    cat_axes,
    cat_axis,
    cat_names,
    cat_keys,
    cat_values,
    check_dimensions,
    check_index_length,
    check_index_uniqueness,
    check_index_params,
    combine_index,
    combine_indices,
    combine_keys,
    combine_names,
    combine_values,
    covcor_axes,
    dimnames,
    drop_axes,
    filter_axes,
    hcat_axes,
    index_by,
    indices,
    inverse_axes,
    keys_type,
    matmul_axes,
    permute_axes,
    pop_index,
    pop_index!,
    popfirst_index,
    popfirst_index!,
    push_index!,
    pushfirst_index!,
    reduce_axes,
    reduce_axis,
    reindex,
    reshape_axes,
    reshape_axes!,
    resize_axis!,
    to_dims,
    unsafe_reindex,
    values_type,
    vcat_axes,
    dimn

include("abstractindex.jl")
include("param_checks.jl")
include("index.jl")
#include("subindex.jl")    # rewrite, doc, ex, tests
include("simpleindex.jl")
include("iterate.jl")      # tests
include("names.jl")
include("size.jl")         # doc, ex, tests
include("reindex.jl")
include("to_index.jl")
include("to_indices.jl")
#include("to_linear.jl")   # rewrite, doc, ex, tests
include("checkindex.jl")   # tests
include("getindex.jl")     # tests
include("combine.jl")      # ex
include("drop_axes.jl")    # tests
include("reduce_axes.jl")  # tests
include("reshape_axes.jl") # ex, tests
include("inverse_axes.jl")
include("covcor_axes.jl")
include("permute_axes.jl") # tests
include("matmul_axes.jl")  # tests
include("filter_axes.jl")  # tests
include("cat_axes.jl")     # tests
include("append_axes.jl")  # tests
include("make_unique.jl")  # doc, ex, tests, TODOs
include("promotion.jl")
include("push_pop.jl")     # tests
#include("prmote_shape.jl")

end
