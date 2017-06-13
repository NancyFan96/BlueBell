import pickle as pkl

with open('./train_data.pkl', 'rb') as f:
	feature_data = pkl.load(f)
	f.close()
	
	
input_data = open('./input.pkl', 'wb')
feature_array = []
label_array = []
i = 0
for item in feature_data:
	feature_array.append(feature_data[item])
	arr = item.split('_')
	aqi = int(arr[1])
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
	label_array.append(aqi)
	print(feature_data[item], aqi)
	
input = {}
input['feature'] = feature_array
input['label'] = label_array

pkl.dump(input, input_data)