# docker-kafka

Apache Kafka docker image based on alpine

## Run server

```
# load default env
eval $(docker-machine env default)

# network 
docker network create vnet

# kafka startup (zookeeper, kafka)
docker-compose up -d

# tail logs for a while
docker-compose logs -f

# check ps
docker-compose ps



```