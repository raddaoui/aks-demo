### Run python server
    python3 printhostname.py

### Build docker container and upload it to dockerhub account
    docker_registry="docker.io/raddaoui" # change value to your docker registry URL
    docker build . -t $docker_registry/printhostname:v1
    docker push $docker_registry/printhostname:v1

### Run container locally
    docker run --rm -it -p 8000:80  --name printhostname $docker_registry/printhostname:v1