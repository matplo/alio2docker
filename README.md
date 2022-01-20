# alio2docker
Alice O2 software in a docker

## quick how-to

1. clone 
2. run `./buildDocker.sh` to make the docker image
3. run `./runDocker.sh` to run it...
4. run `./buildO2Physics.sh` (within the container of course) and be super patient... ;-)

## few notes

- on my laptop (macOS Catalina) I had to increase memory to 6GB for the container to compile... (see options in ./runDocker.sh)
- on a mac I am using Docker Desktop from Docker itself (one can increase the default mem in settings - global to all containers - default is 2GB)
- `./runDocker.sh` will look for the exited (or running) containers before running a new one; so if you need another one make sure you use a different command...
- `./buildO2Physics.sh` builds only that - need to tune/change if you want AliPhysics ...
- ALICE Software will land in a mounted directory in subdirectories where you cloned the repo... - lots of bytes so beware; within docker container the directory is `/allisoft`
- note the handy `alisoft/enterO2Physics.sh` that simply does `alienv enter O2Physics/latest-master-o2`

## for the impatient

- you can try downloading the compiled software pack (includes sources) from a pre-built archive (per request)
- build the container
- before running unpack the archive within the directory where cloned
- run the container - you should be all set with a version of AliceO2Physics
