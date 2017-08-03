import numpy
G = 1024**3
T = 1024**4
numpy.interp(x, (2*G, 8*G, 500*G, 4*T), (90, 80, 90, 99))
