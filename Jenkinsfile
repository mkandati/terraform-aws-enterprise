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
        TF_ROOT                 = 'infrastructure'
        TF_PLAN                 = "tfplan-${params.ENVIRONMENT}-build${env.BUILD_NUMBER}"
        AWS_ACCESS_KEY_ID       = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY   = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION        = 'true'
        AWS_DEFAULT_REGION      = 'ap-south-1'   // or your region
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        ansiColor('xterm')
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build Information') {
            steps {
                script {
                    currentBuild.displayName = "#${env.BUILD_NUMBER} ${params.ENVIRONMENT.toUpperCase()} - PLAN"
                    currentBuild.description = "Terraform validation for ${params.ENVIRONMENT}"
                    "Terraform validation for ${params.ENVIRONMENT}"
                }

                sh """
                echo "==============================================="
                echo " Terraform Enterprise Validation Pipeline"
                echo "==============================================="
                echo " Build Number : ${BUILD_NUMBER}"
                echo " Environment  : ${ENVIRONMENT}"
                echo " Repository   : terraform-aws-enterprise"
                echo " Job Name     : ${JOB_NAME}"
                echo " Workspace    : ${WORKSPACE}"
                echo "==============================================="
                """
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
                    echo "Generating Terraform execution plan..."
                        mkdir -p artifacts/plans
                        terraform plan \
                            -input=false \
                            -var-file=../environments/${ENVIRONMENT}/terraform.tfvars \
                            -out=${TF_PLAN}
                            cp ${TF_PLAN} artifacts/plans/
                    '''
                }
            }
        }

        stage('Archive Terraform Plan') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }

            steps {
                echo "Archiving Terraform execution plan..."
                archiveArtifacts(
                    artifacts: 'artifacts/plans/${TF_PLAN}',
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

            cleanWs(
                deleteDirs: true,
                disableDeferredWipeout: true
            )

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