#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export FLASK_APP=/app.py
#export RUNNER_NAME="my-runner"
#export REPO="qureos/qureos"
#export ACCESS_TOKEN="ghp_Mh0WXAIC7dxxxxxxxx"

export RUNNER_NAME=$RUNNER_NAME
export REPO=$REPO
export ACCESS_TOKEN=$ACCESS_TOKEN

python3 -m flask run --host=0.0.0.0 --port=3001 &

# Wait for Flask application to start
sleep 5  # Adjust this value as needed

# Function to register the GitHub Actions runner
register_runner() {

    # Get registration token for GitHub Actions runner
    REG_TOKEN=$(curl -X POST -H "Authorization: token $ACCESS_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/qureos/qureos/actions/runners/registration-token | jq -r '.token')

    # Output registration token
    echo "Registration Token: $REG_TOKEN"

    # Change directory to where the runner is located
    cd /home/docker/actions-runner

    # Configure and start the runner
    ./config.sh --url https://github.com/$REPO --token $REG_TOKEN --runnergroup "Default" --name $RUNNER_NAME --labels $RUNNER_NAME --work _work

    # Clean up runner
    cleanup() {
        echo "Removing runner..."
        ./config.sh remove --unattended --token ${REG_TOKEN}
    }

    # Trap interrupts and terminate signals to clean up
    trap 'cleanup; exit 130' INT
    trap 'cleanup; exit 143' TERM
   
    ./run.sh & wait $!
}

# Run the registration function in the background
register_runner &

# Wait for background Flask process to finish
wait
