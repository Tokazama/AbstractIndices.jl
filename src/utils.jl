# TODO write out errors
function index_checks(axis, index)
    length(axis) == length(index) || error("axis and index lengths don't match, length(axis) = $(length(axis)) and length(index) = $(length(index))")
    allunique(axis) || error("Not all elements in axis were unique.")
    allunique(index) || error("Not all elements in index were unique.")
end

maybetail(::Tuple{}) = ()
maybetail(t::Tuple) = tail(t)
