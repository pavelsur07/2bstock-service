pipeline {
    agent any
    options {
        timestamps()
    }
    environment {
        CI = true
        REGISTRY = credentials('REGISTRY')
        IMAGE_TAG = sh(
            returnStdout: true,
            script: "echo '${env.BUILD_TAG}' | sed 's/%2F/-/g'"
        ).trim()

    }
    stages {
        stage("Init") {
            steps {
                sh "make init"
            }
        }

        stage("Down") {
            steps {
                sh "make docker-down-clear"
            }
        }
        stage("Build") {
           steps {
               sh "make build"
           }
       }
       stage("Push") {
           steps {
               withCredentials([
                   usernamePassword(
                       credentialsId: 'DOCKER_HUB_AUTH',
                       usernameVariable: 'USER',
                       passwordVariable: 'PASSWORD'
                   )
               ]) {
                   sh 'docker login -u=$USER -p=$PASSWORD'
               }
                   sh "make push"
           }
       }
        stage("Deploy") {
            when {
                branch "master"
            }
            steps {
                withCredentials([
                    string(credentialsId: 'PROD_HOST', variable: 'HOST'),
                    string(credentialsId: 'PROD_PORT', variable: 'PORT'),
                    string(credentialsId: 'PROD_ACCOUNT_DB_PASSWORD', variable: 'ACCOUNT_DB_PASSWORD'),
                    string(credentialsId: 'PROD_ACCOUNT_REDIS_PASSWORD', variable: 'ACCOUNT_REDIS_PASSWORD'),
                    string(credentialsId: 'PROD_ACCOUNT_MAIL_PASSWORD', variable: 'ACCOUNT_MAIL_PASSWORD'),
                    string(credentialsId: 'PROD_ACCOUNT_SENTRY_DSN', variable: 'ACCOUNT_SENTRY_DSN'),
                    string(credentialsId: 'PROD_ACCOUNT_APP_SECRET', variable: 'ACCOUNT_APP_SECRET')
                ]) {
                    sshagent (credentials: ['PROD_AUTH']) {
                        sh "BUILD_NUMBER=${env.BUILD_NUMBER} make deploy"
                    }
                }
            }
        }
    }
    post {
        always {
            sh "make docker-down-clear || true"
            sh 'make deploy-clean || true'
            sh 'make deploy-clean-staging || true'
        }
        failure {
            emailext (
                subject: "FAIL Job ${env.JOB_NAME} ${env.BUILD_NUMBER}",
                body: "Check console output at: ${env.BUILD_URL}/console",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
