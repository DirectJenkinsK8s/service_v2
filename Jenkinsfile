// void setBuildStatus(String message, String context, String state) {
//   // add a Github access token as a global 'secret text' credential on Jenkins with the id 'github-commit-status-token'
//     withCredentials([string(credentialsId: 'github-commit-status-token', variable: 'TOKEN')]) {
//       // 'set -x' for debugging. Don't worry the access token won't be actually logged
//       // Also, the sh command actually executed is not properly logged, it will be further escaped when written to the log
//         sh """
//             set -x
//             curl \"https://api.github.com/repos/org/repo/statuses/$GIT_COMMIT?access_token=$TOKEN\" \
//                 -H \"Content-Type: application/json\" \
//                 -X POST \
//                 -d \"{\\\"description\\\": \\\"$message\\\", \\\"state\\\": \\\"$state\\\", \\\"context\\\": \\\"$context\\\", \\\"target_url\\\": \\\"$BUILD_URL\\\"}\"
//         """
//     }
// }

pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: python
                    image: python
                    command:
                    - sleep
                    args:
                    - infinity
                '''
            defaultContainer 'python'
        }
    }
    stages {
        stage ("Code pull") {
            steps{
                checkout scm
            }
        }

        stage('Build environment') {
            steps {
                echo "Building virtualenv"
                sh  ' make virtualenv'
            }
        }

        stage('Run Tests') {
            steps {
                echo "Running tests"
                sh ' venv/bin/pylint --output-format=parseable --fail-under=<threshold value> module --msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" >> pylint.log'
                echo "linting Success, Generating Report"
                recordIssues enabledForFailure: true, aggregatingResults: true, tool: pyLint(pattern: 'pylint.log')
            }
        }
    }
}



// pipeline {
//     agent any
//
//     stages {
//
//         stage ("Code pull"){
//             steps{
//                 checkout scm
//             }
//         }
//
//         stage('Build environment') {
//             steps {
//                 echo "Building virtualenv"
//                 sh  ''' conda create --yes -n ${BUILD_TAG} python
//                         source activate ${BUILD_TAG}
//                         pip install -r requirements/dev.txt
//                     '''
//             }
//         }
//
//         stage('Static code metrics') {
//             steps {
//                 echo "Raw metrics"
//                 sh  ''' source activate ${BUILD_TAG}
//                         radon raw --json irisvmpy > raw_report.json
//                         radon cc --json irisvmpy > cc_report.json
//                         radon mi --json irisvmpy > mi_report.json
//                         sloccount --duplicates --wide irisvmpy > sloccount.sc
//                     '''
//                 echo "Test coverage"
//                 sh  ''' source activate ${BUILD_TAG}
//                         coverage run irisvmpy/iris.py 1 1 2 3
//                         python -m coverage xml -o reports/coverage.xml
//                     '''
//                 echo "Style check"
//                 sh  ''' source activate ${BUILD_TAG}
//                         pylint irisvmpy || true
//                     '''
//             }
//             post{
//                 always{
//                     step([$class: 'CoberturaPublisher',
//                                    autoUpdateHealth: false,
//                                    autoUpdateStability: false,
//                                    coberturaReportFile: 'reports/coverage.xml',
//                                    failNoReports: false,
//                                    failUnhealthy: false,
//                                    failUnstable: false,
//                                    maxNumberOfBuilds: 10,
//                                    onlyStable: false,
//                                    sourceEncoding: 'ASCII',
//                                    zoomCoverageChart: false])
//                 }
//             }
//         }
//
//
//
//         stage('Unit tests') {
//             steps {
//                 sh  ''' source activate ${BUILD_TAG}
//                         python -m pytest --verbose --junit-xml reports/unit_tests.xml
//                     '''
//             }
//             post {
//                 always {
//                     // Archive unit tests for the future
//                     junit allowEmptyResults: true, testResults: 'reports/unit_tests.xml'
//                 }
//             }
//         }
//
//         stage('Acceptance tests') {
//             steps {
//                 sh  ''' source activate ${BUILD_TAG}
//                         behave -f=formatters.cucumber_json:PrettyCucumberJSONFormatter -o ./reports/acceptance.json || true
//                     '''
//             }
//             post {
//                 always {
//                     cucumber (buildStatus: 'SUCCESS',
//                     fileIncludePattern: '**/*.json',
//                     jsonReportDirectory: './reports/',
//                     parallelTesting: true,
//                     sortingMethod: 'ALPHABETICAL')
//                 }
//             }
//         }
//
//         stage('Build package') {
//             when {
//                 expression {
//                     currentBuild.result == null || currentBuild.result == 'SUCCESS'
//                 }
//             }
//             steps {
//                 sh  ''' source activate ${BUILD_TAG}
//                         python setup.py bdist_wheel
//                     '''
//             }
//             post {
//                 always {
//                     // Archive unit tests for the future
//                     archiveArtifacts allowEmptyArchive: true, artifacts: 'dist/*whl', fingerprint: true
//                 }
//             }
//         }
//
//         // stage("Deploy to PyPI") {
//         //     steps {
//         //         sh """twine upload dist/*
//         //         """
//         //     }
//         // }
//     }
//
//     post {
//         always {
//             sh 'conda remove --yes -n ${BUILD_TAG} --all'
//         }
//         failure {
//             emailext (
//                 subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
//                 body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
//                          <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
//                 recipientProviders: [[$class: 'DevelopersRecipientProvider']])
//         }
//     }
// }
