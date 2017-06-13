import pickle as pkl
import time
import tensorflow as tf
from sklearn.cross_validation import train_test_split
from sklearn.utils import shuffle

from alexnet import AlexNet


model_path = "./model.ckpt"

nb_classes = 5
epochs = 10
batch_size = 128

with open('./predict_data.pkl', 'rb') as f:
	data = pkl.load(f)
	f.close()
print(data)

#X_train, X_val, y_train, y_val = train_test_split(data['feature'], data['label'], test_size=0.33, random_state=0)
X_val = [data]
y_val = [0]

# Returns the second final layer of the AlexNet model,
# this allows us to redo the last layer for the traffic signs
# model.
labels = tf.placeholder(tf.int64, None)
fc7 = tf.placeholder(tf.float32, (None, 4096))
fc7 = tf.stop_gradient(fc7)
shape = (fc7.get_shape().as_list()[-1], nb_classes)
fc8W = tf.Variable(tf.truncated_normal(shape, stddev=1e-2))
fc8b = tf.Variable(tf.zeros(nb_classes))
logits = tf.nn.xw_plus_b(fc7, fc8W, fc8b)

cross_entropy = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logits, labels=labels)
loss_op = tf.reduce_mean(cross_entropy)
opt = tf.train.AdamOptimizer()
train_op = opt.minimize(loss_op, var_list=[fc8W, fc8b])
init_op = tf.global_variables_initializer()

preds = tf.arg_max(logits, 1)
accuracy_op = tf.reduce_mean(tf.cast(tf.equal(preds, labels), tf.float32))



'''
with tf.Session() as sess:
    sess.run(init_op)

    for i in range(epochs):
        # training
        X_train, y_train = shuffle(X_train, y_train)
        t0 = time.time()
        for offset in range(0, len(X_train), batch_size):
            end = offset + batch_size
            sess.run(train_op, feed_dict={fc7: X_train[offset:end], labels: y_train[offset:end]})

        val_loss, val_acc = eval_on_data(X_val, y_val, sess)
        # print(fc8W, fc8b)
        print("Epoch", i+1)
        print("Time: %.3f seconds" % (time.time() - t0))
        print("Validation Loss =", val_loss)
        print("Validation Accuracy =", val_acc)
        print("")
	
	
    print(fc8W,fc8b)
    saver = tf.train.Saver([fc8W, fc8b])
    save_path = saver.save(sess, model_path)  
    print("Model saved in file: %s" % save_path)
'''

with tf.Session() as sess:
    saver = tf.train.Saver([fc8W, fc8b])
    sess.run(init_op)
    saver.restore(sess, model_path)
    prediction = sess.run([preds], feed_dict={fc7: X_val, labels: y_val})
    
    print("prediction =", prediction[0])
    print("")
	
