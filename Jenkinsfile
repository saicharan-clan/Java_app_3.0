pipeline {

    agent any
    // agent { label 'Demo' }

    parameters {

        choice(
            name: 'action',
            choices: 'create\ndelete',
            description: 'Choose create/Destroy'
        )

        string(
            name: 'ImageName',
            description: 'Name of the Docker image',
            defaultValue: 'javapp'
        )

        string(
            name: 'ImageTag',
            description: 'Tag of the Docker image',
            defaultValue: 'v1'
        )

        string(
            name: 'DockerHubUser',
            description: 'DockerHub username',
            defaultValue: 'jhongreesham'
        )
    }

    stages {

        stage('Git Checkout') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/saicharan-clan/Java_app_3.0'
                )
            }
        }

        stage('Unit Test maven') {
            when {
                expression { params.action == 'create' }
            }
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
            when {
                expression { params.action == 'create' }
            }
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
            when {
                expression { params.action == 'create' }
            }
            steps {
                withEnv([
                    'JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64',
                    'PATH+JAVA=/usr/lib/jvm/java-21-openjdk-amd64/bin'
                ]) {
                    withSonarQubeEnv('SonarQube') {
                        sh 'java -version'
                        sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar'
                    }
                }
            }
        }

        stage('Quality Gate Status Check : Sonarqube') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Maven Build : maven') {
            when {
                expression { params.action == 'create' }
            }
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
            when {
                expression { params.action == 'create' }
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh """
                        docker build -t \$DOCKER_USERNAME/${params.ImageName}:${params.ImageTag} .
                    """
                }
            }
        }

        stage('Docker Image Scan: trivy') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh """
                        trivy image \$DOCKER_USERNAME/${params.ImageName}:${params.ImageTag}
                    """
                }
            }
        }

        stage('Docker Image Push : DockerHub') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh """
                        echo "\$DOCKER_PASSWORD" | docker login -u "\$DOCKER_USERNAME" --password-stdin
                        docker push "\$DOCKER_USERNAME/${params.ImageName}:${params.ImageTag}"
                    """
                }
            }
        }

        stage('Docker Image Cleanup : DockerHub') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh """
                        docker rmi \$DOCKER_USERNAME/${params.ImageName}:${params.ImageTag} || true
                    """
                }
            }
        }
    }
}
