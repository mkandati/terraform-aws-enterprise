pipeline {

    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'test', 'prod'],
            description: 'Select deployment environment'
        )
    }

    environment {
        TF_ROOT          = 'infrastructure'
        TF_PLAN          = 'tfplan'
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION = 'true'
        AWS_DEFAULT_REGION = 'ap-south-1'   // or your region
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        ansiColor('xterm')
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Version') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Terraform Version"
                    echo "========================================"

                    terraform version

                    echo ""
                    echo "Current Workspace:"
                    pwd

                    echo ""
                    echo "Repository Contents:"
                    ls -la
                '''
            }
        }

        stage('Terraform Format Check') {
            steps {
                dir("${TF_ROOT}") {
                    sh '''
                        echo "Checking Terraform formatting..."
                        terraform fmt -check -recursive
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_ROOT}") {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_ROOT}") {
                    sh '''
                        echo "Validating Terraform configuration..."
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_ROOT}") {
                    sh '''
                    echo "===== Current Directory ====="
                    pwd
                    
                    echo "========Files========"
                    ls -la

                    echo "===== Terraform Files ====="
                    ls -la *.tf*

                    echo "===== tfvars ====="
                    cat terraform.tfvars
                    
                    echo ""
                    echo "===== Environment ====="
                    echo "TF_ROOT=$TF_ROOT"
                    echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
                    echo "AWS_ACCESS_KEY_ID is ${AWS_ACCESS_KEY_ID:+SET}"
                    echo "AWS_SECRET_ACCESS_KEY is ${AWS_SECRET_ACCESS_KEY:+SET}"
                    echo ""
                    
                        echo "Generating Terraform execution plan..."

                        terraform plan \
                            -input=false \
                            -var-file=../environments/${ENVIRONMENT}/terraform.tfvars \
                            -out=tfplan
                    '''
                }
            }
        }

        stage('Archive Terraform Plan') {
            steps {
                archiveArtifacts(
                    artifacts: 'infrastructure/tfplan',
                    fingerprint: true
                )
            }
        }

    }

    post {

        success {

            echo '''
========================================
Terraform Validation Pipeline Successful
========================================
'''

            cleanWs()

        }

        failure {

            echo '''
========================================
Terraform Validation Pipeline Failed
========================================
'''

        }

        always {

            echo "Build completed."

        }

    }

}