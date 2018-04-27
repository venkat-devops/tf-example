pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.11.7"
    }
    parameters {
    string(name: 'WORKSPACE', defaultValue: 'development', description:'worspace to use in Terraform')
    }
    environment {
        TF_HOME = tool('terraform-0.11.7')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
        DYNAMODB_STATELOCK = "tf-statelock"
        REMOTESTATE_BUCKET = "networking-tfstate-venkatp"
        CICD_ACCESS_KEY = credentials('cicd_access_key')
        CICD_SECRET_KEY = credentials('cicd_secret_key')
    }
    stages {
        stage('TfInit'){
            steps {
                    sh 'terraform --version'
                    sh 'terraform providers'
                    sh "terraform init -input=false -get-plugins=false -plugin-dir=/var/jenkins_home/terraform_plugins \
                     --backend-config='dynamodb_table=$DYNAMODB_STATELOCK' --backend-config='bucket=$REMOTESTATE_BUCKET' \
                     --backend-config='access_key=$CICD_ACCESS_KEY' --backend-config='secret_key=$CICD_SECRET_KEY'"
                    sh "echo \$PWD"
                    sh "whoami"
                }
        }
        stage('TfPlan'){
            steps {
                    script {
                        sh "echo \$PWD"
                        sh "whoami"
                        try {
                           sh "terraform workspace new ${params.WORKSPACE}"
                        } catch (err) {
                            sh "terraform workspace select ${params.WORKSPACE}"
                        }
                        sh "terraform plan -var 'aws_access_key=$CICD_ACCESS_KEY' -var 'aws_secret_key=$CICD_SECRET_KEY' \
                         -out terraform.tfplan; echo \$? > status"
                        stash name: "terraform-plan", includes: "terraform.tfplan"
                        sh 'terraform --version'
                        sh 'terraform providers'
                        // sh "terraform init -input=false \
                        // --backend-config='dynamodb_table=$DYNAMODB_STATELOCK' --backend-config='bucket=$REMOTESTATE_BUCKET' \
                        // --backend-config='access_key=$CICD_ACCESS_KEY' --backend-config='secret_key=$CICD_SECRET_KEY'"
                        sh "echo \$PWD"
                        sh "whoami"
                    }
            }
        }
        stage('TfApply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'confirm apply', ok: 'Apply Config'
                        apply = true
                    } catch (err) {
                        apply = false
                        sh "terraform destroy -var 'aws_access_key=$CICD_ACCESS_KEY' -var 'aws_secret_key=$CICD_SECRET_KEY' -force"
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('/'){
                            unstash "terraform-plan"
                            sh 'terraform apply terraform.tfplan'
                        }
                    }
                }
            }
        }
    }
}
