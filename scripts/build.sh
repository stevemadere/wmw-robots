eval $(docker-machine env default) # equivalent of the old $(boot2docker shellinit)
docker build -t stevemadere/wmw-robots . # && \
#docker push stevemadere/wmw-robots
