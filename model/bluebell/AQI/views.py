# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import HttpResponse, StreamingHttpResponse
from django.utils import timezone

from AQI import models
from AQI.run_prediction import predict
from AQI.real_prediction import predict2

import random
import json
import time
import os
import traceback


# Create your views here.

def create_user(request):
	return HttpResponse(200)

def get_user(request):
	return HttpResponse(200)

def change_name(request):
	return HttpResponse(200)

def change_profile(request):
	return HttpResponse(200)

def change_signature(request):
	return HttpResponse(200)

def upload_comment(request):
	Uploaded_File =request.FILES.get("addImage", None)
	if not Uploaded_File:  
		print "no file"
		return HttpResponse("no files for upload!")  
	dst_url = os.path.join("/home/group4/bluebell/upload", Uploaded_File.name)
	print dst_url
	destination = open(dst_url,'wb+')    # 打开特定的文件进行二进制的写操作  
	for chunk in Uploaded_File.chunks(): # 分块写入文件  
		destination.write(chunk)  
	destination.close()  
	index = predict2(dst_url)
	print index
	#print(index)
	context = {}
	if index==0:
		context['aqi'] = 'good'
	elif index==1:
		context['aqi'] = 'moderate'
	elif index==2:
		context['aqi'] = 'light pollution'
	elif index==3:
		context['aqi'] = 'medium pollution'
	elif index==4:
		context['aqi'] = 'heavy pollution'
	#context['aqi'] = index
	context['image_url'] = dst_url
	return HttpResponse(json.dumps(context),content_type='text/json')

	
def get_image(request, fileurl):
	def file_iterator(fileurl, chunk_size=512):
		# 读大文件还是这样读比较好
		with open(fileurl, "rb") as f:
			# print f + '!!!'
			while True:
				c = f.read(chunk_size)
				if c:
					yield c
				else:
					break
	
	# 寻找该文件在数据库中对应的信息
	context = {}
	fileurl = fileurl.replace("//", "\\")
	fileurl = '/'+fileurl #在Apache上需要这句话
	if not os.path.exists(fileurl):
		context['result'] = 'Error: File does not exist!'
		return HttpResponse(json.dumps(context), content_type = 'text/json')

	# 验证文件是否存在，以及验证权限
	# download
	if request.method == "GET":	
		the_file_name = fileurl
		response = StreamingHttpResponse(file_iterator(the_file_name))
		response['Content-Type'] = 'image/jpeg' #'application/octet-stream'
		response['Content-Disposition'] = 'attachment;filename="{0}"'.format(the_file_name)
		# 返回文件
		return response
	
	else:
		# context['result']="Error: Wrong Method: Download --> GET ; Delete --> DELETE!"
		context['result']='Error: Method should be GET!'
		return HttpResponse(json.dumps(context), content_type = 'text/json')



def download_comment(request):
	return HttpResponse(200)

def get_abstract(request):
	return HttpResponse(200)
	
def not_found(request):
	#print('not found')
	context = {}
	return HttpResponse(json.dumps(context), content_type = 'text/json')

