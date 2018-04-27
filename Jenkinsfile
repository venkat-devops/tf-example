pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.11.7"
    }
    environment {
        TF_HOME = tool('terraform-0.11.7')
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
                    sh "terraform init -input=false \
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
                        sh "terraform init -input=false \
                        --backend-config='dynamodb_table=$DYNAMODB_STATELOCK' --backend-config='bucket=$REMOTESTATE_BUCKET' \
                        --backend-config='access_key=$CICD_ACCESS_KEY' --backend-config='secret_key=$CICD_SECRET_KEY'"
                        sh "terraform plan -var 'aws_access_key=$CICD_ACCESS_KEY' -var 'aws_secret_key=$CICD_SECRET_KEY' \
                        -out terraform.tfplan; echo \$? > status"
                        stash name: "terraform-plan", includes: "terraform.tfplan"
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
                            unstash "terraform-plan"
                            sh 'terraform apply terraform.tfplan'
                            sh "echo Hello World!!!"
                        }
                }
            }
        }
    }
}
