# Jute_disease_classification
Benchmarking ResNet-50, NASNet-Large, and Darknet-53 Architectures for Reliable Jute Disease Classification



A standalone MATLAB Graphical User Interface (GUI) designed for the rapid, batch-based diagnostic analysis of images using deep learning. 

**📌 Important Note:** This repository contains the supplementary MATLAB source code and GUI for our research manuscript, which is currently **under peer review**. Due to GitHub's 100 MB file size limit, the trained deep learning model (`.mat` file, ~300 MB) is hosted securely on Zenodo. 

---

## 📥 Getting the Trained Model (Required)

To run this GUI application, you must first download the pre-trained AI core engine from our Zenodo repository:

1. Visit the Zenodo repository: **(https://doi.org/10.5281/zenodo.23157309)**
2. Download the `net.mat` (or corresponding `.mat`) model file.
3. Save the downloaded file to your local machine. You will be prompted to select this file when initializing the AI Core in the GUI.

---

## ⚙️ Prerequisites

To execute the GUI and the inference engine, the following are required:
* **MATLAB** (R2023a or newer recommended)
* **Deep Learning Toolbox**
* **Computer Vision Toolbox** (for image pre-processing operations)

---

## 🚀 How to Run the Application

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/mftefek/Jute_disease_classification.git](https://github.com/mftefek/Jute_disease_classification.git)
   cd Jute_disease_classification


**Data Availability**

The data that support the findings of this study are openly available in Harvard Dataverse at https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/FJ1DM1. The dataset is described in detail and cited as: Islam, M. M., Sheikh, M. R. 2026. "A comprehensive image dataset of jute diseases". Data in Brief, 64(February 2026), 112334.

The sample images are from the dataset/article above.
