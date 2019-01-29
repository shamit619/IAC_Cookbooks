node('master') {
    try {
        stage('clone') {
            checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/shamit619/Application.git']]])
        }
        stage('build and package') {
            sh "mvn clean package"
        }

        stage('docker build') {
            sh "docker build -t application:latest ."
        }

        stage('deploy') {
            sh "docker run -p 49160:8080 -d application:latest"
        }
    } catch(error) {
        throw error
    } finally {
        // Any cleanup operations needed, whether we hit an error or not
    }
}
