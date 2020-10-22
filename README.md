# DeepFoci

DNA double strand breaks (DSB) are the most serious DNA lesions, dangerous to human health. In this script, we introduce a custom semi-/fully-automatic method for DSB quantification (by means of H2AX+53BP1 fluorescence detection) that employs **nucleus segmentation based on deep learning, deep learning foci detection and MSER 3D foci segmentation**. 

Our software thus offers fast semi-automated quantification of DSB repair foci with high reproducibility. Unlike published approaches, it allows 3D-image analysis and can be trained for specific data. Hence, precision of expert manual analysis can be reached and additional information on DSB focus properties extracted. Moreover, focus soft-classification by logistic regression overcomes the problems related to uncertainty of threshold setting. The developed software improves DSB quantification for various practical applications and opens door to better understanding of DSB focus biology.

## Description

The proposed focus detection method consists of three main steps
1) Initial segmentation of single nuclei with Convolutional neuronal network (CNN), 
2) Detection of focus proposals with CNN and 
3) Maximally Stable Extremal Regions SER based foci segmentation.

## Annotated dataset used for training and verification

The proposed method was verified on two testing datasets: (1) patient-derived primocultures of tumor and normal cells, very heterogeneous in respect to H2AX+53BP1 focus properties and (2) permanent lines of normal human skin fibroblasts and radio-resistant glioblastoma cells (U87). All cells were exposed to 1-4 Gy of gamma-rays and H2AX+53BP1 foci were scored in various post-irradiation times.



bioRxiv paper:
[## DeepFoci: Deep Learning-Based Algorithm for Fast Automatic Analysis of DNA Double Strand Break Ionizing Radiation-Induced Foci](https://doi.org/10.1101/2020.10.07.321927)
Tomas Vicar,  Jaromir Gumulec,  Radim Kolar, Olga Kopecna, Eva Pagáčová,  Martin Falk


