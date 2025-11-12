pipeline {
    agent any

    environment {
        IMAGE_NAME = "yashvi/ecorise-website"
        ECR_REPO   = "207613818218.dkr.ecr.ap-south-1.amazonaws.com/html-website"
        REGION     = "ap-south-1"
        AWS_CLI    = "C:\\Program Files\\Amazon\\AWSCLIV2\\aws.exe"
        TERRAFORM  = "C:\\Terraform\\terraform.exe"
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
                bat """
                docker build -t ${env.IMAGE_NAME}:latest .
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
                    bat """
                    "${env.AWS_CLI}" ecr get-login-password --region ${env.REGION} | docker login --username AWS --password-stdin ${env.ECR_REPO}
                    docker tag ${env.IMAGE_NAME}:latest ${env.ECR_REPO}:latest
                    docker push ${env.ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy Infrastructure with Terraform') {
            steps {
                echo '🏗️ Deploying Auto Scaling and Load Balancer via Terraform...'
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-creds'
                ]]) {
                    dir('terraform') {  // ✅ Ensure your .tf files are in a 'terraform' folder (or remove this block if not)
                        bat """
                        "${env.TERRAFORM}" init
                        "${env.TERRAFORM}" plan -out=tfplan
                        "${env.TERRAFORM}" apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Show Deployment Output') {
            steps {
                echo '🌐 Fetching deployed ALB DNS...'
                dir('terraform') {
                    bat """
                    "${env.TERRAFORM}" output alb_dns_name
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build, push, and Terraform deployment completed successfully!'
            echo '🎉 Your website is now live on AWS via Load Balancer (Auto Scaled).'
        }
        failure {
            echo '❌ Build or deployment failed. Please check the Jenkins logs.'
        }
    }
}
