LEO Channel Model & ECOCSI Channel Prediction Model
===

This script can generate LEO CSI training and validation data and can perform CSI prediction using GRU neural network.

```
Environment Setup
* STK 11
* Matlab 2020b
```

## Installation

1. Download System Tool Kit (STK 11): [Download](https://drive.google.com/file/d/1zEJDTEiSir65Ngu51Ek76j7cOV1QoUUm/view?usp=sharing)
    * Click install.exe to install STK
    ![](https://i.imgur.com/auEEbzn.png)
    * Then, click Crack file to read Readme.txt
    ![](https://i.imgur.com/HP1foKh.png)
    * 

2. Download latest Matlab (2020b): [Download](https://www.mathworks.com/downloads/)
:::info
You can get educational account by signing up matlab using cc.ncu mail
:::

3. Clone the github project: [Link]()
    * Open git bash
```bash
git clone git@github.com:Alverson22/GRUChannelPrediction.git
```

## STK Tutorial

:star: STK tutorial website [Link](https://help.agi.com/stk/index.htm)

1. Download the scenario: [Download](https://drive.google.com/file/d/1lOCqG2KkEVDuhr_UUj88vat4Od_yATFy/view?usp=sharing)

2. After download the scenario, execute STK and click "Open a Scenario"
![](https://i.imgur.com/BOjvAcz.png)

3. Choose the .sc file in the scenario file
![](https://i.imgur.com/VTrtAdU.png)

4. Click the Access tool from receiver to get the propagation parameters
![](https://i.imgur.com/rP7ofzI.png)
    * Generate the corresponding report
![](https://i.imgur.com/m2SybEZ.png)
    * Save the parameters
![](https://i.imgur.com/6mEtJhA.png)

### Note

You can customize the report

![](https://i.imgur.com/f2HkOKL.png)






## Compile Step

1. getSatChannelParam.m
    * Set up parameters for LEO satellite channel model
    * The LEO parameters is generated from System Tool Kit (STK)

2. DataGeneration.m
    * Generate the CSI

3. TrainingGRU.m
    * Training RNN network

4. Testing.m
    * Testing the RNN model on the data set that the RNN model have ever seen