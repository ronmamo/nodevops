# NoDevops

**Encapsulate all of your projects' CI/CD needs into a portable ad-hoc Docker agent**

Execute build/push/deploy and other CI/CD commands using simple one-liners.

Can works for any build tool and any deployment tool. Includes all relevant environment variables and CLI tools.

- Commands: build, push, deploy, cicd, pipeline, promote, ...
- CLIs: hub (github), kubectl, helm, slack, maven, go, dotnet, jira, aws, azure, jfrog, ...
- Features: github, kubernetes, aws, java, go, dotnet, ...

_WIP / POC / Looking for design partners_

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

