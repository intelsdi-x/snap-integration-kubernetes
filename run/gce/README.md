# Running Snap on Google Compute Engine
1. [Start work with Google Cloud Platform](#1-start-work-with-google-cloud-platform)  
2. [Install Kubernetes and Snap](#2-install-kubernetes-and-snap)

### 1. Start work with Google Cloud Platform

#### a) Open Google Cloud Platform Console
 - go to https://console.cloud.google.com/  
 - log in using your e-mail address
 - follow the instruction [how to create a Cloud Platform Console project](https://cloud.google.com/storage/docs/quickstart-console)


#### b) Select your project  
- select your project from the drop-down menu in the top right corner
  <img src="https://cloud.githubusercontent.com/assets/6523391/21567477/b0796fbc-ceac-11e6-9512-2de8a11ee67c.png"> 

#### c) Switch to _**Compute Engine**_ screen

- select _Products & Services_ from GC Menu in the top left corner  

  <img src="https://cloud.githubusercontent.com/assets/6523391/21567483/b7ec7ff0-ceac-11e6-86a2-066310426c10.png"> 

- and then select _Compute Engine_ from the drop-down list

  <img src="https://cloud.githubusercontent.com/assets/6523391/21567476/ae7f227e-ceac-11e6-8b82-b10260c2a298.png">

#### d) Create a new VM instance  
- create a new VM instance
  <img src="https://cloud.githubusercontent.com/assets/6523391/21567474/ac3b9be6-ceac-11e6-914e-d10746ee43d2.png">  

- set the instance name
- choose a machine with at least 4 vCPUs and at least 15GB RAM
- select Ubuntu 16.04 with standard persistent disk with at least 100GB

  <img src="https://cloud.githubusercontent.com/assets/6523391/21567478/b2477e6a-ceac-11e6-91c3-8ca2cc223f8f.png">  

#### e) Open the VM terminal by click on SSH  
 -  click on SSH to open the VM terminal (it will open as a new window)

  <img src="https://cloud.githubusercontent.com/assets/6523391/21567481/b46721dc-ceac-11e6-9ad9-556b18581e9e.png"> 

#### f) Authorize access to Google Cloud Platform  
- manage credentials for the Google Cloud SD. To do that, run the following command:
  ```
  gcloud auth login
  ```
  Answer `Y` to the question (see below) and follow the instructions:
  -	copy the link in your browser and 
  -	authenticate with a service account which you use in Google Cloud Environment,
  - copy the verification code from browser window and enter it

   <img src="https://cloud.githubusercontent.com/assets/6523391/21567579/7b905044-cead-11e6-9c72-ba51cf1ecef0.png">

- check if you are on credentialed accounts:  
 ```
 gcloud auth list
 ```
### 2. Install Kubernetes and Snap 
Clone kubesnap into your home directory:
```
git clone https://github.com/intelsdi-x/snap-integration-kubernetes
```

Go to snap-integration-kubernetes/run/gce:
```
cd snap-integration-kubernetes/run/gce
```

Provision kubesnap (it takes approximately 35 minutes on a VM with 4 vCPUs and 15 GB of RAM in us-central1-b zone):
```
./provision-snap.sh
```
