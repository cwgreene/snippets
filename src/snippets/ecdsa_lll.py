def generate_matrix(order : int, pairs, bound: int):
    # initial N rows
    count = len(pairs)
    matrix = []
    for i in range(count):
        row = [0]*(i+2)
        row[i] = order
        matrix.append(row)
    
    # get last pair
    sig_n, msg_n = pairs[-1]
    s_n_inv = pow(sig_n.s, -1, order)
    rs_n = s_n_inv*sig_n.r
    ms_n = s_n_inv*msg_n
    
    # append risi
    row_risi : list = [0]*(i+2)
    for i in range(count - 1):
        sig_i, msg_i = pairs[i]
        r = sig_i.r
        s_i_inv = pow(sig_i.s,-1, order)
        entry = r*s_i_inv - rs_n
        row_risi[i] = entry
    row_risi[i+1] = bound/order
    matrix.append(row_risi)

    # append misi
    row_misi : list = [0]*(i+2)
    for i in range(count -1):
        sig_i, msg_i = pairs[i]
        entry = msg_n*pow(sig_i.s,-1,order) - ms_n
        row[i] = entry
    row_misi[i+2] = bound
    matrix.append(row_misi)

    return matrix
