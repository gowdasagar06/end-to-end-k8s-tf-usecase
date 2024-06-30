pipeline {
    agent any
        tools {
        jdk 'java'
    }

    environment {
        GIT_REPO_NAME = "Manifests-eks-argocd-2tier"
        GIT_USER_NAME = "gowdasagar06"    
        DEPLOYMENT_PATH = "argocd-eks-manifests/two-tier-app-deployment.yml"
        DOCKER_IMAGE_NAME = "flaskapp" 
        // DOCKER_IMAGE_NAME = "2tier-blue-green" 
        DOCKER_HUB_USER = "gowdasagar" 
        MYSQLCLIENT_CFLAGS = '-I/usr/include/mysql'
        MYSQLCLIENT_LDFLAGS = '-L/usr/lib/x86_64-linux-gnu -lmysqlclient'
    }
    stages {
        stage("Code") {
            steps {
                git url: "https://github.com/gowdasagar06/2-Tier-Flask-App.git", branch: "main"
            }
        }
        stage('Dependency Installation') {
            steps {
                sh "sudo apt-get update -y"
                sh "sudo apt-get install -y libmysqlclient-dev"
                sh "which pip3"
                sh "pip install mysqlclient --global-option=build_ext --global-option=\"${MYSQLCLIENT_CFLAGS}\" --global-option=\"${MYSQLCLIENT_LDFLAGS}\""
                sh "pip3 install -r requirements.txt"
            }
        }

        stage ('OWASP Dependency-Check Vulnerabilities') {
            steps {
               dependencyCheck additionalArguments: '--format HTML', odcInstallation: 'Dp-Check'
            }
        }
        stage("Build & Test") {
            steps {
                sh "sudo docker build . -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
            }
        } 
        stage("Push to DockerHub") {
            steps {
                withCredentials([usernamePassword(credentialsId: "dockerHub", passwordVariable: "dockerHubPass", usernameVariable: "dockerHubUser")]) {
                    sh "sudo docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                    sh "sudo docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                     sh "sudo docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:latest"
                    sh "sudo docker push ${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                     sh "sudo docker push ${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:latest"
   
                    //  sh "sudo docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:blue"
                    //   sh "sudo docker push ${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:blue"
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/gowdasagar06/Manifests-eks-argocd-2tier.git'
            }
        }
        stage('Update Deployment File') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        def NEW_IMAGE_NAME = "${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "sed -i 's|image: .*|image: $NEW_IMAGE_NAME|' ${DEPLOYMENT_PATH}"
                        sh "git config --global user.email 'sagargowda6666@gmail.com' "
                        sh "git config --global user.name 'gowdasagar06' "
                        sh 'git add ${DEPLOYMENT_PATH}'
                        sh "git commit -m 'Update image' "
                        sh "git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main"
                    }
                }
            }
        }
    }
}
