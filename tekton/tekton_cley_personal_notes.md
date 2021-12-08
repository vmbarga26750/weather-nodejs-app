# Tekton

[tekton](https://tekton.dev)

Tekton is an open-source cloud native CI/CD (Continuous Integration and Delivery/Deployment) solution. It allows developers to build, test, and deploy across destinations using a Kubernetes cluster of their own.

## Tekton terminology

Tekton uses the YAML syntax for declarative pipelines and consists of tasks. Some basic terms in Tekton are as follows:

- Pipeline: A set of tasks in a series, in parallel, or both.

- Task: A sequence of steps as commands, binaries, or scripts.

- PipelineRun: Execution of a pipeline with one or more tasks.

- TaskRun: Execution of a task with one or more steps.

- Workspace: In Tekton, workspaces are conceptual blocks that serve the following purposes:

	- Storage of inputs, outputs, and build artifacts.
	- Common space to share data among tasks.
	- Mount points for credentials held in secrets, configurations held in config maps, and common tools shared by an organization.


## Install tektoncd-cli from brew (tkn)

	> brew install tektoncd-cli

## Operate

### RUN tkn task

	> tkn task start <TASK>

### STATUS : Get logs from task

	> tkn taskrun logs -f <TASK>
	
### K8s resources

* task
* taskRun
* pipeline
* pipelineRun


## Tekton hub

[https://hub.tekton.dev/](https://hub.tekton.dev/)

Discover, search and share reusable Tasks and Pipelines

## Tekton catalog

[https://github.com/tektoncd/catalog](https://github.com/tektoncd/catalog)

Catalog of Task resources (and someday Pipelines and Resources), which are designed to be reusable in many pipelines.

## TASK

A task is a collection of steps in order. Tekton runs a task in the form of a Kubernetes pod, where each step becomes a running container in the pod. This design allows you to set up a shared environment for a number of related steps; for example, you may mount a Kubernetes volume in a task, which will be accessible inside each step of the task.


### Search task

	> tkn hub search <TASK>

Example, search task for github

	> tkn hub search github
	NAME                                    KIND   CATALOG   DESCRIPTION                                  TAGS
	create-github-release (0.1)             Task   Tekton    This `task` can be used to make a githu...   github
	github-add-comment (0.4)                Task   Tekton    This Task will add a comment to a pull ...   github
	github-add-gist (0.1)                   Task   Tekton    This task will uploaded the provided fi...   github
	github-add-labels (0.1)                 Task   Tekton    This Task will add a label to an issue ...   github
	github-app-token (0.2)                  Task   Tekton    Retrieve a user token from a GitHub app...   github
	github-close-issue (0.2)                Task   Tekton    This Task will close a pull request or ...   github
	github-create-deployment (0.2)          Task   Tekton    This Task will create a GitHub deployme...   github
	github-create-deployment-status (0.1)   Task   Tekton    This Task will create a status for a Gi...   github
	github-open-pr (0.1)                    Task   Tekton    This task will open a PR on Github base...   github
	github-request-reviewers (0.1)          Task   Tekton    This Task will request reviewers for a ...   github
	github-set-status (0.2)                 Task   Tekton    This task will set the status of the CI...   github
	
### Install task

Task will be installed in the current ns/project

	> tkn hub install task <TASK>
	
#### Install specific task version

	> tkn hub install task <TASK> --version <VERSION>

Example 

	> tkn hub install task ygithub-add-comment --version 0.2

## ClusterTask

Task qui peuvent etre partagé au autres namespaces/projects.
Déployé au niveau du Cluster.

Déclarer en tant que resource type:

kind: ClusterTask

## Task vs. ClusterTask

A ClusterTask is a Task scoped to the entire cluster instead of a single namespace. 

A ClusterTask behaves identically to a Task and therefore everything in this document applies to both.

> Note: When using a ClusterTask, you must explicitly set the kind sub-field in the taskRef field to ClusterTask. If not specified, the kind sub-field defaults to Task.
	
## Task vs TaskRun

A task describes how work is to be done, but creating the task resource does not result in any action being taken. 

A task run resource references the task, and the creation of a task run resource triggers Tekton to execute the steps in the referenced task.

A TaskRun allows you to instantiate and execute a Task on-cluster. A Task specifies one or more Steps that execute container images and each container image performs a specific piece of build work. A TaskRun executes the Steps in the Task in the order they are specified until all Steps have executed successfully or a failure occurs.

## Task vs TaskRun vs Pipeline vs PipelineRun

`Task` and `Pipeline` are the template, Pipeline is for multiple Task combination.

`Taskrun` and `Pipelinerun` are one time execution for Task and Pipeline, and they will supply some runtime parameters.

So, that's means when you create Task or Pipeline, just a CR created, no pod, no container until a Pipelinerun or Taskrun which refer to them were created.


## TASKRUN

### STATUS : Get logs from taskrun

	> tkn taskrun logs -f <TASKRUN>

Example: **logs from taskrun curl**

	> oc get taskrun curl
	NAME   SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
	curl   True        Succeeded   171m        171m

	> tkn taskrun logs curl
	[curl]   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
	[curl]                                  Dload  Upload   Total   Spent    Left  Speed
	  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
	[curl] <html>
	[curl]   <head>
	[curl]     <meta charset="UTF-8">
	[curl]     <title>Postman</title>
	[curl]
	[curl]     <!-- New Relic Integration -->
	[curl]     <script type="text/javascript" nonce="DJWhEQRxdM1JCrP1egAxq3O3Nclrc6Rx6T+PcXrTj1QiQROU">
	[curl]       ;window.NREUM||(NREUM={});NREUM.init={privacy:{cookies_enabled:false}};


## Pipeline


[tekton pipeline](https://tekton.dev/docs/pipelines/pipelines/)



	apiVersion: tekton.dev/v1beta1
	kind: Pipeline
	metadata:
	  name: pipeline-with-parameters
	spec:
	  params:
	    - name: context
	      type: string
	      description: Path to context
	      default: /some/where/or/other
	    - name: flags
	      type: array
	      description: List of flags
	  tasks:
	    - name: build-skaffold-web
	      taskRef:
	        name: build-push
	      params:
	        - name: pathToDockerFile
	          value: Dockerfile
	        - name: pathToContext
	          value: "$(params.context)"
	        - name: flags
	          value: ["$(params.flags[*])"]


Example:

	apiVersion: tekton.dev/v1beta1
	kind: Pipeline
	metadata:
	  name: nodejs
	spec:
	  params:
	  - description: Source code repository
	    name: source-repo
	    type: string
	  tasks:
	  - name: clone-repository
	    params:
	    - name: url
	      value: $(params.source-repo)
	    taskRef:
	      kind: ClusterTask
	      name: git-clone
	    workspaces:
	    - name: output
	      workspace: pipeline-shared-data
	  - name: run-tests
	    params:
	    - name: ARGS
	      value:
	      - install-ci-test
	    runAfter:
	    - clone-repository
	    taskRef:
	      kind: Task
	      name: npm
	    workspaces:
	    - name: source
	      workspace: pipeline-shared-data
	  - name: create-image
	    params:
	    - name: IMAGE
	      value: quay.io/davidbieder/express-sample-app:1
	    runAfter:
	    - run-tests
	    taskRef:
	      kind: ClusterTask
	      name: buildah
	    workspaces:
	    - name: source
	      workspace: pipeline-shared-data
	  workspaces:
	  - name: pipeline-shared-data



## PipelineRun

[tekton PipelineRun](https://tekton.dev/docs/pipelines/pipelineruns/)

	apiVersion: tekton.dev/v1beta1
	kind: PipelineRun
	metadata:
	  generateName: express-sample-app-
	spec:
	  params:
	  - name: source-repo
	    value: https://github.com/davidbieder/express-sample-app
	  pipelineRef:
	    name: nodejs
	  serviceAccountName: build-bot
	  workspaces:
	  - name: pipeline-shared-data
	    volumeClaimTemplate:
	      metadata:
	        creationTimestamp: null
	      spec:
	        accessModes:
	        - ReadWriteOnce
	        resources:
	          requests:
	            storage: 1Gi


![bootcamp](img/tekton_pipeline_pipelineRun.png)




All steps on a task run in the same pod.

All task in pipelineRun run in different pods.

When a PVC is called from a pipelineRuns, if we delete the Pipeline it will release also the storage (pvc)

	workspaces:
	  - name: myworkspace # must match workspace name in Task
	    persistentVolumeClaim:
	      claimName: mypvc # this PVC must already exist
	    subPath: my-subdir
	    

## Task vs TaskRun vs Pipeline vs PipelineRun

`Task` and `Pipeline` are the template, Pipeline is for multiple Task combination.

`Taskrun` and `Pipelinerun` are one time execution for Task and Pipeline, and they will supply some runtime parameters.

So, that's means when you create Task or Pipeline, just a CR created, no pod, no container until a Pipelinerun or Taskrun which refer to them were created.

## YAML

[examples yaml](tekton/yaml)

## Task YAML

	apiVersion: tekton.dev/v1beta1
	kind: Task
	metadata:
	  name: wget
	spec:
	  description: This task uses wget to download files from the internet to a workspace.
	  params:
	  - default: ""
	    description: The url we want to download file from
	    name: url
	    type: string
	  - default: []
	    description: The directory path we want to save file to
	    name: diroptions
	    type: array
	  - default: []
	    description: The arguments to pass to wget
	    name: options
	    type: array
	  - default: ""
	    description: The filename we want to change our file to
	    name: filename
	    type: string
	  - default: docker.io/library/buildpack-deps:stable-curl@sha256:c8b03ed105baa8ff8202d49cc135c5f3cf54b48601678d0b39fd69768d3dccca
	    description: The wget docker image to be used
	    name: wget-option
	    type: string
	  steps:
	  - args:
	    - $(params.options[*])
	    - $(params.url)
	    - $(params.diroptions[*])
	    - $(workspaces.wget-workspace.path)/$(params.filename)
	    command:
	    - wget
	    image: $(params.wget-option)
	    name: wget
	    resources: {}
	  workspaces:
	  - description: The folder where we write the wget'ed file to
	    name: wget-workspace


## TaskRun YAML

	apiVersion: tekton.dev/v1beta1
	kind: TaskRun
	metadata:
	  generateName: wget-taskrun-
	spec:
	  params:
	  - name: url
	    value: www.google.com
	  - name: diroptions
	    value:
	    - -P
	  taskRef:
	    kind: Task
	    name: wget
	  workspaces:
	  - emptyDir: {}
	    name: wget-workspace
	    
## Pipeline YAML

	apiVersion: tekton.dev/v1beta1
	kind: Pipeline
	metadata:
	  name: nodejs
	spec:
	  params:
	  - description: Source code repository
	    name: source-repo
	    type: string
	  tasks:
	  - name: clone-repository
	    params:
	    - name: url
	      value: $(params.source-repo)
	    taskRef:
	      kind: ClusterTask
	      name: git-clone
	    workspaces:
	    - name: output
	      workspace: pipeline-shared-data
	  - name: run-tests
	    params:
	    - name: ARGS
	      value:
	      - install-ci-test
	    runAfter:
	    - clone-repository
	    taskRef:
	      kind: Task
	      name: npm
	    workspaces:
	    - name: source
	      workspace: pipeline-shared-data
	  - name: create-image
	    params:
	    - name: IMAGE
	      value: quay.io/davidbieder/express-sample-app:1
	    runAfter:
	    - run-tests
	    taskRef:
	      kind: ClusterTask
	      name: buildah
	    workspaces:
	    - name: source
	      workspace: pipeline-shared-data
	  workspaces:
	  - name: pipeline-shared-data

## PipelineRun YAML

	apiVersion: tekton.dev/v1beta1
	kind: PipelineRun
	metadata:
	  generateName: express-sample-app-
	spec:
	  params:
	  - name: source-repo
	    value: https://github.com/davidbieder/express-sample-app
	  pipelineRef:
	    name: nodejs
	  serviceAccountName: build-bot
	  workspaces:
	  - name: pipeline-shared-data
	    volumeClaimTemplate:
	      metadata:
	        creationTimestamp: null
	      spec:
	        accessModes:
	        - ReadWriteOnce
	        resources:
	          requests:
	            storage: 1Gi
	            

## Pipeline/PipelineRun to Git Clone private registry

[https://redhat-scholars.github.io/tekton-tutorial/tekton-tutorial/private_reg_repos.html](https://redhat-scholars.github.io/tekton-tutorial/tekton-tutorial/private_reg_repos.html)

[https://github.com/tektoncd/pipeline/blob/main/docs/auth.md#basic-authentication-git](https://github.com/tektoncd/pipeline/blob/main/docs/auth.md#basic-authentication-git)

[https://github.com/tektoncd/pipeline/issues/1983](https://github.com/tektoncd/pipeline/issues/1983)

**The way to use secret in tekton is a bit different than usual, see [auth.md](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-git)**

* Your secret need to be annotated with tekton.dev/git-0: https://github.my-company.com
* You need to add that secret to a serviceaccount
* You need to run you Task or Pipeline with that serviceAccount (using serviceAccountName)


1. Create Personal Access Token in GitHub (PAT)
2. Create Secret in k8s with GitHub User + GitHub PAT + annotate "tekton.dev/git-0=https://github.com"

_secret.yaml_

	apiVersion: v1
	kind: Secret
	metadata:
	  name: github-pat
	  annotations:
	    tekton.dev/git-0: https://github.com
	type: kubernetes.io/basic-auth
	stringData:
	  username: <USER>
	  password: <GITHUB_PAT>

> oc annotate secret github-pat "tekton.dev/git-0=https://github.com"

3. Create ServiceAccount to use in the pipelinerun 

_serviceaccount.yaml_

	apiVersion: v1
	imagePullSecrets:
	- name: github-bot-dockercfg-sckdc
	kind: ServiceAccount
	metadata:
	  creationTimestamp: "2021-09-30T20:08:34Z"
	  name: github-bot
	  namespace: christopher-ley-pipeline-assignment
	  resourceVersion: "5704965"
	  selfLink: /api/v1/namespaces/christopher-ley-pipeline-assignment/serviceaccounts/github-bot
	  uid: 7e32a1df-7359-4ba2-9075-27eb4dd9ce33
	secrets:
	- name: github-pat
	- name: github-bot-token-cjc8h
	- name: github-bot-dockercfg-sckdc


4. Patch ServiceAccount with github personal account secret previously created

		> oc patch serviceaccount github-bot -p '{"secrets": [{"name": "github-pat"}]}'


5. Deploy pipeline and pipelinerun

_pipeline.yaml_

	apiVersion: tekton.dev/v1beta1
	kind: Pipeline
	metadata:
	  name: secret-yaml-lint
	spec:
	  description: >-
	    The pipeline to clone from private GitHub repo and list the directory
	  params:
	    - name: private-source-repo
	      description: The private GitHub Repo
	    - name: github-repo-revision
	      description: The GitHub revision to use
	      default: main
	  workspaces:
	    - name: p3-secret-shared-data
	  tasks:
	    - name: clone-sources
	      taskRef:
	        kind: ClusterTask
	        name: git-clone
	      params:
	        - name: url
	          value: $(params.private-source-repo)
	        - name: revision
	          value: $(params.github-repo-revision)
	        - name: deleteExisting
	          value: 'true'
	      workspaces:
	        - name: output
	          workspace: p3-secret-shared-data
	    - name: yaml-lint-run
	      params:
	      - name: args
	        value:
	        - .
	      runAfter:
	      - clone-sources
	      taskRef:
	        kind: Task
	        name: yaml-lint
	      workspaces:
	      - name: shared-workspace
	        workspace: p3-secret-shared-data

_pipelinerun.yaml_

	apiVersion: tekton.dev/v1beta1
	kind: PipelineRun
	metadata:
	  generateName: secret-yaml-lint-
	spec:
	  serviceAccountName: github-bot
	  params:
	  - name: private-source-repo
	    value: https://github.com/cloud-native-garage-method-cohort/tekton-pipeline-yaml-christopher-ley-private.git
	  - name: github-repo-revision
	    value: main
	  pipelineRef:
	    name: secret-yaml-lint
	  workspaces:
	  - name: p3-secret-shared-data
	    volumeClaimTemplate:
	      metadata:
	        creationTimestamp: null
	      spec:
	        accessModes:
	        - ReadWriteOnce
	        resources:
	          requests:
	            storage: 1Gi


## Diagrams 

![tekton k8s](img/tekton_workflow-tekton_kind_in_K8s.jpg)
![tekton runtime](img/tekton_workflow-tekton_runtime.jpg)

## CI Sequence

![CI Sequence](img/ci-sequence.png)

## CI/CD From Dev to Prod

![CI/CD Sequence](img/cicd-from-dev-to-prod-no-cd.png)


## Jenkins VS Tekton

[Jenkins vs Tekton](https://docs.openshift.com/container-platform/4.8/cicd/jenkins-tekton/migrating-from-jenkins-to-tekton.html)

## Tekton Pipeline Build - Build Triggers

[https://github.com/cloud-native-garage-method-cohort/emea-6-ci-cd-from-first-principles/blob/main/tekton/pipeline-build-05-triggers.md](https://github.com/cloud-native-garage-method-cohort/emea-6-ci-cd-from-first-principles/blob/main/tekton/pipeline-build-05-triggers.md)


[https://www.arthurkoziel.com/tutorial-tekton-triggers-with-github-integration/](https://www.arthurkoziel.com/tutorial-tekton-triggers-with-github-integration/)


## Kustomize 

Kustomize is a tool for customizing Kubernetes YAML configuration files.

Example: edit deployment with kustomization

	> tree k8s
	k8s
	├── deployment.yaml
	├── kustomization.yaml
	├── route.yaml
	└── service.yaml

oc apply -f <folder_with_kustomization.yaml>

kustomization.yaml

	apiVersion: kustomize.config.k8s.io/v1beta1
	kind: Kustomization
	resources:
	- deployment.yaml
	- service.yaml
	- route.yaml
	images:
	- name: quay.io/upslopeio/express-sample-app
	  newName: quay.io/chrisley7506/express-app-alex-chris
	  newTag: 6da70b4345ec2d92adbfdb775160056c5143f789
	commonLabels:
	  app: express-app
	  app.kubernetes.io/instance: express-app
	  app.kubernetes.io/name: express-app


deployment.yaml

	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: express-sample-app
	spec:
	  replicas: 1
	  selector:
	    matchLabels:
	      app.kubernetes.io/instance: app-instance
	      app.kubernetes.io/name: app
	  template:
	    metadata:
	      labels: # THIS LABELS MUST MATCH WITH SPEC -> SELECTOR LABELS
	        app.kubernetes.io/instance: app-instance
	        app.kubernetes.io/name: app
	    spec:
	      restartPolicy: Always
	      terminationGracePeriodSeconds: 30
	      dnsPolicy: ClusterFirst
	      schedulerName: default-scheduler
	      containers:
	      - name: express-sample-app
	        image: quay.io/upslopeio/express-sample-app:d90c742ee626048c4d1e2032eb836255e4036561
	        ports:
	        - name: http
	          protocol: TCP
	          containerPort: 3000
	        env:
	        - name: INGRESS_HOST
	        - name: PROTOCOLS
	        - name: LOG_LEVEL
	          value: debug
	        resources: {}
	        livenessProbe:
	          failureThreshold: 3
	          httpGet:
	            port: 3000
	            path: /
	            scheme: HTTP
	          periodSeconds: 10
	          successThreshold: 1
	          timeoutSeconds: 1
	        readinessProbe:
	          failureThreshold: 3
	          httpGet:
	            port: http
	            path: /
	            scheme: HTTP
	          periodSeconds: 10
	          successThreshold: 1
	          timeoutSeconds: 1
	        terminationMessagePath: /dev/termination-log
	        terminationMessagePolicy: File
	        imagePullPolicy: IfNotPresent
	      securityContext: {}
	  revisionHistoryLimit: 10
	  progressDeadlineSeconds: 600
	  
	  

# Tekton e2e Assignment

6 Tasks from pipeline:

- clone-repository
- run-tests
- create image
- create configuration - kustomize
- deploy
- save configuration to manifest, to be used after with ArgoCD to deploy in specific environment

**Tekton kinds (pipeline,tasks,vcs trigger,etc..) are here:**

[https://github.com/chrisley75/nextjs-sample-app/tree/main/tekton](https://github.com/chrisley75/nextjs-sample-app/tree/main/tekton)

**Kustomize configuration are here:**

[https://github.com/chrisley75/nextjs-sample-app/tree/main/k8s](https://github.com/chrisley75/nextjs-sample-app/tree/main/k8s)

**How to configure ArgoCD (continuous deployment) are here**:

[Argo CD](argocd/README.md)