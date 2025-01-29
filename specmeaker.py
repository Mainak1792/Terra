import os
import numpy as np
import pandas as pd
import pywt
import matplotlib.pyplot as plt

file_path = r'C:\Users\mainak\Desktop\pythonProject\A1_footstep_feat_full.mat'

import scipy.io
import pandas as pd
# Read the dataset
dataset= scipy.io.loadmat(file_path)
print(dataset)
footstep_dataset = dataset['footstep_feat']
# ['footstep_feat']
featuresofevents = footstep_dataset[:,0:-1]
labels = footstep_dataset[:,-1]-1
print(labels)
#X = featuresofevents
# y = labels
import torch
import torchvision
def footstep_concatenation(x_train, y_train, footsteps_num):
    '''
    This function concatenates the raw footsteps temporal signal horizontally
    and returns the modified footsteps matrix where the number of columns represents
    the concatenated footsteps and raws represents the samples. So, for the given
    footsteps_num, every sample is actually the aggrergation of that much footsteps
    in a single sample

    Parameters
    ----------
    x_train : Input raw footsteps data matrix.
    y_train : Labels information of the data matrix
    footsteps_num : int value for the aggregating the number of footsteps in a
                    sampples

    Returns
    -------
    train_dataset : Modified footstep data matrix

    '''

    trn_smpl = x_train.shape[0]
    nm_trn = int(trn_smpl/footsteps_num)*footsteps_num

    y_train = y_train[0:nm_trn]


    trn_idx = np.arange(nm_trn)
    trn_rsz_nm = int(nm_trn/footsteps_num)
    trn_resized = trn_idx.reshape(trn_rsz_nm,footsteps_num)


    y_trn_comb = np.zeros([trn_rsz_nm,footsteps_num])
    for col in range(0,footsteps_num):
        y_trn_comb[:,col] = y_train[trn_resized[:,col]]


    row_idx=0
    mismatched_elmnts = []
    for  row in y_trn_comb:
        unique, counts = np.unique(row, return_counts=True)
        if len(unique) > 1:
            mismatched_elmnts.append(row_idx)
            # print (row_idx,row)
        row_idx=row_idx+1


    y_trn_comb = np.delete(y_trn_comb,(mismatched_elmnts), axis=0)
    trn_resized = np.delete(trn_resized,(mismatched_elmnts), axis=0)

    x_train = torch.Tensor(x_train)
    train_set = x_train[trn_resized[:,0]]
    for i in range(1,footsteps_num):
        train_set = torch.cat((train_set, x_train[trn_resized[:,i]]), dim=1)


    y_train = torch.Tensor(y_trn_comb[:,0])
    y_train = y_train.type(torch.LongTensor)

    train_dataset={}
    train_dataset['data_set'] = train_set
    train_dataset['labels_set'] = y_train

    return train_dataset

train_dataset1 = {}
train_dataset1 = footstep_concatenation(featuresofevents, labels, 1)
X =train_dataset1['data_set']
y= train_dataset1['labels_set']


plt.plot(X[5,:])
plt.show()
# ameters for CWT
scales = np.arange(1, 257)  # Adjust as needed
wavelet = 'morl'  # Choose wavelet type
# # Assu/ming class labels are in the 'y' variable
classes = np.unique(y)  # Get unique class labels
# notebook_path =r'D:\Python_2024\specs'

notebook_path = (r'C:\Users\mainak\Desktop\pythonProject\A1_new')

for class_label in classes:
    # Create folder for each class within 'output_folder'
    class_folder = os.path.join(notebook_path, str(class_label))
    os.makedirs(class_folder, exist_ok=True)

    # Filter data for the current class
    class_data = X[y == class_label]

    # Loop through the class data and save images
    for index, signal in enumerate(class_data):
        signal = signal.numpy()
        coefficients, _ = pywt.cwt(signal, scales, wavelet)
        plt.imshow(coefficients, cmap='jet')
        plt.axis('off')
        # plt.show()
        image_path = os.path.join(class_folder, f'cwt_image_{class_label}_{index}.png')
        print(image_path)
        plt.savefig(image_path, transparent=True, bbox_inches='tight', pad_inches=0)
        plt.close()  # C

#