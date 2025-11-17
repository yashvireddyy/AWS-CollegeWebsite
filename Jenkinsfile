pipeline {
    agent any

    environment {
        IMAGE_NAME = "yashvi/ecorise-website"
        ECR_REPO   = "207613818218.dkr.ecr.ap-south-1.amazonaws.com/html-website"
        REGION     = "ap-south-1"
        AWS_CLI    = "aws"
        TERRAFORM  = "terraform"
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo '📦 Cloning repository...'
                git branch: 'main', url: 'https://github.com/yashvireddyy/CICD_pipeline_website'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh """
                docker build -t ${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Push to AWS ECR') {
            steps {
                echo '🚀 Logging in and pushing image to AWS ECR...'
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-creds'
                ]]) {
                    sh """
                    ${AWS_CLI} ecr get-login-password --region ${REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REPO}

                    docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
                    docker push ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy Infrastructure with Terraform') {
            steps {
                echo '🏗️ Deploying Auto Scaling & Load Balancer using Terraform...'
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-creds'
                ]]) {
                    dir('terraform') {
                        sh """
                        ${TERRAFORM} init
                        ${TERRAFORM} plan -out=tfplan
                        ${TERRAFORM} apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Show Deployment Output') {
            steps {
                echo '🌐 Fetching ALB DNS name...'
                dir('terraform') {
                    sh """
                    ${TERRAFORM} output alb_dns_name
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Build or deployment failed. See logs.'
        }
    }
}
