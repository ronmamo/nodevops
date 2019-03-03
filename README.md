# NoDevops

_A different take on Continious integration and deployment_

**Encapsulate all of your projects' CI/CD needs into a portable ad-hoc Docker agent.**

Execute build/push/deploy and other CI/CD commands using simple one-liners.

Can work for any build tool and any deployment tool. Includes all relevant environment variables and CLI tools.

- Commands: build, push, deploy, cicd, pipeline, promote, ...
- CLIs: hub (github), kubectl, helm, slack, maven, go, dotnet, jira, aws, azure, jfrog, ...
- Features: github, kubernetes, aws, java, go, dotnet, ...

_WIP / POC / Looking for design partners_

----

## How it works

Given your project's sources, the first command **init** creates both the ad-hoc `nodevops` scripts and Docker agents. 
The project's sources and your environment are inspected, language and features are detected, and a customized Docker agent is built accordingly.

The Docker agent is based on alpine, contains the relevant build tools and CLIs, captures the required environment variables, and is portable and executable by any machine, either developers' or CI servers.

From this point, you can use the `nodevops` script to execute CI/CD commands for this specific project, such as **build**, **push**, **deploy**. The **cicd** command creates a github webhook, listens to pull requests and comments, and executes **pipeline** or other commands when required (gitops).

It is very easy to extend the project with for any build/deploy tool - by adding a Dockerfile snippet to install the relevant CLI tool (for the customized Docker agent), and few Shell script lines (for commands).

#### Example
For example, for a Java project sources with Maven pom.xml file, environment variables set for GITHUB_TOKEN, and a defined kubernetes context .kube - the ad-hoc Docker agent is going to contain Java and Maven to execute _build_, together with the environment needed to execute _cicd_ gitops commands with github, and kubernetes context for _deploy_.

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
