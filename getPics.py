#coding:utf-8

import sys
import os
import re

import httplib
import requests
import lxml.html
import lxml.etree

reload(sys)
sys.setdefaultencoding('utf-8') 

sess = requests.session()

api = "http://ugc.moji.com/index.php?picid="
DocumentPath = "moji-pics-from-2016"

if not os.path.exists(DocumentPath):
	os.mkdir(DocumentPath)

count = len(os.listdir(DocumentPath))
if os.path.exists(DocumentPath+"/record.txt"):
	count -= 1
print("目录下已有" + str(count) + "个图片")

for picid in range(54843142, 74243800):
# for picid in range(54843142, 54843143):
	if os.path.exists(DocumentPath + "/record.txt"):
		f = open(DocumentPath + "/record.txt", "r")
		all_record = f.read()
		f.seek(0,2)
		f.close()
		if str(picid) in all_record:
			pass
	
	url = api + str(picid)+"&cityid=1"
	r = sess.get(url)
	html = r.text.decode('utf8')
	html_tree = lxml.etree.HTML(html.decode('utf8'))

	# prase html
	picXpath = u"//img/@src"
	infoXpath = u"//span"
	picNodes = html_tree.xpath(picXpath)
	infoNodes = html_tree.xpath(infoXpath)

	picUrl = picNodes[0]
	infoText = infoNodes[0].text.decode('utf8')
	infoList = infoText.split(u"\xa0\xa0")
	Time = infoList[0].decode('utf8')
	Location = infoList[1].decode('utf8')

	m = re.search(r'\.[^\.]*$', picUrl)
	if m.group(0) and len(m.group(0)) <= 5:
		fix = m.group(0)
	else:
		fix = ".jpeg"
	imgPath = DocumentPath + "/" + str(count) + fix

	# download and record
	response = requests.get(picUrl, stream=True)
	if response.status_code == 200:
		print("download a new pic, id = " + str(count))
		with open(imgPath, 'wb') as img:
			img.write(response.content)
			img.close()
			f = open(DocumentPath + "/record.txt", "a+")
			f.write(str(count) + "\t" + str(picid) + "\t" + picUrl + "\t" + Time + "\t" + Location + "\n")
		 	f.close()
		 	count += 1





	







