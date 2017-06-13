import tensorflow as tf
import numpy as np
import pandas as pd
from scipy.misc import imread
from alexnet import AlexNet
import os

import pickle as pkl

def extract_feature(file_url):
	nb_classes = 5
	x = tf.placeholder(tf.float32, (None, None, None, 3))
	resized = tf.image.resize_images(x, (227, 227))

	fc7 = AlexNet(resized, feature_extract=True)
	#feature = fc7

	init = tf.global_variables_initializer()
	sess = tf.Session()
	sess.run(init)

	image = imread(file_url) #.astype(np.float32)
	image = np.array(image)
	image = image - np.mean(image)
	# image = tf.image.resize_images(image, [1024,1024])


	output = sess.run(fc7, feed_dict={x: [image]})
	np.savetxt('feature.txt', output[0])



