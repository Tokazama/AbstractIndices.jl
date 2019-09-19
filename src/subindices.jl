# TODO SubArray
const SubIndicesArray{T,N,A,D,I,L} = SubArray{T,N,<:AbstractIndicesArray{T,N,A,D},I,L}

const SubIndicesMatrix{T,A,D<:AbstractMatrix{T},I,L} = SubIndicesArray{T,2,A,D,I,L}
