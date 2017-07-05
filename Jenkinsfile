node {
  def project = 'nmiu-play'
  def appName = 'kube-gc'
  def feSvcName = "${appName}"
  def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

  checkout scm

  stage 'Build image'
  sh("docker build -t ${imageTag} server")

  stage 'Push image to registry'
  sh("gcloud docker -- push ${imageTag}")

  stage "Deploy Application"
  switch (env.BRANCH_NAME) {
    // Roll out
    case ["master"]:
      // Change deployed image in canary to the one we just built
      sh("sed -i.bak 's#gcr.io/${project}/${appName}:0.0.1#${imageTag}#' ./k8s/ds.yaml")
      sh("kubectl apply -f k8s/ds.yaml")
      sh("kubectl delete pods -l name=${appName}")
      break

    // do nothing for the other branches
    default:
      echo "Do nothing for ${env.BRANCH_NAME}"
  }
}
