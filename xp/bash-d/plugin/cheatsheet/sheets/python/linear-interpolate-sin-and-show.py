import numpy
import matplotlib
import matplotlib.pyplot as plt

xp = [1, 2, 3]
fp = [3, 2, 0]
numpy.interp(2.5, xp, fp)
numpy.interp([0, 1, 1.5, 2.72, 3.14], xp, fp)
UNDEF = -99.0
numpy.interp(3.14, xp, fp, right=UNDEF)

x = numpy.linspace(0, 2*numpy.pi, 10)
y = numpy.sin(x)
xvals = numpy.linspace(0, 2*numpy.pi, 50)
yinterp = numpy.interp(xvals, x, y)
plt.plot(x, y, 'o')
plt.plot(xvals, yinterp, '-x')
plt.show()
