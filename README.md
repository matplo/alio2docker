# alio2docker

Alice O2 software in a docker (linux image - ubuntu 20.04)

## quick how-to

1. clone
2. optional step (see #3 why ) run `./buildDocker.sh` to build the docker image locally (you may want to skip this step)
3. run `./runDocker.sh` to run a the image... (note: in case no local images not found it will attempt to pull nobetternick/alisoft:o2)
4. run `./buildO2Physics.sh` (within the container of course) and be super patient... ;-)
5. optional: you can run `./run_at_test.sh` (run analysis tutorial test) - note: will attempt to curl an AOD file to `AO2D-tutorial.root`

- to run a single command within the container just add it to the ./runDocker.sh (the container will run it and exit; interactive mode with no command at all)

```
./runDocker.sh ls -ltr
```

## few notes

- on my laptop (macOS Catalina) I had to increase memory to 6GB for the container to compile... (see options in ./runDocker.sh)
- on a mac I am using Docker Desktop from Docker itself (one can increase the default mem in settings - global to all containers - default is 2GB)
- `./runDocker.sh` will look for the exited (or running) containers and will print a note - you can ignore but this is ueful
- `./buildO2Physics.sh` builds only that - need to tune/change if you want AliPhysics ...
- ALICE Software will land in a mounted directory in subdirectories where you cloned the repo... - lots of bytes so beware; within docker container the directory is `/alisoft`
- note the handy `alisoft/enterO2Physics.sh` that simply does `alienv enter O2Physics/latest-master-o2`
- the ./runDocker.sh will try to map your user name within the container - will essentially create a user with your system id (and a home dir) and will look for your ~/.globus files...

## for the impatient

- you can try downloading the compiled software pack (includes sources) from a pre-built archive (per request)
- build the container
- before running unpack the archive within the directory where cloned
- run the container - you should be all set with a version of AliceO2Physics
