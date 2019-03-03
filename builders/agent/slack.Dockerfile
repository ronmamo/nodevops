
RUN curl -Lo /usr/bin/slack https://raw.githubusercontent.com/rockymadden/slack-cli/master/src/slack && \
    chmod +x /usr/bin/slack

ENV SLACK_CLI_TOKEN
