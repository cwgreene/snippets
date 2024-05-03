import numpy
#import numba

#@numba.njit
def gaussian_eliminate(A, b):
    A = numpy.append(A, b, axis=1)
    num_vars = A.shape[1] - 1 # ignore affixed column
    if num_vars > A.shape[0]:
        return A 
    for i in range(num_vars-1):
        print(i)
        # find leading entry
        non_zeros = numpy.nonzero(A[:,i])[0]
        if len(non_zeros) < 1:
            continue
        # rest of entries
        non_zeros_rest = non_zeros[1:]

        # pivot non zero
        start = non_zeros[0]
        A[[i, start],:] = A[[start,i],:]

        # Eliminate non zero entries
        row = A[i]
        A[non_zeros_rest] = A[non_zeros_rest] ^ row
        del non_zeros
        del non_zeros_rest
    print("Completed downards pass")
    B = A[:num_vars+1,:]
    for i in range(num_vars-1):
        # index of variable we're eliminating
        eliminate_var_index = num_vars - 1 - i 
        # select all non zeros in this column above elimination row
        non_zeros = numpy.nonzero(B[:eliminate_var_index,eliminate_var_index])
        row = B[eliminate_var_index,:]
        B[non_zeros,:] = B[non_zeros,:] ^ row
        del row
        del non_zeros
    return A
