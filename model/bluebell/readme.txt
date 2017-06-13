这是个django项目，是服务器端的代码
db.sqlite3是数据库
bvlc-alexnet.npy weight都是神经网络的参数
manage.py是django项目的管理文件，和我们的内容没关系

有关系的是AQI文件夹下的
views.py 实现对不同url请求的处理
（关于url的定义在bluebell文件夹下的url.py）
run_prediction.py 是一开始那个提取alexnet特征的方法，返回aqi的预测结果
real_prediction.py 是后来那个算RGB的方法，也是返回aqi的预测结果
predict.py 其实是提取alexnet特征的（和predict没关系。。。）
RGB_extract.py 是提取RGB特征
