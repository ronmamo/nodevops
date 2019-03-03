
RUN apk add --no-cache npm

ENV GITHUB_TOKEN=

RUN npm install -g gh-jira
