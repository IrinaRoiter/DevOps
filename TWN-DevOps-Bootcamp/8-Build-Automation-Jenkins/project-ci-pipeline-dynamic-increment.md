# Module 8 - Containers with Docker
## Demo Project:
Dynamically Increment Application version in Jenkins Pipeline
## Technologies used:
Jenkins, Docker, GitLab, Git, Java, Maven
## Project Description:
* Configure CI step: Increment patch version
* Configure CI step: Build Java application and clean old artifacts
* Configure CI step: Build Image with dynamic Docker Image Tag
* Configure CI step: Push Image to private DockerHub repository
* Configure CI step: Commit version update of Jenkins back to Git repository
* Configure Jenkins pipeline to not trigger automatically on CI build commit to avoid commit loop

## Repo:
https://gitlab.com/IrinaRoiter/java-maven-app
  

# Solution


Branch: increment-version </br>
https://gitlab.com/IrinaRoiter/java-maven-app/-/tree/increment-version

<details>
<summary><b>Dynamically increment application version in Jenkins pipeline</b></summary>

* Increment patch version

```
Jenkinsfile:
script{
    echo "Incrementing app version..."
    sh 'mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit '
    def matcher = readFile ('pom.xml') =~ '<version>(.+)</version>'
    def version = matcher[0][1]
    env.IMAGE_TAG = "jma-$version-$BUILD_NUMBER"
}
```
👉🏻 To test 'mvn build-helper' command locally the command should be executed like this:
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} versions:commit '

* Clean old artifacts and build new JAR file
```
def buildJar() {
    echo 'Building Jar file...'
    sh 'mvn clean package'
}
```
* Build Image with dynamic Docker Image Tag and Push Image to private DockerHub repository
```
Jenkinsfile:
        stage('build image') {
            when {
                expression {
                    GIT_BRANCH == 'increment-version'
                }
            }
            steps {
                script {
                    gv.buildImage("${IMAGE_TAG}")
                }
            }
        }

```
```
Script.groovy:

def buildImage(String imageTag) {
        echo "Building Docker image ..."
        withCredentials([usernamePassword(credentialsId: 'pat-dockerhub-viewer', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
        sh "docker build -t irinaroiter/demo-app:${imageTag} ."
        sh "echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin"
        sh "docker push irinaroiter/demo-app:${imageTag}"
        }
}
```
* Commit version update of Jenkins and Script.groovy back to Git repository
Jenkinsfile:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/8ade9fbcb0001b60dd57e00dbe3b374288bc85fd/Jenkinsfile

Script.groovy:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/ddaa2284dd1a8fb96eb4d76000abc4d3dd1c4058/script.groovy  

* Jenkins build runs automatically on push event from GitLab

```
From build log:

...
Obtained Jenkinsfile from b5fe1e3d9c091921d5aaef1ce40ada700deb1791
[Pipeline] Start of Pipeline
...
Incrementing app version...
[Pipeline] sh
+ mvn build-helper:parse-version versions:set -DnewVersion=${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion} versions:commit
[INFO] Processing change of com.example:java-maven-app:1.1.0-SNAPSHOT -> 1.1.1
[INFO] Processing com.example:java-maven-app
[INFO]     Updating project com.example:java-maven-app
[INFO]         from version 1.1.0-SNAPSHOT to 1.1.1
...
==== ENV ====
+ printenv
+ sort
BRANCH_NAME=increment-version
IMAGE_TAG=jma-1.1.1-8
+ mvn clean package
[INFO] Scanning for projects...
[INFO] 
[INFO] ---------------------< com.example:java-maven-app >---------------------
[INFO] Building java-maven-app 1.1.1
[INFO]   from pom.xml
.... 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  12.676 s
[INFO] Finished at: 2026-04-16T19:00:25Z
[INFO] ------------------------------------------------------------------------
...
+ docker build -t irinaroiter/demo-app:jma-1.1.1-8 .
...
+ docker push irinaroiter/demo-app:jma-1.1.1-8
...
00178530fa5f: Pushed
jma-1.1.1-8: digest: sha256:825b868eafe47794d1e8ce5bb170c3f8513a1c654303d3cb65232296bd5f80b7 size: 1160
...
Finished: SUCCESS
Jenkins 2.541.3
```
* Validate image with the tag - jma-1.1.1-8 on DockerHub

https://hub.docker.com/repository/docker/irinaroiter/demo-app/tags/jma-1.1.1-8/sha256-825b868eafe47794d1e8ce5bb170c3f8513a1c654303d3cb65232296bd5f80b7
 
* Add a new stage and run git commands to push pom.xml changes back to GitLab
```
Jenkinsfile:
stage('commit version update') {
    when {
        expression {
            GIT_BRANCH == 'increment-version'
        }
    }    
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'pat-gitlab-viewer', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh '''
            git config --global user.name "jenkins"
            git config --global user.email "jenkins@example.com"

            git status
            git branch
            git config --list

            git remote set-url origin https://$USERNAME:$PASSWORD@gitlab.com/IrinaRoiter/java-maven-app.git
            git add pom.xml
            git commit -m "Increment version to $IMAGE_TAG"
            git push origin HEAD:increment-version
            '''
            }
        }
    }
}
```
</details>

<details>
<summary><b>Configure Jenkins pipeline to not trigger automatically on CI build commit to avoid commit loop</b> </summary>

* Install 'Ignore committer strategy' plugin
```
Manage Jenkins->Available plugins->Search for 'Ignore committer strategy' plugin->Install
```
* Configure 'java-maven-build-multibranch-type' job
```
'java-maven-build-multibranch-type'->Configure->Branch sources->Build strategies->Add 'Ignore commiter strategy'
e-mail: jenkins@example.com
Select 'Allow builds when a changeset contains non-ignored author(s)'
Save
```
* Test it
```
Make a new commit-> pipeline gets triggered->pipeline makes a new commit->new build is not triggered
``` 
</details>