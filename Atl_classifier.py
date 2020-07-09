import keras
import h5py
import hdf5storage
import os

from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation
from keras import initializers
from keras import regularizers
from keras.optimizers import SGD
from keras.callbacks import TensorBoard
import numpy as np
import scipy.io as spio
import datetime
#import tensorflow as tf

#tensorboard --logdir=G:/NNet_TrainLogs --host localhost --port 8088

trainSetFile = 'G:/cluster_NNet/TrainTest/TrainSet_MSPICIWV_NewSonar_5000.mat'
mat1 = h5py.File(trainSetFile, 'r')

x_train = mat1['trainMSPICIWV'][()]
x_train = x_train.transpose()
y_trainMat = mat1['trainLabelSet'][()]
print(x_train.shape)
print(y_trainMat.shape)


testSetFile = 'G:/cluster_NNet/TrainTest/TestSet_MSPICIWV_NewSonar_500.mat'
mat2 = h5py.File(testSetFile, 'r')
x_test = mat2['testMSPICIWV'][()]
x_test = x_test.transpose()
y_testMat = mat2['testLabelSet'][()]

y_train = keras.utils.to_categorical(y_trainMat.transpose()-1)
y_test = keras.utils.to_categorical(y_testMat.transpose()-1)

#x_train = x_train[:,0:249]
#x_test = x_test[:,0:250]
print(x_train.shape)
print(y_train.shape)

batch_size = 500
model = Sequential()

model.add(Dense(512, activation='relu', input_dim=491, kernel_initializer='glorot_uniform', bias_initializer='zeros'))
model.add(Dropout(0.5))
model.add(Dense(512, activation='relu', kernel_initializer='glorot_uniform', bias_initializer='zeros'))
model.add(Dropout(0.5))
model.add(Dense(512, activation='relu', kernel_initializer='glorot_uniform', bias_initializer='zeros'))
model.add(Dropout(0.5))
model.add(Dense(512, activation='relu', kernel_initializer='glorot_uniform', bias_initializer='zeros'))
model.add(Dropout(0.5))
model.add(Dense(22, activation='softmax', kernel_initializer='glorot_uniform', bias_initializer='zeros'))

#sdg = SGD(lr=0.01, momentum=0.9)# decay=1e-6, nesterov=True)
model.compile(loss='categorical_crossentropy',
              optimizer='rmsprop',
              metrics=['accuracy'])

#log_dir = "logs/fit/" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
log_dir = "G:\\cluster_NNet\\TrainLogs\\"+ datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard = keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
#tensorboard = TensorBoard(log_dir=log_dir, histogram_freq=1)
save_dir = "G:\\cluster_NNet\\TrainTest\\"+ datetime.datetime.now().strftime("%Y%m%d-%H%M%S")+"\\"
os.mkdir(save_dir)

model.fit(x_train, y_train,
          epochs=15, shuffle = True,
          batch_size = batch_size,
          callbacks=[tensorboard])

# model.fit(x_train, y_train,
#           epochs=20, shuffle = True,
#           batch_size = batch_size)

print("\nValidating ...")
score, accuracy = model.evaluate(x_test, y_test, batch_size=batch_size, verbose=1)
print("Dev loss:  ", score)
print("Dev accuracy:  ", accuracy)


model.save(save_dir+'NNet.h5')
# model = load_model('myModel.h5')
testOut = model.predict_classes(x_test)
probs = model.predict(x_test)

mat = spio.savemat(save_dir+'TestOutput.mat',{'testOut':testOut,'probs':probs})


# model = load_model('myModel_dense_unsup.h5')
