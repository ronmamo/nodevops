# NoDevops

**Encapsulate all of your projects' CI/CD needs into a portable ad-hoc Docker agent**

Execute build/push/deploy and other CI/CD commands using simple one-liners

Works for any build tool and any deployment tool, includes all required environment variables and CLI tools

- Commands: build, push, deploy, cicd, pipeline, promote, ...
- CLIs: hub (github), kubectl, helm, slack, maven, go, dotnet, jira, aws, azure, jfrog, ...
- Features: github, kubernetes, aws, java, go, dotnet, ...

_WIP / POC / Looking for design partners_

### Init
Generate `nodevops` script:
```bash
docker run -it -v $PWD:/workspace nodevops/agent init

./nodevops init <project-name> [features]
```

![nodevops-init](https://user-images.githubusercontent.com/2588829/53676305-e7b97300-3cd2-11e9-80a9-1837be7a8b65.gif)

### Build-Push-Deploy
Execute `nodevops` build-push-deploy and other commands:
```bash
./nodevops build [release]
./nodevops push <release>
./nodevops deploy <release>
```

![nodevops-build-push-deploy](https://user-images.githubusercontent.com/2588829/53676340-62828e00-3cd3-11e9-9aad-b9e79f5eae05.gif)

### CI/CD
Execute CI/CD pipelines using github webhook, [adnanh-webhook](https://github.com/adnanh/webhook) and ngrok:
```bash
./nodevops cicd start <project-name>

./nodevops cicd logs

./nodevops cicd stop
```

![nodevops-cicd](https://user-images.githubusercontent.com/2588829/53676700-ad52d480-3cd8-11e9-9b9b-758787665032.gif)

