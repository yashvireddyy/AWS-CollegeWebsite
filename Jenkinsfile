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
                bat 'docker build -t %IMAGE_NAME%:latest .'
            }
        }

        stage('Push to AWS ECR') {
            steps {
                echo '🚀 Pushing image to AWS ECR...'
                withCredentials([usernamePassword(credentialsId: 'aws-ecr-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    bat """
                    set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                    set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                    "%AWS_CLI%" ecr get-login-password --region %REGION% | docker login --username AWS --password-stdin %ECR_REPO%
                    docker tag %IMAGE_NAME%:latest %ECR_REPO%:latest
                    docker push %ECR_REPO%:latest
                    """
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                echo '🏗️ Deploying EC2 instance and running Docker container...'
                // Use AWS plugin credentials here
                withAWS(credentials: '207613818218', region: '%REGION%') {
                    dir('terraform') {
                        bat """
                        "%TERRAFORM%" init
                        "%TERRAFORM%" apply -auto-approve
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Docker image pushed, EC2 deployed, and website is running!'
            echo '🎉 Open the site in your browser using the EC2 Public IP or DNS.'
        }
        failure {
            echo '❌ Build or deployment failed!'
        }
    }
}
