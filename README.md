# JND-project
 Codes for my undergraduate final year project and part of our research paper.
 
## About my personal JND project
`FYP_codes_to_be_submitted` folder contains the codes for my undergraduate final year projects which is about *Perceptual experience and deep learning-based image/video compression & quality evaluation* based on JND ([Just-Noticeable-Difference](https://en.wikipedia.org/wiki/Just-noticeable_difference)) concept, which is a metric that takes the human perceptual system into consideration when performing image/video quality assessment. 

This project mainly includes the following works:
- Goodness-of-fit evaluation: Find the most suitable PDF (probability density function) model that fits the distribution of the sample JND data in [VideoSet](https://www.sciencedirect.com/science/article/pii/S1047320317300950) dataset.
- Bitrate modeling: Model the relationship between [QP](https://trac.ffmpeg.org/wiki/Encode/H.264) value (compression parameter of H.264 scheme) and video bitrate.
- Algorithm proposal: Design and implement a video compression algorithm based on JND and bitrate, compromising between user visual experience and cost of resources. Given a PDF model, a bitrate constraint, and a SUR (satisfied user rate) constraint, the proposed algorithm can return the JND point such that, when the original video is compressed with this JND point, the compressed video is able to satisfy all the specified constraints and maximize users' visual experience as much as possible at the same time.  

> ***P.S.*** The satisfied user ratio (SUR) is the fraction of users that do not perceive any distortion when comparing the original image to its compressed version. In other words, it implies the fraction of users that will ***not*** notice the artifacts in the compressed video, i.e., ***"satisfied"*** by the compressed video in terms of visual experience.

I also wrote a GUI APP which summarized all the above works, it mainly contains three tabs - correspond to the three major works:

- First tab - Goodness-of-fit evaluation: Given different videos and corresponding JND data in the dataset, fit different PDF models to the raw data and use K-S test statistic for evaluating the goodness-of-fit (in our paper, instead of K-S test, we use A-D test, which is another hypothesis test. We utilize p-value of the hypothesis test and negative log-likelihood value of MLE as the evaluating metrics). 

<p align = "center">
<img src = "JND_app_figs/JND_app_1.jpg" width = "800"/>
</p>

- Second tab - Bitrate modeling: Use three ground truth values of raw data to fit the exponential curve and model the relationship between QP values and bitrate of the videos in dataset.
<p align = "center">
<img src = "JND_app_figs/JND_app_2.jpg" width = "800"/>
</p>


- Third tab - Proposed algorithm: Given a specified PDF model, a bitrate constraint, and a SUR constraint, the proposed algorithm will output the found JND point.
<p align = "center">
<img src = "JND_app_figs/JND_app_3.jpg" width = "800"/>
</p>

**Note**: In order to run the APP correctly, you might need to modify some lines in the [code](https://github.com/seabro917/JND-project/blob/main/FYP_codes_to_be_submitted/App/JND_app_improved_upgraded.mlapp), which specify the data directory (I have already provided the data in three excel files `1280x720_1st.csv`, `1280x720_2nd.csv` and `1280x720_3rd.csv`).


## About our paper
`JND_summer_project` folder contains part of the codes for our research paper "*SUR-FeatNet: Predicting the satisfied user ratio curve for image compression with deep feature learning*", the paper can be found [here](https://link.springer.com/article/10.1007/s41233-020-00034-1). 

Specifically, the folder contains the codes for generating the following figures and tables. In `nll_values` and `p_values` folders, you can find the data shown in the table, that is; negative log-likelihood values of MLE and p-values of A-D test evaluated on the samples in [MCL-JCI](https://mcl.usc.edu/mcl-jci-dataset/) and [JND-Pano](https://link.springer.com/chapter/10.1007/978-3-030-00776-8_42) datasets, based on the evaluating algorithm described in our paper.


<img src = "paper_figs/image_5_first_JND.png" width = "273"/> <img src = "paper_figs/image_5_second_JND.png" width = "273"/> <img src = "paper_figs/image_5_third_JND.png" width = "273"/>
<img src = "paper_figs/image_14_first_JND.png" width = "273"/> <img src = "paper_figs/image_14_second_JND.png" width = "273"/> <img src = "paper_figs/image_14_third_JND.png" width = "273"/>

In this paper, we propose the first deep learning approach to predict SUR curves. The proposed approach relies on a siamese convolutional neural
network, transfer learning, and deep feature learning. The model utilizes image pairs consisting of a reference image and a compressed image for training. Full model implementation code can be found in this [repo](https://github.com/Linhanhe/SUR-FeatNet).

Please consider citing our paper with the following entry if you find the above codes and information useful to you
```@article{lin2020featnet,
  title={SUR-FeatNet: Predicting the satisfied user ratio curve for image compression with deep feature learning},
  author={Lin, Hanhe and Hosu, Vlad and Fan, Chunling and Zhang, Yun and Mu, Yuchen and Hamzaoui, Raouf and Saupe, Dietmar},
  journal={Quality and User Experience},
  volume={5},
  pages={1--23},
  year={2020},
  publisher={Springer}
}
```
