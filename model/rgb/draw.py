import numpy
import matplotlib.pyplot as plt
import random

f = open("result.txt", "r")
x = []
y = []
for line in f:
	line = line.split('\t')
	x.append(int(line[0])+random.uniform(-5,5))
	y.append(int(line[1])+random.uniform(-0.1,0.1))

plt.scatter(x,y)
plt.show()