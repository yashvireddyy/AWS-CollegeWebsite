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

                // Using simple Jenkins credentials instead of AWS plugin
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {

                    sh """
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region ${REGION}

                    aws ecr get-login-password --region ${REGION} | \
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

                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {

                    dir('Terraform') {   // <-- Correct folder name

                        sh """
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region ${REGION}

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
                dir('Terraform') {    // <-- Correct folder
                    sh """
                    terraform output alb_dns_name
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed successfully!'
            echo '🎉 Website deployed on AWS using Jenkins + Docker + Terraform!'
        }
        failure {
            echo '❌ Build or deployment failed. Please check the console logs.'
        }
    }
}
