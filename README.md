# umd-fcrepo-messaging

UMD Libraries Fedora Messaging Infrastructure

## Key Components

* [ActiveMQ] is the message broker
* [Camel] configures message routing

## Related Repositories

* [umd-camel-processors](https://github.com/umd-lib/umd-camel-processors)
* [umd-fcrepo-docker]

## ActiveMQ Docker Image

Built from the [OpenJDK 8 Docker base image](https://hub.docker.com/_/openjdk),
with [ActiveMQ 5.16.0](http://activemq.apache.org/activemq-5160-release).

[Dockerfile](activemq/Dockerfile)

Create a persistent data volume, if needed:

```bash
docker volume create fcrepo-activemq-data
```

Build and run this image.

```bash
cd activemq
docker build -t docker.lib.umd.edu/fcrepo-activemq .
docker run -it --rm --name fcrepo-activemq \
    -p 61616:61616 -p 61613:61613 -p 8161:8161 \
    -v fcrepo-activemq-data:/var/opt/activemq \
    docker.lib.umd.edu/fcrepo-activemq
```

The ActiveMQ web admin console will be at <http://localhost:8161/admin/>

* STOMP server and port: `localhost:61613`
* OpenWire server and port: `localhost:61616`

## History

This code comes from the [activemq](https://github.com/umd-lib/umd-fcrepo-docker/tree/1.0.1/activemq) subdirectory of the [umd-fcrepo-docker] project at the 1.0.1 release.

## License

See the [LICENSE](LICENSE) file for license rights and limitations (Apache 2.0).


[ActiveMQ]: https://activemq.apache.org/components/classic/
[Camel]: https://camel.apache.org/
[umd-fcrepo-docker]: https://github.com/umd-lib/umd-fcrepo-docker
