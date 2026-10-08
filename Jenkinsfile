pipeline {

    agent any
    //agent { label 'Demo' }

    parameters {

        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'praveensingam1994')
    }

    stages {

        stage('Git Checkout') {
            when { expression { params.action == 'create' } }
            steps {
                git(
                    branch: "main",
                    url: "https://github.com/saicharan-clan/Java_app_3.0"
                )
            }
        }

        stage('Unit Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                withEnv([
                    'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64',
                    'PATH+JAVA=/usr/lib/jvm/java-8-openjdk-amd64/bin'
                ]) {
                    sh 'java -version'
                    sh 'mvn clean test'
                }
            }
        }

        stage('Integration Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                withEnv([
                    'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64',
                    'PATH+JAVA=/usr/lib/jvm/java-8-openjdk-amd64/bin'
                ]) {
                    sh 'mvn verify'
                }
            }
        }

        stage('Static code analysis: Sonarqube') {
            when { expression { params.action == 'create' } }
            steps {
                withEnv([
                    'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64',
                    'PATH+JAVA=/usr/lib/jvm/java-8-openjdk-amd64/bin'
                ]) {
                    withSonarQubeEnv('SonarQube') {
                        sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
                    }
                }
            }
        }

        stage('Quality Gate Status Check : Sonarqube') {
            when { expression { params.action == 'create' } }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Maven Build : maven') {
            when { expression { params.action == 'create' } }
            steps {
                withEnv([
                    'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64',
                    'PATH+JAVA=/usr/lib/jvm/java-8-openjdk-amd64/bin'
                ]) {
                    sh 'mvn package -DskipTests'
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                sh "docker build -t ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag} ."
            }
        }

        stage('Docker Image Scan: trivy') {
            when { expression { params.action == 'create' } }
            steps {
                sh "trivy image ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
            }
        }

        stage('Docker Image Push : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh """
                        echo "\$DOCKER_PASSWORD" | docker login -u "\$DOCKER_USERNAME" --password-stdin
                        docker push "\$DOCKER_USERNAME/${params.ImageName}:${params.ImageTag}"
                    """
                }
            }
        }

        stage('Docker Image Cleanup : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                sh "docker rmi ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag} || true"
            }
        }
    }
}
