## To run the dai-backstage in docker with the github auth , dai-release and dai-deploy plugin:

```sh
1. Update the docker-compose_backstage.yaml with the correct version of the image.
```text
    image: xebialabsunsupported/dai-backstage-docker:<version>
```
2. Update the value for environment variables in the docker-compose_backstage.yaml file.
```text
      - AUTH_GITHUB_CLIENT_ID=<clientId>
      - AUTH_GITHUB_CLIENT_SECRET=<clientSecret>
      - DAI_RELEASE_INSTANCE1_NAME=TestEnv
      - DAI_RELEASE_INSTANCE1_HOST=<http://172.19.0.1:5516>
      - DAI_RELEASE_INSTANCE1_TOKEN=<release token>
      - GITHUB_TOKEN=<githubtoken>
      - DAI_DEPLOY_HOST=<http://172.19.0.1:4516>
      - DAI_DEPLOY_USERNAME=<username>
      - DAI_DEPLOY_PASSWORD=<password>
```
3. Run the below command to start the dai-backstage in docker.
```sh
cd docker
docker-compose -f docker-compose_backstage.yaml up -d 
```
4. Open your browser at http://localhost:7007 to access the dai-backstage with the default plugins[dai-release, dai-deploy and github auth] installed.

### To bring down the dai-backstage in docker:
1. Run the below command to stop the dai-backstage in docker.
```sh
cd docker
docker-compose -f docker-compose_backstage.yaml down
```

## To run xl-release, xl-deploy and Backstage in docker with the github, dai-release and dai-deploy plugin:
1. cd into the docker directory.
```sh
cd docker
```
2. Update the value for environment variables in dai-backstage.sh .
```text
      - AUTH_GITHUB_CLIENT_ID=<clientId>
      - AUTH_GITHUB_CLIENT_SECRET=<clientSecret>    
      - GITHUB_TOKEN=<githubtoken>  
```
3. Run the below command to start the dai-backstage in docker with xl-release and xl-deploy.
```sh
./dai-backstage_up.sh
```
4. Open your browser at http://localhost:7007 to access the dai-backstage with the default plugins[dai-release, dai-deploy and github auth] installed.

### To bring down the dai-backstage in docker with xl-release and xl-deploy:
1. Run the below command to stop the dai-backstage in docker.
```sh
cd docker
./dai-backstage_down.sh
```