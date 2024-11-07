# Set Network, Environment variables and start the services.
export NETWORK_NAME=dai-backstage
export DAI_RELEASE_IMAGE=xebialabs/xl-release:24.1
export DAI_DEPLOY_IMAGE=xebialabs/xl-deploy:24.1
export DAI_BACKSTAGE_IMAGE=xebialabsunsupported/dai-backstage-docker:1.0.0

docker-compose -f docker-compose_backstage.yaml -f docker-compose_release_deploy.yaml down
docker network rm $NETWORK_NAME