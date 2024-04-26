import math

# compute the log2 of L(a,c).
# which gives the effective bits of an algorithm presented in L notation complexity.
# Example:
#   How many effective bits is a 128 bit prime for discrete log?
#   >>> lnotation(.5,math.sqrt(2),n)
#   40.70179122011839
def lnotation(a,c,n):
     return math.log(math.exp(c*math.log(n)**a * (math.log(math.log(n))**(1-a))),2)
