#encoding=utf-8
import requests
import re
import sqlite3
import os
import time
from collections import OrderedDict
import cPickle as pkl

pattern_image = re.compile('<div class="scenery_image_detail">.*?<img src="(.*?)" alt="(.*?)">' , re.S)

api_key = "wvVJMxr-c7aJ22etP2yXcCXBgtLoV4ou"
api_secret  = "flo9wlgCQXntRKoAS1SfwJxwbZQ66p2X"

parse_value = {'api_key':api_key,'api_secret':api_secret,'image_url':None}
face_api = "https://api-cn.faceplusplus.com/imagepp/beta/detectsceneandobject"
label_list = ['Sunrise','Fog','Bridge','Building','Library','Bus Station','Woods','Reeds','Park','Coast','Lightning','Snow','Dusk','Rivers','Pool']




def get_aqi(aqi):
    aqi_db = sqlite3.connect(aqi)
    aqi_cursor = aqi_db.cursor()
    aqi_cursor.execute("SELECT * FROM CITY;")
    city = aqi_cursor.fetchall()
    citys = []
    city_index = {}
    for i,j in enumerate(city):
        citys.append(j[1])
        city_index[j[1]] = i+1
    his_aqi_index = {}
    aqi_cursor.execute("SELECT date_aqi, avgAQI, pm2_5, city FROM AQI;")  
    his_aqi = aqi_cursor.fetchall()
    for i in his_aqi:
        his_aqi_index[i[0]+str(i[3])] = i[1]
    return citys,city_index,his_aqi_index

def search_aqi(image_name,location,image_time,citys,city_index,aqi_index):
    if not location == None:
        # print location
        try:
            image_time = int(image_time)/10
            image_time = time.localtime(image_time)
            image_time = time.strftime("%Y-%m-%d",image_time)

            for i in citys:
                if i in location:
                    index = image_time + str(city_index[i])
                    if index in aqi_index:
                        aqi = aqi_index[index]
                        return image_name,aqi
            return None, None
        except Exception,e:
            return None,None
    return None,None
    
def download_image(url, name):
    # print "in here"
    parse_value['image_url']=url
    label = requests.post(face_api,data=parse_value)
    label = eval(label.content)
    scenes = label['scenes']
    obj = label['objects']
    result = False
    for l in scenes:
        print l['value']
        if l['value'] in label_list:
            result = True
            break
    for l2 in obj:
        print l2['value']
        if l2['value'] in label_list:
            result = True
            break
    if not result:
        return False

    r = requests.get(url, timeout = 5.)
    f = open('image/'+name, 'wb')
    f.write(r.content)
    return True


def get_image(count,citys,city_index,his_aqi_index,dic):
    base_url = "https://tianqi.moji.com/liveview/picture/"
    url = base_url + str(count)

    r = requests.get(url, timeout = 5.)
    content = r.text
    items = re.findall(pattern_image, content)

    if len(items)==0:
        return None, None
    else:
        item = items[0]
        name = item[0].split('/')[-1]
        print name
        if name in dic:
            return None,None
        name, aqi = search_aqi(image_name=name,location=item[1],image_time=name[:11],citys=citys,city_index=city_index,aqi_index=his_aqi_index)
        
        if name==None or aqi==None:
        	print "No aqi"
        	return None,None
        res = download_image(item[0], name)
        if res==False:
        	print "No label"
        	return None, None
        # #url image_name location
        # return item[0], name, item[1]
        return name,aqi

def run(b_index, e_index, aqi_db, image_aqi_dic):
	citys,city_index,his_aqi_index=get_aqi(aqi_db)
	try:
		dic_f = open(image_aqi_dic,'rb')
		i_a_dic = pkl.load(dic_f)
		dic_f.close()
	except Exception,e:
		i_a_dic = OrderedDict()

    # fail_count = 0
    # conn = init_sqlite()
	for i in range(b_index, e_index,20):
		time.sleep(1)
		try:
			
			name,aqi = get_image(i,citys,city_index,his_aqi_index,i_a_dic)

			if name==None or aqi==None:
				continue

			if name not in i_a_dic:
				i_a_dic[name]=aqi
			# image_time = name[:11]
			# sql_write(conn, i, url, image_time, name, location)
			# fail_count = 0
			# print "success:",i , url, image_time, name, location
			print "success:", i,name,aqi
		except Exception,e:
			print e
			print "fail:", i
			pass


	with open(image_aqi_dic, 'wb') as f:
		pkl.dump(i_a_dic, f)


if __name__ == '__main__':
	run(71464436,80147765,'./database_aqi.sqlite','./image_aqi.pkl')