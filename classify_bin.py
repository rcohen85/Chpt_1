import keras
from keras.models import load_model
import scipy.io as spio
import os
import h5py
import hdf5storage
import numpy as np

def load_ts(fileName):
	matData = spio.loadmat(fileName, squeeze_me=True)
	x_train = mat['trainDataAll'] # array
	return x_train


# directory = os.fsencode('I:/JAX13D_broad_metadata/TPWS_noMinPeakFr')
inDir = 'J:/WAT_WC_03/New folder'
directory = os.fsencode(inDir)
# load trained network
os.chdir(directory)
model = load_model('I:/cluster_NNet/TrainTest/20200803-091722/NNet.h5')
outDir = 'J:/WAT_WC_03/New folder'
for file in os.listdir(directory):
	fileName = os.fsdecode(file)
	if fileName.endswith("toClassify.mat"):
				print(fileName)
				f = h5py.File(fileName,'r')
				matData = f['toClassify'].value

				print(matData.shape)
				if matData.shape[0]>2:
						fileNameOut = fileName.replace('toClassify.mat','predLab.mat')
						fileNameOut = os.path.join(outDir,fileNameOut)
						print(fileNameOut)
						matData = matData/np.std(matData,axis=0)
						predictedLabels = model.predict_classes(matData.transpose())
						probs = model.predict(matData.transpose())
						matOutData ={}
						matOutData[u'predLabels'] = predictedLabels
						matOutData[u'probs'] = probs
						hdf5storage.write(matOutData,'.',fileNameOut,matlab_compatible = True)
				continue
	else:
		continue
