inv_indices(a) = (axes(a, 2), axes(a, 1))

Base.inv(a::IndicesMatrix) = IndicesArray(inv(parent(a)), inv_indices(a))
