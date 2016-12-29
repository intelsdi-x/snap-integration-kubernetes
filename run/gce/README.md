# Running Snap on Google Compute Engine
1. [Start work with Google Cloud Platform](#1-start-work-with-google-cloud-platform)  
2. [Install kubesnap](#2-install-kubesnap)

### 1. Start work with Google Cloud Platform

#### a) Open Google Cloud Platform Console
 - go to https://console.cloud.google.com/  
 - log in using your e-mail address
 - follow the instruction [how to create a Cloud Platform Console project](https://cloud.google.com/storage/docs/quickstart-console)


#### b) Select your project  
- select your project from the drop-down menu in the top right corner
  <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_01.png"> 

#### c) Switch to _**Compute Engine**_ screen

- select _Products & Services_ from GC Menu in the top left corner  

  <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_02.png"> 

- and then select _Compute Engine_ from the drop-down list

  <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_03.png">

#### d) Create a new VM instance  
- create a new VM instance
  <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_04.png">  

- set the instance name
- choose a machine with at least 4 vCPUs and at least 15GB RAM
- select Ubuntu 16.04 with standard persistent disk with at least 100GB

  <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_05.png">  

#### e) Open the VM terminal by click on SSH  
 -  click on SSH to open the VM terminal (it will open as a new window)

  <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_07.png"> 

#### f) Authorize access to Google Cloud Platform  
- manage credentials for the Google Cloud SD. To do that, run the following command:
  ```
  gcloud auth login
  ```
  Answer `Y` to the question (see below) and follow the instructions:
  -	copy the link in your browser and 
  -	authenticate with a service account which you use in Google Cloud Environment,
  - copy the verification code from browser window and enter it

   <img src="https://raw.githubusercontent.com/intelsdi-x/kubesnap/master/docs/images/image_08.png">

- check if you are on credentialed accounts:  
 ```
 gcloud auth list
 ```
### 2. Install kubesnap  
Clone kubesnap into your home directory:
```
git clone https://github.com/intelsdi-x/kubesnap
```

Go to kubesnap/tools:
```
cd kubesnap/tools
```

Provision kubesnap (it takes approximately 35 minutes on a VM with 4 vCPUs and 15 GB of RAM in us-central1-b zone):
```
./provision-kubesnap.sh
```
[TODO: migrate kubesnap to this repo]
