import os
from RGB_extract import extract_feature
import numpy
import matplotlib.pyplot as plt

image_rootdir = "./dataset/"

f = open("result.txt", "w")


total = 0
accuate = 0
x = []
y = []
for parent,dirnames,filenames in os.walk(image_rootdir):
	for filename in filenames:
		print(filename)
		extract_feature(image_rootdir + filename)

		fc8W = numpy.loadtxt("weight_WW.txt")
		fc8b = numpy.loadtxt("weight_bb.txt")

		feature = numpy.loadtxt("feature.txt")


		feature = feature.reshape(1,3)
		fc8b = fc8b.reshape(1,6)


		res = numpy.dot(feature, fc8W) + fc8b

		res = res.reshape(6)
		#print(res)

		predict = res.argmax()
		
		arr = filename.split('_')
		aqi = int(arr[1])
		'''
		if(0 < aqi <= 50):
			aqi = 0
		elif(50 < aqi <= 100):
			aqi = 1
		elif(100 < aqi <= 150):
			aqi = 2
		elif(150 < aqi <= 200):
			aqi = 3
		elif(200 < aqi <= 300):
			aqi = 4
		else:
			aqi = 5
		'''
		f.write(str(aqi)+'\t'+str(predict)+'\n')
		x.append(aqi)
		y.append(predict)
		total = total + 1
		if aqi == predict:
			accuate = accuate + 1
			
print("accuracy = " + str(accuate/total))
#plt.plot(x,y)
#plt.show()
		
