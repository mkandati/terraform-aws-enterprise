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

        stage('Generate Build Metadata') {
            steps {
                dir("${TF_ROOT}") {
                sh '''
                mkdir -p artifacts/metadata
                mkdir -p artifacts/checksum

                echo "===================================" > artifacts/metadata/build-info.txt
                echo "Terraform Enterprise Build" >> artifacts/metadata/build-info.txt
                echo "===================================" >> artifacts/metadata/build-info.txt
                echo "Build Number : ${BUILD_NUMBER}" >> artifacts/metadata/build-info.txt
                echo "Job Name     : ${JOB_NAME}" >> artifacts/metadata/build-info.txt
                echo "Environment  : ${ENVIRONMENT}" >> artifacts/metadata/build-info.txt
                echo "Workspace    : ${WORKSPACE}" >> artifacts/metadata/build-info.txt
                echo "Build URL    : ${BUILD_URL}" >> artifacts/metadata/build-info.txt

                echo "Repository Information" > artifacts/metadata/git-info.txt
                echo "Branch    : $(git rev-parse --abbrev-ref HEAD)" >> artifacts/metadata/git-info.txt
                echo "Commit ID : $(git rev-parse HEAD)" >> artifacts/metadata/git-info.txt
                echo "Commit    : $(git log -1 --pretty=%s)" >> artifacts/metadata/git-info.txt
                echo "Author    : $(git log -1 --pretty=%an)" >> artifacts/metadata/git-info.txt

                terraform version > artifacts/metadata/terraform-version.txt

                echo "Environment : ${ENVIRONMENT}" > artifacts/metadata/environment.txt
                echo "Terraform Root : ${TF_ROOT}" >> artifacts/metadata/environment.txt
                echo "Plan File : ${TF_PLAN}" >> artifacts/metadata/environment.txt

                terraform show ${TF_PLAN} > artifacts/metadata/plan-summary.txt
                sha256sum ${TF_PLAN} > artifacts/checksum/SHA256SUM
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
                    echo "===== Artifact Structure ====="
                    #ls -R artifacts
                    find artifacts -type f
                    artifacts: 'infrastructure/artifacts/**',
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