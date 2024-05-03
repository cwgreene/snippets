import fastmt

class MT19937Solver:
    def __init__(self):
        self.model = MT19937()
        self.observed = []

    def submit(self, bits, value):
        bit_expressions = self.model.getrandbits(bits).vars[:bits]

        # cannot extend observed
        # this call will have simply advanced the state
        if value is None:
            return

        for i, expr in zip(range(bits), bit_expressions):
            if value[i] is not None:
                pass
                self.observed.append((expr, value[i]))
        
    def v2n(self, vec):
        acc = 0
        for i, v in enumerate(vec):
            acc += 2**i * int(v)
        return acc

    def solve(self):
        size = self.model.N * self.model.W
        rows = []
        observed_values = []
        print("Allocating Matrix...")
        start = time.time()
        M = Matrix(GF(2), len(self.observed), size)
        print("Allocated Matrix:", time.time() - start)
        observed = vector(GF(2), len(self.observed))
        print("Filling Matrix...")
        for i,(row, value) in tqdm.tqdm(enumerate(self.observed)):
            matrix_row = [0]*size
            for monomial in row.monomials():
                M[i,self.model.genindex[monomial]] = 1
            observed[i] = value
        print("Solving Matrix for observed vector")
        start = time.time()
        solution = M \ observed
        print("Computed solution:", time.time() - start)
        print("Converting to numbers...")
        res = []
        for i in range(624):
            res.append(self.v2n(solution[32*i:32*(i+1)]))
        return res
