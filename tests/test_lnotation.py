from snippets.math import lnotation
import math

def test_lnotation():
    lnotation(.5, math.sqrt(2), 2**128) == 40.70179122011839
