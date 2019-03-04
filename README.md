# NoDevops

_A different take on Continuous Integration and Deployment_

**Encapsulate all of your projects' CI/CD needs into a portable ad-hoc Docker agent.**

Execute build/push/deploy and other CI/CD commands using simple one-liners.

Can work for any build tool and any deployment tool. Includes all relevant environment variables and CLI tools.

- Commands: build, push, deploy, cicd, pipeline, promote, ...
- CLIs: hub (github), kubectl, helm, slack, maven, go, dotnet, jira, aws, azure, gcloud, jfrog, ...
- Features: github, kubernetes, aws, java, go, dotnet, ...

_WIP / POC / Looking for design partners_

----

## How it works

Given your project's sources, the first command **init** creates both the ad-hoc `nodevops` scripts and Docker agents. 
The project's sources and your environment are inspected, language and features are detected, and a customized Docker agent is built accordingly.

The Docker agent is based on alpine, contains the relevant build tools and CLIs, captures the required environment variables, and is portable and executable by any machine - either developers' or CI servers.

From this point, you can use the `nodevops` script to execute CI/CD commands for this specific project, such as **build**, **push**, **deploy**. The **cicd** command creates a github webhook, listens to pull requests and comments, and executes **pipeline** or other commands when required.

It is very easy to extend the project with any build/deploy tool - by adding a Dockerfile snippet (for building the customized Docker agent), and few Shell script lines (for commands execution).

#### Example
For example, Golang project sources with Dockerfile for packaging, environment variables set for GITHUB_TOKEN, and a defined .kube context - the generated Docker agent will contain Golang and Docker to execute _build_, together with the environment needed to execute _cicd_ gitops commands with github, and kubernetes for _deploy_.

Another example, Java project sources with Maven pom.xml and Dockerfile for packaging, environment for GITHUB_TOKEN, DOCKER_REGISTRY and Artifactory context defined - the generated Docker agent will contain Java and Maven to execute _build_, _push_ and _pull_ artifact into Artifactory and Docker image into the Docker registy, as well as _cicd_ using Github gitops.

----

### Init
Generate `nodevops` script and Docker agent:
```bash
docker run -it -v $PWD:/workspace nodevops/agent init

./nodevops init <project-name> [features]
```

![nodevops-example-go-init](https://user-images.githubusercontent.com/2588829/53689563-830e1f00-3d8b-11e9-9420-46ff8947124f.gif)

### Build-Push-Deploy
Execute `nodevops` build-push-deploy and other commands:
```bash
./nodevops build [release]
./nodevops push <release>
./nodevops deploy <release>
```

![nodevops-example-java-build-push-deploy](https://user-images.githubusercontent.com/2588829/53689687-bc478e80-3d8d-11e9-94d6-29d066304826.gif)

### CI/CD
Execute CI/CD pipelines using github webhook, [adnanh-webhook](https://github.com/adnanh/webhook) and ngrok:
```bash
./nodevops cicd start <project-name>

./nodevops cicd logs

./nodevops cicd stop
```

![nodevops-cicd](https://user-images.githubusercontent.com/2588829/53676700-ad52d480-3cd8-11e9-9b9b-758787665032.gif)

----

### Production build environments
The `nodevops` script can be commited into the different branches - master, develop and feature - each with optionally slight modifications to reflect the git branching/environment requirements. For example, in the master branch we might want to have continuous deployment to a canary production cluster, and in the develop or feature branches we might want to use different clusters and deployment tools.

Specifically, the **pipeline** command (practically the Shell script which runs after merging pull request), can also have different variations depending on the branch/environment. We can run different build tasks for master and develop branches, use different notifications (slack or email), and execute different set of tests. 

Another point is how to run the operations. One option is using the `nodevops` script and Docker agents from within your CI server. There is no need to deploy or provision the CI servers with the required tools. 

Another option is to use a dedicated kubernetes cluster in order to deploy `nodevops` command into it. In this scenario, there is no need for CI server and workers, and the deployed Docker agents actually act as an encapsulated build workers.

UI is not in the scope of this project and is orthogonal, but there are several alternatives to get feedback on the running operations and build/deploy status.

As for security, one approach would be to inject tokens and secrets from the running host and user, rather than encapsulating it into the Docker agent.

### `nodevops` script
The `nodevops` Shell script contains two sections - CI/CD definitions as environment variables and running the Docker agent.

The definitions are captured and prompted in the **init** command step, based on the optional `[features]` parameters and the host's environment variables and context, and can be further edited manually.

```bash
#!/bin/sh
set -e

# project variables
export PROJECT_NAME=getting-started
export BUILD_TYPE="go docker"
export PUSH_TYPE=docker
export DEPLOY_TYPE=docker
export OPS_TYPE=github

export GITHUB_URL=github.com
export GITHUB_API=https://api.github.com
export GITHUB_USER=noodevops
export DOCKER_REGISTRY=localhost:5000

IMAGE=nodevops/getting-started-agent

...

# run docker agent
docker run ... $VOLUMES $ENV_VARS $IMAGE $@
```
