pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        aws_default_region = "eu-central-1"
    }

    stages {
        stage("Run terraform plan") {
            steps {
                script {
                    dir('/vagrant/cloudresume/iac') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }

}
