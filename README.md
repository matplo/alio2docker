# alio2docker
Alice O2 software in a docker

## quick how-to

1. clone 
2. run `./buildDocker.sh` to make the docker image
3. run `./runDocker.sh` to run it...
4. run `./buildO2Physics.sh` and bet super patient... ;-)

## few notes

- on my laptop (macOS Catalina) I had to increase memory to 6GB for the container to compile... (see options in ./runDocker.sh)
- on a mac I am using Docker Desktop from Docker itself (one can increase the default mem in settings - global to all containers - default is 2GB)
- `./runDocker.sh` will look for the exited (or running) containers before running a new one; so if you need another one make sure you use a different command...
- `./buildO2Physics.sh` builds only that - need to tune/change if you want AliPhysics ...
