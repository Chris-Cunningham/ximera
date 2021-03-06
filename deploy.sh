#!/bin/bash
if [ $(hostname) = ximera-1.asc.ohio-state.edu ]; then
    echo On the deployment machine.
    echo Pulling latest version from github...
    mv -f environment.sh environment.backup
    git pull
    mv -f environment.backup environment.sh
    echo Updating npm...
    npm install
    echo Running grunt...
    ./node_modules/grunt-cli/bin/grunt production
    echo Stopping old copies of app.js...
    ./node_modules/forever/bin/forever stop app.js
    echo Starting a new copy of app.js...
    source environment.sh
    export DEPLOYMENT=production
    export NODE_ENV=production
    ./node_modules/forever/bin/forever start -a -l forever.log -o out.log -e err.log app.js &
else
    echo not on the deployment machine...
    echo copying environment to deployment machine...
    rsync -avz -f"- .git/" environment.sh ximera:/var/www/apps/ximera
    echo ssh to the deploy machine...
    ssh ximera "cd /var/www/apps/ximera ; source deploy.sh"
fi
