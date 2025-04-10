# Set Network, Environment variables and start the services.
export NETWORK_NAME=dai-backstage
export DAI_RELEASE_IMAGE=xebialabs/xl-release:24.3
export DAI_DEPLOY_IMAGE=xebialabs/xl-deploy:24.3
export DAI_BACKSTAGE_IMAGE=xebialabsunsupported/dai-backstage-docker:1.0.1
export DAI_DEPLOY_USERNAME=admin
export DAI_DEPLOY_PASSWORD=admin
export GITHUB_TOKEN=<GITHUB_TOKEN>
#export AUTH_GITHUB_CLIENT_ID=<AUTH_GITHUB_CLIENT_ID>
#export AUTH_GITHUB_CLIENT_SECRET=<AUTH_GITHUB_CLIENT_SECRET>
export base64Token=$(echo -n admin:admin | base64)
export DAI_DEPLOY_AUTH_TOKEN="Basic $base64Token"
export START_BACKSTAGE_IN_DOCKER=false
export BACKSTAGE_MANUAL_INSTALL=true

# Create the external network
docker network create $NETWORK_NAME

docker-compose -f docker-compose_release_deploy.yaml up -d

# Export the IP addresses dai-release and dai-deploy
export releaseIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-dai-release-1)
export deployIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-dai-deploy-1)

timeout=120
elapsed_time_release=0
elapsed_time_deploy=0
elapsed_time_backstage=0

# Wait for the dai-release service to be ready with timeout
until curl -s http://$releaseIp:5516 > /dev/null ; do
  if [[ $elapsed_time_release -ge $timeout ]]; then
    echo "Timeout reached. dai-release is not ready within $timeout seconds."
    exit 1  # Exit with an error if the service is not ready
  fi
  echo "Waiting for the dai-release to be ready..."
  sleep 10
  elapsed_time_release=$((elapsed_time_release + 10))  # Increment elapsed time for dai-release
done
echo "dai-release is ready!"

# Wait for the dai-deploy service to be ready with timeout
until curl -s http://$deployIp:4516 > /dev/null ; do
  if [[ $elapsed_time_deploy -ge $timeout ]]; then
    echo "Timeout reached. dai-deploy is not ready within $timeout seconds."
    exit 1  # Exit with an error if the service is not ready
  fi
  echo "Waiting for the dai-deploy to be ready..."
  sleep 10
  elapsed_time_deploy=$((elapsed_time_deploy + 10))  # Increment elapsed time for dai-deploy
done
echo "dai-deploy is ready!"

# Generate the token for the dai-release
TOKEN=$(curl -u admin:admin -X POST -H 'Content-Type: application/json' -d '{"tokenNote":"backstageToken"}' http://$releaseIp:5516/api/v1/personal-access-tokens/admin | jq -r '.token' )

# Deploy the application using dai-deploy
docker run --network dai-backstage -v $(pwd)/:$(pwd) -w $(pwd) xebialabs/xl-client:24.3 apply -f deploy/digital-ai-deploy.yaml --xl-deploy-url http://$deployIp:4516/

# Export the environment variables for the backstage
export GITHUB_TOKEN=$GITHUB_TOKEN
export AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID
export AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET
export DAI_RELEASE_INSTANCE1_NAME=dai-release-instance
export DAI_RELEASE_INSTANCE1_TOKEN=$TOKEN
export DAI_RELEASE_INSTANCE1_HOST=http://$releaseIp:5516
export DAI_DEPLOY_HOST=http://$deployIp:4516
export DAI_DEPLOY_USERNAME=$DAI_DEPLOY_USERNAME
export DAI_DEPLOY_PASSWORD=$DAI_DEPLOY_PASSWORD
export DAI_DEPLOY_AUTH_TOKEN=$DAI_DEPLOY_AUTH_TOKEN


echo http://$releaseIp:5516
echo http://$deployIp:4516

echo GITHUB_TOKEN=$GITHUB_TOKEN > ../backstage-with-new-backend/.env
echo DAI_RELEASE_INSTANCE1_NAME=dai-release-instance >> ../backstage-with-new-backend/.env
echo DAI_RELEASE_INSTANCE1_TOKEN=$TOKEN >> ../backstage-with-new-backend/.env
echo DAI_RELEASE_INSTANCE1_HOST=http://$releaseIp:5516 >> ../backstage-with-new-backend/.env
echo DAI_DEPLOY_HOST=http://$deployIp:4516 >> ../backstage-with-new-backend/.env
echo DAI_DEPLOY_USERNAME=$DAI_DEPLOY_USERNAME >> ../backstage-with-new-backend/.env
echo DAI_DEPLOY_PASSWORD=$DAI_DEPLOY_PASSWORD >> ../backstage-with-new-backend/.env
echo DAI_DEPLOY_AUTH_TOKEN=$DAI_DEPLOY_AUTH_TOKEN >> ../backstage-with-new-backend/.env


if [ "$START_BACKSTAGE_IN_DOCKER" = "true" ]; then
  # Start the backstage
  docker-compose -f docker-compose_backstage.yaml up -d

  export daiBackstageIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-backstage-1)
  # Wait for the dai-backstage service to be ready with timeout
  until curl -s http://$daiBackstageIp:7007 > /dev/null ; do
    if [[ $elapsed_time_backstage -ge $timeout ]]; then
      echo "Timeout reached. dai-backstage is not ready within $timeout seconds."
      exit 1  # Exit with an error if the service is not ready
    fi
    echo "Waiting for the dai-backstage to be ready..."
    sleep 10
    elapsed_time_backstage=$((elapsed_time_backstage + 10))  # Increment elapsed time for dai-backstage
  done
  echo "dai-backstage is ready!"
elif [  "$START_BACKSTAGE_IN_DOCKER" = "false" ]; then
  if [ "BACKSTAGE_MANUAL_INSTALL" = "false" ]; then
    cd ../backstage-with-new-backend
    LOG_LEVEL=debug NODE_OPTIONS=--no-node-snapshot env-cmd -f .env yarn dev:env
  fi
  else
    echo "Start Backstage manual from ../backstage-with-new-backend"
    exit 1
fi


