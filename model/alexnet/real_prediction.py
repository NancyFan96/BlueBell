import os
from predict import extract_feature
import numpy
#import predict2


#extract_feature("test.jpg")

fc8W = numpy.loadtxt("weight_W.txt")
fc8b = numpy.loadtxt("weight_b.txt")

feature = numpy.loadtxt("feature.txt")


feature = feature.reshape(1,4096)
fc8b = fc8b.reshape(1,5)


res = numpy.dot(feature, fc8W) + fc8b

res = res.reshape(5)
print(res)

index = res.argmax()
print(index)
