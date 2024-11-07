# Set Network, Environment variables and start the services.
export NETWORK_NAME=dai-backstage
export DAI_RELEASE_IMAGE=xebialabs/xl-release:24.1
export DAI_DEPLOY_IMAGE=xebialabs/xl-deploy:24.1
export DAI_BACKSTAGE_IMAGE=xebialabsunsupported/dai-backstage-docker:1.0.0
export DAI_DEPLOY_USERNAME=admin
export DAI_DEPLOY_PASSWORD=admin
export GITHUB_TOKEN=<GITHUB_TOKEN>
export AUTH_GITHUB_CLIENT_ID=<AUTH_GITHUB_CLIENT_ID>
export AUTH_GITHUB_CLIENT_SECRET=<AUTH_GITHUB_CLIENT_SECRET>

# Create the external network
docker network create $NETWORK_NAME

docker-compose -f docker-compose_release_deploy.yaml up -d

# Export the IP addresses dai-release and dai-deploy
export releaseIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-dai-release-1)
export deployIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-dai-deploy-1)


# Wait for the dai-release service to be ready
until curl -s http://$releaseIp:5516 > /dev/null ; do
  echo "Waiting for the dai-release to be ready..."
  sleep 10
done

# Wait for the dai-deploy service to be ready
until curl -s http://$deployIp:4516 > /dev/null ; do
  echo "Waiting for the dai-deploy to be ready..."
  sleep 10
done


# Generate the token for the dai-release
TOKEN=$(curl -u admin:admin -X POST -H 'Content-Type: application/json' -d '{"tokenNote":"backstageToken"}' http://$releaseIp:5516/api/v1/personal-access-tokens/admin | jq -r '.token' )

# Deploy the application using dai-deploy
docker run --network dai-backstage -v $(pwd)/..:$(pwd) -w $(pwd) xebialabs/xl-client:24.1 apply -f deploy/digital-ai-deploy.yaml --xl-deploy-url http://$deployIp:4516/

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

# Start the backstage
docker-compose -f docker-compose_backstage.yaml up -d