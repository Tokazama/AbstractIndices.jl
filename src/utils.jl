# TODO write out errors
function index_checks(axis::AbstractVector, index::AbstractVector)
    length(axis) == length(index) || error("axis and index lengths don't match, length(axis) = $(length(axis)) and length(index) = $(length(index))")
    allunique(axis) || error("Not all elements in axis were unique.")
    allunique(index) || error("Not all elements in index were unique.")
end

function index_checks(axis::NTuple{N}, index::AbstractVector) where N
    N == length(index) || error("axis and index lengths don't match, length(axis) = $(length(axis)) and length(index) = $(length(index))")
    allunique(axis) || error("Not all elements in axis were unique.")
    allunique(index) || error("Not all elements in index were unique.")
end
