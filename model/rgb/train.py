import time
import tensorflow as tf
import numpy as np
import pandas as pd
from scipy.misc import imread
import os

import pickle as pkl




image_rootdir = "./dataset/"
train_dict = {}

for parent,dirnames,filenames in os.walk(image_rootdir):
	for filename in filenames:
		print(filename)
		f = open(image_rootdir + filename)
		image = imread(image_rootdir + filename) #.astype(np.float32)
		image = np.array(image)
		
		middle = int(image.shape[1])/2
		middle = int(middle)
		print(middle)
		pivot = int(image[0][middle][0]) + int(image[0][middle][1]) + int(image[0][middle][2])
		pivot_R = int(image[0][middle][0])
		pivot_G = int(image[0][middle][1])
		pivot_B = int(image[0][middle][2])
		sum_R = 0
		sum_G = 0
		sum_B = 0
		max = 70
		count = 0
		for i in range(100):
			for j in range(image.shape[1]):
				num_R = int(image[i][j][0])
				num_G = int(image[i][j][1])
				num_B = int(image[i][j][2])
				
				if abs(num_R-pivot_R) > max:
					continue
				if abs(num_G-pivot_G) > max:
					continue
				if abs(num_B-pivot_B) > max:
					continue
				
				count = count+1
				sum_R = sum_R + num_R
				sum_G = sum_G + num_G
				sum_B = sum_B + num_B
		
		output = [0,0,0]
		output[0] = sum_R / count
		output[1] = sum_G / count
		output[2] = sum_B / count
		print(output[0], output[1], output[2])
		
		train_dict[filename] = output
	
	with open("./train_data.pkl", 'wb') as f:
		pkl.dump(train_dict, f)




