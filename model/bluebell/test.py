import requests

image = {"addImage": open("image1.jpeg", "rb")}
response = requests.post("http://162.105.175.115:8004/bluebell/comments/upload", files=image)

f = open("log.html", "wb")
f.write(response.text.encode("utf-8"))

print response.text
