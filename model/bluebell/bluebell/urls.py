"""bluebell URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.11/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url
from django.contrib import admin

from AQI import views

urlpatterns = [ 

	url(r'^admin/', admin.site.urls),

	url(r'^user/new_user$', views.create_user),
	url(r'^user/user_info$', views.get_user),
	url(r'^user/name$', views.change_name),
	url(r'^user/signature$', views.change_signature),
	url(r'^user/profile$', views.change_profile),
	
    url(r'^comments/upload$', views.upload_comment),  
    url(r'^comments/abstract$', views.get_abstract),
    url(r'^comments/download$', views.download_comment),  
	url(r'^getimage/(?P<fileurl>.+)$', views.get_image),
	url(r'^[^\s]*$', views.not_found),
	
]
