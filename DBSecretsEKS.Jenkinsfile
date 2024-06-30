// Task 1: Deploy an sample application using EKS into Jenkins.
// Note : Don’t pass the secrets values directly (EX: use environment variables)


pipeline {
    agent any
        tools {
        jdk 'java'
    }

    environment {
        DEPLOYMENT_PATH = "eks-manifests/two-tier-app-deployment.yml"
        DOCKER_IMAGE_NAME = "flaskapp" 
        DOCKER_HUB_USER = "gowdasagar" 
        MYSQLCLIENT_CFLAGS = '-I/usr/include/mysql'
        MYSQLCLIENT_LDFLAGS = '-L/usr/lib/x86_64-linux-gnu -lmysqlclient'
        DB_USER = credentials('MYSQL_USER')
        DB_PASS = credentials('	MYSQL_PASSWORD')
        DB_NAME = credentials('MYSQL_DATABASE')
        ENVSUBST_PATH = "eks-manifests/mysql-deployment_tmp.yml"
    }
    stages {
        stage("Code") {
            steps {
                git url: "https://github.com/gowdasagar06/2-Tier-Flask-App.git", branch: "main"
            }
        }
        stage('Dependency Installation') {
            steps {
                sh "sudo apt-get update"
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
                }
            }
        }
        
        stage('Update Deployment File') {
            steps {
                script {
                        def NEW_IMAGE_NAME = "${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "sed -i 's|image: .*|image: $NEW_IMAGE_NAME|' ${DEPLOYMENT_PATH}"
                        //  sh "envsubst '$NEW_IMAGE' < ${DEPLOYMENT_PATH} > two-tier-app-deployment.yml"
                        sh "envsubst '$DB_USER $DB_PASS $DB_NAME' < ${ENVSUBST_PATH} > eks-manifests/mysql-deployment.yml"
                        sh "cat ${ENVSUBST_PATH}"
                        
                    
                }
            }
        }
         stage('Deploy in EKS') {
            steps {
               withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "AWS", ]]){

                    script {
                            sh "aws eks update-kubeconfig --name demo --region ap-south-1"
                            sh "kubectl apply -f eks-manifests/namespace.yml"
                            sh "sleep 5"
                            sh "kubectl apply -f eks-manifests/"
                      
                    
                }
            }
          }
        }
    }
        
}
