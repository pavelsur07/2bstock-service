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
        stage("Valid") {
            steps {
                sh "make account-validate-schema"
            }
        }
        stage("Lint") {
            steps {
                sh "make account-cs-fix"
            }
        }
//         stage("Analyze") {
//             steps {
//                  sh "make account-analyze"
//             }
//         }
//        stage("Test") {
//            steps {
//                sh "make account-test"
//            }
//        }
        stage("Down") {
            steps {
                sh "make docker-down-clear"
            }
        }
        stage("Build") {
            when {
                branch "master"
            }
            steps {
                sh "make build"
            }
        }
        stage("Push") {
            when {
                branch "master"
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'REGISTRY_AUTH',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASSWORD'
                    )
                ]) {
                    sh 'docker login -u=$USER -p=$PASSWORD'
                }
                    sh "make push"
            }
        }
        stage("Staging-build") {
            when {
                branch "staging"
            }
            steps {
                sh "make build"
            }
        }
        stage("Staging-push") {
            when {
                branch "staging"
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'REGISTRY_AUTH',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASSWORD'
                    )
                ]) {
                    sh 'docker login -u=$USER -p=$PASSWORD'
                }
                    sh "make push"
            }
        }
        stage("Staging-deploy") {
            when {
                branch "staging"
            }
            steps {
                withCredentials([
                    string(credentialsId: 'STAGING_HOST', variable: 'HOST'),
                    string(credentialsId: 'STAGING_PORT', variable: 'PORT'),
                    string(credentialsId: 'STAGING_ACCOUNT_DB_PASSWORD', variable: 'ACCOUNT_DB_PASSWORD'),
                    string(credentialsId: 'STAGING_ACCOUNT_REDIS_PASSWORD', variable: 'ACCOUNT_REDIS_PASSWORD'),
                    string(credentialsId: 'STAGING_ACCOUNT_APP_SECRET', variable: 'ACCOUNT_APP_SECRET'),
                    string(credentialsId: 'STAGING_ACCOUNT_SENTRY_DSN', variable: 'ACCOUNT_SENTRY_DSN'),
                    string(credentialsId: 'STAGING_ACCOUNT_MAIL_PASSWORD', variable: 'ACCOUNT_MAIL_PASSWORD'),
                    string(credentialsId: 'STAGING_ACCOUNT_STORAGE_FTP_PASSWORD', variable: 'STORAGE_FTP_PASSWORD'),
                ]) {
                    sshagent (credentials: ['STAGING_AUTH']) {
                        sh "BUILD_NUMBER=${env.BUILD_NUMBER} make deploy-staging"
                    }
                }
            }
        }
        stage("Prod-deploy") {
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
