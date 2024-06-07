def minpoly(element, K):
    max_order = K.order().log(K.characteristic())
    mod = K.modulus()
    M = Matrix(K.base_ring(), nrows=max_order,ncols=max_order)
    for i in range(max_order):
        p = (element)**(i+1)
        p = p.polynomial().padded_list(max_order)
        for j in range(max_order):
            M[i,j] = p[j]
    sol = list((M\identity_matrix(max_order,max_order))[0,:])[0]
    P.<x> = PolynomialRing(K.base_ring())
    return (P(list(map(int,sol)))*x-1).monic()
    #return (M \ identity_matrix(max_order,max_order))
