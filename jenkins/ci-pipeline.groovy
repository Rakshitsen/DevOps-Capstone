pipeline {
   agent { label 'KMaster' }

    stages {
        stage('Cloning the Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Rakshitsen/Ci_pipeline.git'
            }
        }

        stage('Docker Image') {
            steps {
                sh "docker image prune -a -f"
                sh "docker build -t rakshitsen/central-image:${BUILD_NUMBER} ."
                sh "docker images"
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    sh "docker push rakshitsen/central-image:${BUILD_NUMBER}"
                    // Optional: Push 'latest' tag
                    // sh "docker tag rakshitsen/central-image:${BUILD_NUMBER} rakshitsen/central-image:latest"
                    // sh "docker push rakshitsen/central-image:latest"
                    sh "docker logout"
                }
            }
        }

        stage('Docker Run') {
            steps {
                sh '''
                CONTAINERS=$(docker ps -aq)
                if [ ! -z "$CONTAINERS" ]; then
                    docker rm -f $CONTAINERS
                fi
                '''
                sh "docker run -d -p 85:80 --name central-container-${BUILD_NUMBER} rakshitsen/central-image:${BUILD_NUMBER}"
            }
        }

        stage('Trigger Deploy Pipeline') {
            steps {
                build job: 'CD_PIPELINE',
                      parameters: [string(name: 'BUILD_TAG', value: "${BUILD_NUMBER}")],
                      wait: false
            }
        }
    }

    post {
        always {
            sh '''
            docker rm -f central-container-${BUILD_NUMBER} || true
            '''
        }
    }
}
