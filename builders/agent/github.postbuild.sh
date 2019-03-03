
echo "alias git=hub" >> $ENV

if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" >> $ENV
fi

if [ ! -z "$GITHUB_URL" ]; then
    git config --global --add hub.host $GITHUB_URL
fi

if [ ! -z "$GITHUB_USER" ]; then
    git config --global user.name $GITHUB_USER
fi
