# LearnFoci

DNA double strand breaks (DSB) are the most serious DNA lesions, dangerous to human health. In this script, we introduce a custom semi-/fully-automatic method for DSB quantification (by means of H2AX+53BP1 fluorescence detection) that employs **nucleus segmentation based on deep learning, MSER 3D focus segmentation, and logistic regression classification to discriminate foci from the noise**. 

Our software thus offers fast semi-automated quantification of DSB repair foci with high reproducibility. Unlike published approaches, it allows 3D-image analysis and can be trained for specific data. Hence, precision of expert manual analysis can be reached and additional information on DSB focus properties extracted. Moreover, focus soft-classification by logistic regression overcomes the problems related to uncertainty of threshold setting. The developed software improves DSB quantification for various practical applications and opens door to better understanding of DSB focus biology.

## Description

The proposed focus detection method consists of three main steps
1) Initial segmentation of single nuclei with Convolutional neuronal network (CNN), 
2) Detection of focus proposals within each segmented nucleus using Maximally stable extremal region (MSER) approach and 
3) Classification of true foci with logistic regression (LR).This strategy allows for rapid computational data processing under the control of the evaluator.

## Annotated dataset used for training and verification

The proposed method was verified on two testing datasets: (1) patient-derived primocultures of tumor and normal cells, very heterogeneous in respect to H2AX+53BP1 focus properties and (2) permanent lines of normal human skin fibroblasts and radio-resistant glioblastoma cells (U87). All cells were exposed to 1-4 Gy of gamma-rays and H2AX+53BP1 foci were scored in various post-irradiation times.

The annotated confocal microscopy dataset used for the training of this method is available to download at Zenodo.org repository, divided into following parts:

- Part 1/3 (this dataset): Head and neck primocultures immunostained with gH2AX/53BP1, 
[DOI 10.5281/zenodo.2564980](https://doi.org/10.5281/zenodo.2564980).
- Part 2/3: U-87 and NHDF Cells exposed to 1-4 Gy confocal microscopy data of head and neck tumor primocultures immunostained with gH2AX/53BP1,[DOI 10.5281/zenodo.2572450](https://doi.org/10.5281/zenodo.2572450). 174 TIFFs
- Part 3/3: training dataset for nuclei and gH2AX foci with ground truth annotation masks. 
[DOI 10.5281/zenodo.2576241](https://doi.org/10.5281/zenodo.2576241). 150 TIFFs for nuclei learning incl 150 png masks + 

