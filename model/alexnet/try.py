import requests
import re
import sqlite3
import os
import time
from collections import OrderedDict
import cPickle as pkl

dict = {}
for i in range(20):
	dict[i] = str(i)+"haha"

dic_f = open(image_aqi_dic,'rb')
		i_a_dic = pkl.load(dic_f)

	
with open("./image_aqi.pkl", 'wb') as f:

	pkl.dump(dict, f)