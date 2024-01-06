# DevOps Assessment

This assessment involves deploying a simple web application with an Database using Docker, Kubernetes, and ArgoCD. Follow the steps below to complete the tasks.

## Step 1: Docker
### Task
Build a Dockerfile for deploying a simple web application with DynamoDB enabled. The application and the database should run on different containers.

### Steps
1. Create a new Rails application or use an existing one.
2. Write a Dockerfile to containerize the Rails application.
   ```Dockerfile
   FROM ruby:3.1
   RUN mkdir /app
   WORKDIR /app

   COPY Gemfile Gemfile.lock ./

   RUN apt-get update && apt-get install -y nodejs yarn
   RUN gem install bundler
   RUN bundle install

   COPY . .

   RUN rake assets:precompile

   EXPOSE 3000

   CMD ["rails", "server", "-b", "0.0.0.0"]
3. Build Docker container for the Rails application and DynamoDB and push it on Docker-Hub
   
   ```docker build -t yashpimple22/railsapp:1.0 .```
   
   ```docker push yashpimple22/railsapp:1.0```

## Step 2: Kubernetes

### Task
#### Build a YAML file to deploy the application and DynamoDB on Kubernetes. Use an EC2 instance to deploy the standalone DynamoDB pod using Kubernetes StatefulSet. You can choose an ingress controller or service mesh for networking.

```bash
Kubectl apply -f Manifests/deployment.yaml

Kubectl apply -f Manifests/Ingress.yaml
```

## Step 3: ArgoCD
### Task
#### Deploy ArgoCD to manage the deployment of the application using GitOps. Create a private GitHub repository to manage the YAML files and for GitOps purposes. All ArgoCD config files must be present in the GitHub repository. Required files include application.yaml, argocd-cm, argocd-rbac-cm, a config file for the private GitHub repository, and Kubernetes manifest files.

ArgoCD can be installed using the following commands:

- To create a namespace "argocd", execute the following command. However, this step is optional and you can proceed with the "default" namespace as well:<br>
`kubectl create namespace argocd`

- Run the install ArgoCD script by executing the following command: <br>
`kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

- Install the CLI using brew to use argocd commands: <br>
`brew install argocd`

- To retrieve the password, execute the following command: <br>
`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`

- To access ArgoCD on a browser, forward the port to 8080 by executing the following command: <br>
`kubectl port-forward svc/argocd-server -n argocd 8080:443`

- Deployment the YAML configuration
  - create `argoproject.yaml` which will have our argo-cd configuration

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rails-app
  namespace: argocd  
spec:
  destination:
    name: default
    namespace: ruby-rails   
    server: https://kubernetes.default.svc 
  project: default
  source:
    repoURL: 'https://github.com/YashPimple/Ruby_on_rails.git'  
    path: "Manifests"  
    targetRevision: HEAD 
  syncPolicy:
    automated:
      prune: true  # Remove resources not defined in Git
      selfHeal: true  # Automatically recover from sync failures
```

## Step 4 (Optional → Added Advantage): Tekton

### Task
Set up Tekton pipelines and the Tekton dashboard. The pipeline should download the source code from the public fork of the sample project (Which you’ve containerized in the first step), build the image, and push it to Docker Hub. The candidate is expected to manually run the pipeline from the Tekton dashboard.

### Steps
1. Install and configure Tekton on your Kubernetes cluster.
2. Create Tekton Tasks ([clone-and-build-task.yaml](https://github.com/YashPimple/Ruby_on_rails/blob/main/Tekton/clone-and-build-task.yaml)) for building the application image.
3. Define a Tekton Pipeline ([build-pipeline.yaml](https://github.com/YashPimple/Ruby_on_rails/blob/main/Tekton/build-pipeline.yaml)) that includes the Task.
4. Create a PipelineRun ([build-pipeline-run.yaml](https://github.com/YashPimple/Ruby_on_rails/blob/main/Tekton/build-pipeline-run.yaml)) to trigger the pipeline.
5. Access the Tekton dashboard and manually run the pipeline.
6. Verify that the source code is downloaded, the image is built, and it is pushed to Docker Hub.

## Working

```bash
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```


