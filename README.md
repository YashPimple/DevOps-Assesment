# DevOps Assessment

This assessment involves deploying a simple web application with DynamoDB using Docker, Kubernetes, and ArgoCD. Follow the steps below to complete the tasks.

## Step 1: Docker

### Task
Build a Dockerfile for deploying a simple web application with DynamoDB enabled. The application and the database should run on different containers.

### Steps
1. Create a new Rails application or use an existing one.
2. Write a Dockerfile to containerize the Rails application.
   ```Dockerfile
   FROM ruby:3.1

   # Create directory for the app
   RUN mkdir /app
   WORKDIR /app

   # Copy Gemfile and Gemfile.lock
   COPY Gemfile Gemfile.lock ./

   # Install dependencies
   RUN apt-get update && apt-get install -y nodejs yarn
   RUN gem install bundler
   RUN bundle install

   # Copy the Rails application code
   COPY . .

   # Precompile assets
   RUN rake assets:precompile

   # Expose port
   EXPOSE 3000

   # Run Rails server
   CMD ["rails", "server", "-b", "0.0.0.0"]
3. Build Docker container for the Rails application and DynamoDB and push it on Docker-Hub
   
   ```docker build -t yashpimple22/railsapp:1.0 .```
   
   ```docker push yashpimple22/railsapp:1.0```

## Step 2: Kubernetes

### Task
#### Build a YAML file to deploy the application and DynamoDB on Kubernetes. Use a local cluster provider such as Minikube or K3d. Deploy the standalone DynamoDB pod using Kubernetes StatefulSet. You can choose an ingress controller or service mesh for networking.

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
