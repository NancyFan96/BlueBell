import numpy as np
from scipy.misc import imread


def extract_feature(file_url):
	
	image = imread(file_url) #.astype(np.float32)
	image = np.array(image)
	image = image - np.mean(image)
	
		
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
			
			sum_R = sum_R + num_R
			sum_G = sum_G + num_G
			sum_B = sum_B + num_B
	
	output = [0,0,0]
	output[0] = sum_R / 100 / image.shape[1]
	output[1] = sum_G / 100 / image.shape[1]
	output[2] = sum_B / 100 / image.shape[1]
	print(output[0], output[1], output[2])
	
	
	
	np.savetxt('/home/group4/bluebell/feature.txt', output)
