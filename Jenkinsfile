node {
  def project = 'nmiu-play'
  def appName = 'kube-gc'
  def feSvcName = "${appName}"
  def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

  checkout scm

  stage 'Build image'
  sh("docker build -t ${imageTag} docker")

  stage 'Push image to registry'
  sh("gcloud docker -- push ${imageTag}")

  stage "Deploy Application"
  switch (env.BRANCH_NAME) {
    // Roll out the pods
    case ["master"]:
      sh("sed -i.bak 's#gcr.io/${project}/${appName}:0.0.1#${imageTag}#' ./k8s/ds.yaml")
      sh("kubectl apply -f k8s/ds.yaml")
      sh("kubectl delete pods -l name=${appName}")
      break

    // Do not deploy this for any other branches
    default:
      echo "Not deploying for ${env.BRANCH_NAME}"
  }
}
