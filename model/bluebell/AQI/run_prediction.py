import os
from AQI.predict import extract_feature
import numpy
#import predict2

def predict(image_url):
	extract_feature(image_url)

	fc8W = numpy.loadtxt("/home/group4/bluebell/weight_W.txt")
	fc8b = numpy.loadtxt("/home/group4/bluebell/weight_b.txt")

	feature = numpy.loadtxt("/home/group4/bluebell/feature.txt")


	feature = feature.reshape(1,4096)
	fc8b = fc8b.reshape(1,5)


	res = numpy.dot(feature, fc8W) + fc8b

	res = res.reshape(5)
	#print(res)

	index = res.argmax()
	return index
