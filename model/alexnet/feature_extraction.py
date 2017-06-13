import time
import tensorflow as tf
import numpy as np
import pandas as pd
from scipy.misc import imread
from alexnet import AlexNet
import os

import pickle as pkl


x = tf.placeholder(tf.float32, (None, None, None, 3))
resized = tf.image.resize_images(x, (227, 227))

# NOTE: By setting `feature_extract` to `True` we return
# the second to last layer.
fc7 = AlexNet(resized, feature_extract=True)
# TODO: Define a new fully connected layer followed by a softmax activation to classify
# the traffic signs. Assign the result of the softmax activation to `probs` below.
# HINT: Look at the final layer definition in alexnet.py to get an idea of what this
# should look like.
feature = fc7

init = tf.global_variables_initializer()
sess = tf.Session()
sess.run(init)


aqi_f = open("./image_aqi.pkl", 'rb')
image_dict = pkl.load(aqi_f)
aqi_f.close()

image_rootdir = "./image/"

extracted = open("./train_data.pkl", 'rb')
train_dict = pkl.load(extracted)
extracted.close()

for parent,dirnames,filenames in os.walk(image_rootdir):
	i = 0
	for filename in filenames:
		i = i + 1
		print (i)
		if filename in train_dict:
			continue
		#if(i > 10):
		#	break
		try:
			f = open(image_rootdir + filename)
			image = imread(image_rootdir + filename) #.astype(np.float32)
			image = np.array(image)
			image = image - np.mean(image)
			# image = tf.image.resize_images(image, [1024,1024])
		except Exception as e:
			print (e)
			continue
		
		output = sess.run(feature, feed_dict={x: [image]})
		print (filename, output[0])
		train_dict[filename] = output[0]
		f.close
	
	with open("./train_data.pkl", 'wb') as f:
		pkl.dump(train_dict, f)




