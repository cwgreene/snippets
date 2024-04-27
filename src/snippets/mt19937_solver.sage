from sage.all import *

_int = (int, Integer)

import tqdm

# Class is from LakeCTF Quals 2023 author for "Choices"

class BoPoRint:
    # Σ vars[i] * 2^i
    def __init__(self, R, vars):
        self.R = R
        self.vars = tuple(vars)

    def __xor__(self, other):
        if isinstance(other, BoPoRint):
            assert len(self.vars) == len(other.vars)
            return BoPoRint(self.R, [v + w for v, w in zip(self.vars, other.vars)])
        else:
            return BoPoRint(self.R, [v + ((other >> i) & 1) for i, v in enumerate(self.vars)])

    __rxor__ = __xor__

    def __mul__(self, other):
        assert isinstance(other, _int) and other >= 0
        if other in [0, 1]:
            return self if other else BoPoRint(self.R, [self.R(0) for _ in self.vars])
        elif all(v == self.R(0) for v in self.vars[1:]):
            return BoPoRint(self.R, [self.vars[0] if o == "1" else self.R(0) for o in bin(other)[2:].zfill(len(self.vars))[::-1]])
        else:
            assert False, "Unsupported kind of mult"

    def __rmul__(self, other):
      return self * other

    def __rshift__(self, other):
        assert isinstance(other, _int)
        zeroes = tuple(self.R(0) for _ in range(other))
        return BoPoRint(self.R, (self.vars + zeroes)[-len(self.vars):])

    def __lshift__(self, other):
        assert isinstance(other, _int)
        zeroes = tuple(self.R(0) for _ in range(other))
        return BoPoRint(self.R, (zeroes + self.vars)[:len(self.vars)])

    def __and__(self, other):
        assert isinstance(other, _int)
        return BoPoRint(self.R, [v if (other >> i) & 1 else self.R(0) for i, v in enumerate(self.vars)])
    __rand__ = __and__

    def __mod__(self, other):
        assert isinstance(other, _int)
        assert int(other).bit_count() == 1
        return self & (other - 1)

    def eval(self, asn):
        def eval_v(x):
            return ZZ(sum(asn[m] for m in x.monomials()) % 2)
        return sum(eval_v(v) * 2**i for i, v in enumerate(self.vars))
        
        
def boporints(n, k, name="x"):
    R = BooleanPolynomialRing(n * k, name)
    gens = tuple(R.gens())
    return [BoPoRint(R, gens[k*i:k*(i + 1)]) for i in range(n)]


class MT19937:
    W = 32
    N = 624
    M = 397
    R = 31
    A = 0x9908B0DF
    U = 11
    D = 0xFFFFFFFF
    S = 7
    B = 0x9D2C5680
    T = 15
    C = 0xEFC60000
    L = 18

    F = 1812433253

    def __init__(self):
        self.state = boporints(self.N, self.W)
        self.gens = self.state[0].R.gens()
        self.genindex = {g:i for i,g in enumerate(self.gens)}
        self.idx = self.N

    def rand(self):
        if self.idx >= self.N:
            self._twist()
        y = self.state[self.idx]
        y ^^= (y >> self.U) & self.D
        y ^^= (y << self.S) & self.B
        y ^^= (y << self.T) & self.C
        y ^^= y >> self.L
        self.idx += 1
        return y % (2**self.W)

    def getrandbits(self, n):
        assert n <= 32
        return self.rand() >> (32 - n)

    def _twist(self):
        lower_mask = (1 << self.R) - 1
        upper_mask = 2^self.W - 1 - lower_mask
        for i in range(0, self.N):
            x = (self.state[i] & upper_mask) ^^ (self.state[(i + 1) % self.N] & lower_mask)
            xA = x >> 1
            xA ^^= (x % 2) * self.A
            self.state[i] = self.state[(i + self.M) % self.N] ^^ xA
        self.idx = 0

import time
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
            self.observed.append((expr, value & 2**i))
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
        M = Matrix(GF(2), size, size)
        print("Allocated Matrix:", time.time() - start)
        observed = vector(GF(2), size)
        print("Filling Matrix...")
        for i,(row, value) in tqdm.tqdm(enumerate(self.observed), total=size):
            matrix_row = [0]*size
            for monomial in row.monomials():
                M[i,self.model.genindex[monomial]] = 1
            observed[i] = value
        start = time.time()
        print("Solving Matrix for observed vector")
        solution = M \ observed
        print("Computed solution:", time.time() - start)
        print("Converting to numbers...")
        res = []
        for i in range(624):
            res.append(self.v2n(solution[32*i:32*(i+1)]))
        return res

import random
mrand = MT19937Solver()
rand = random.Random(int(1))
initial_state = rand.__getstate__()[1][:-1]
for i in tqdm.tqdm(range(624*32)):
    b = rand.getrandbits(1)
    mrand.submit(1, b)
result = mrand.solve()
for i in range(len(initial_state)):
    print(initial_state[i], result[i])