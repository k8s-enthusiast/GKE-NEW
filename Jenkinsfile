pipeline {
  agent {
   label "cicd-npe-slave0"
  }
  environment {
      no_proxy = 'googleapis.com'
  }
  stages {
    stage('Setup') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-equifax-prod', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        sh("git config --global credential.username $GIT_USERNAME ")
        sh("git config --global credential.helper '!f() { echo password=${GIT_PASSWORD}; }; f'")
        sh "git clone https://github.com/Equifax/7265_GL_GKE_IAAS.git"
        dir('examples/cluster') {
          sh "terraform version"
          sh "terraform init"
          sh "terraform validate"
          sh "terraform refresh"
        }
      }
    }
    }
    stage('execute') {
      steps {
        dir('examples/cluster') {
          sh "terraform plan"
          sh "terraform apply -auto-approve"
          sh "terraform destroy -auto-approve"
        }
      }
    }
  }
}