# Module 8 - Build Automation and CI/CD with Jenkins
## Demo Project:
Configure Webhook to trigger CI Pipeline automatically on
every change
## Technologies used:
Jenkins, GitLab, Git, Docker, Java, Maven
## Project Description:
* Install GitLab Plugin in Jenkins
* Configure GitLab access token and connection to
Jenkins in GitLab project settings
* Configure Jenkins to trigger the CI pipeline, whenever a
change is pushed to GitLab

## Repo:
https://gitlab.com/IrinaRoiter/java-maven-app
  

# Solution

<details>
<summary><b>'Pipeline type' job</b></summary>

Branch: master
https://gitlab.com/IrinaRoiter/java-maven-app/-/tree/master

* Install GitLab Plugin in Jenkins
```
Jenkins Manage->Plugins->Available Plugins->Search for GitLab->select it->Install it
Jenkins Manage->System=>GitLab section is available now
Configure GitLab:
Connection name: gitlab-connection
GitLAb host URL: https://gitlab.com/
Credentials: pat-gitlab-api
```
* Configure 'java-maven-build-pipeline-type' job
```
'java-maven-build-pipeline-type' job ->Configure
General->GitLab connection: 'gitlab-connection'
Triggers->choose "Build when a change is pushed to GitLab."
Select "Push events", "Open merge requests"
Save
```
* Configure GitLab to send events notifications to Jenkins
```
GitLab->Repo https://gitlab.com/IrinaRoiter/java-maven-app->Settings->Integrations
Choose 'Jenkins'
Jenkins server URL: http://165.227.47.177:8080/
Disable SSH connection
Project name: java-maven-build-pipeline-type
Username: admin
Password: token generated in GitLab for admin user
Save
Test settings
```
* Make changes in the code and validate that a new build is triggered automatically
```
Added a line in Jenkins file:
echo "Testing the integration between GitLab and Jenkins"
```
```
From build log:
Started by GitLab push by Irina Roiter 👈🏻 triggered on push event
Obtained Jenkinsfile from git https://gitlab.com/IrinaRoiter/java-maven-app.git
.....
[Pipeline] echo
Testing the integration between GitLab and Jenkins 👈🏻 displayed an added line 
....
Finished: SUCCESS
```
</details>

<details>
<summary><b>'Multibranch type' job</b></summary>

* Install 'Multibranch scan webhook trigger' plugin
```
Manage Jenkins->Plugins->Avaialble Plugins->Search for Install Multibranch scan webhook trigger
Install
```
* Configure trigger in'java-maven-build-multibranch-type' job
```
'java-maven-build-multibranch-type' job->Configure
Scan Multibranch Pipeline Triggers-> select 'Scan by webhook'->Trigger token 'gitlab-token'
Save
```
* Configure Webhook connection in GitLab
```
Connect to https://gitlab.com/IrinaRoiter/java-maven-app
Settings->Webhooks->Add webhook
Name: jenkins-webhook
URL: 
```
ℹ️ To construct an URL, go back to Jenkins
'java-maven-build-multibranch-type' job->Configure
Scan Multibranch Pipeline Triggers-> select 'Scan by webhook'->Trigger token 'gitlab-token'
Find the url as shown on the picture:
![webhook-url](images/webhook-url.png)

```
URL template is JENKINS_URL/multibranch-webhook-trigger/invoke?token=[Trigger token]
My URL is
URL: http://165.227.47.177:8080//multibranch-webhook-trigger/invoke?token=gitlab-token

Trigger: select "Push events"
Add Webhook
```
* Make a change in GitLab
```
Added a line under 'init' stage
echo "Testing GitLab and Jenkins integration" 
on 'jenkins-shared-library' branch
```
* Verify that 'java-maven-build-multibranch-type' job was triggerred on 'jenkins-shared-library' branch


</details>
