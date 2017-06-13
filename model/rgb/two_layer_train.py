import pickle as pkl
import time
import tensorflow as tf
from sklearn.cross_validation import train_test_split
from sklearn.utils import shuffle
import numpy


model_path = "./model.ckpt"

nb_classes = 6
epochs = 1000
batch_size = 16

with open('./input.pkl', 'rb') as f:
	data = pkl.load(f)
	f.close()
	
X_train, X_val, y_train, y_val = train_test_split(data['feature'], data['label'], test_size=0.33, random_state=0)

def add_layer(inputs, in_size, out_size, activation_function=None):
    # add one more layer and return the output of this layer
    Weights = tf.Variable(tf.random_normal([in_size, out_size]))
    biases = tf.Variable(tf.zeros([1, out_size]) + 0.1)
    Wx_plus_b = tf.matmul(inputs, Weights) + biases
    if activation_function is None:
        outputs = Wx_plus_b
    else:
        outputs = activation_function(Wx_plus_b)
    return outputs

# Returns the second final layer of the AlexNet model,
# this allows us to redo the last layer for the traffic signs
# model.
labels = tf.placeholder(tf.int64, None)
fc7 = tf.placeholder(tf.float32, (None, 3))
fc7 = tf.stop_gradient(fc7)
#shape = (fc7.get_shape().as_list()[-1], nb_classes)
#fc8W = tf.Variable(tf.truncated_normal(shape, stddev=1e-2))
#fc8b = tf.Variable(tf.zeros(nb_classes))
#logits = tf.nn.xw_plus_b(fc7, fc8W, fc8b)
# add hidden layer
l1 = add_layer(fc7, 3, 10, activation_function=tf.nn.relu)
# add output layer
logits = add_layer(l1, 10, 6, activation_function=None)


cross_entropy = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logits, labels=labels)
loss_op = tf.reduce_mean(cross_entropy)
opt = tf.train.AdamOptimizer()
train_op = opt.minimize(loss_op)
init_op = tf.global_variables_initializer()

preds = tf.arg_max(logits, 1)
accuracy_op = tf.reduce_mean(tf.cast(tf.equal(preds, labels), tf.float32))


def eval_on_data(X, y, sess):
    total_acc = 0
    total_loss = 0
    for offset in range(0, len(X), batch_size):
        end = offset + batch_size
        X_batch = X[offset:end]
        y_batch = y[offset:end]

        loss, acc = sess.run([loss_op, accuracy_op], feed_dict={fc7: X_batch, labels: y_batch})
        total_loss += (loss * len(X_batch))
        total_acc += (acc * len(X_batch))

    return total_loss/len(X), total_acc/len(X)


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
	
    numpy.savetxt('weight_W.txt', fc8W.eval(session=sess))
    numpy.savetxt('weight_b.txt', fc8b.eval(session=sess))

	
	
    print(fc8W,fc8b)
    saver = tf.train.Saver([fc8W, fc8b])
    save_path = saver.save(sess, model_path)  
    print("Model saved in file: %s" % save_path)


with tf.Session() as sess:
    saver = tf.train.Saver([fc8W, fc8b])
    sess.run(init_op)
    saver.restore(sess, model_path)
    val_loss, val_acc = eval_on_data(X_val, y_val, sess)
    
    # print(fc8W, fc8b)
    print("Epoch", 1)
    print("Validation Loss =", val_loss)
    print("Validation Accuracy =", val_acc)
    print("")