# TODO write out errors
function index_checks(axis::AbstractVector, index::AbstractVector)
    length(axis) == length(index) || error("lengths don't match")
    allunique(axis) || error()
    allunique(index) || error()
end
