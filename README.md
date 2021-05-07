# umd-fcrepo-messaging

UMD Libraries Fedora Messaging Infrastructure

## Key Components

* [ActiveMQ] is the message broker
* [Camel] configures message routing

## Related Repositories

* [umd-camel-processors](https://github.com/umd-lib/umd-camel-processors)
* [umd-fcrepo-docker]

## Docker Image

Built from the [OpenJDK 8 Docker base image](https://hub.docker.com/_/openjdk),
with [ActiveMQ 5.16.0](http://activemq.apache.org/activemq-5160-release) and
[umd-camel-processors 1.0.0](https://github.com/umd-lib/umd-camel-processors/tree/1.0.0).

[Dockerfile](Dockerfile)

### Volumes

|Mount point|Purpose|
|-----------|-------|
|`/var/opt/activemq`|Persistent data for ActiveMQ (queues, logs, etc.)|
|`/var/log/fixity`  |Fixity check logs (see the [fixity Camel route])|

### Ports

|Port number|Purpose|
|-----------|-------|
|8161       |ActiveMQ web admin console|
|61613      |[STOMP] messaging|
|61616      |[OpenWire] messaging|

### Build

Build the image:

```bash
docker build -t docker.lib.umd.edu/fcrepo-messaging activemq
```

TODO: specify required environment to run this image

```bash
docker run -it --rm --name fcrepo-messaging \
    -p 61616:61616 -p 61613:61613 -p 8161:8161 \
    docker.lib.umd.edu/fcrepo-messaging
```

The ActiveMQ web admin console will be at <http://localhost:8161/admin/>

* [STOMP] server and port: `localhost:61613`
* [OpenWire] server and port: `localhost:61616`

## History

This code comes from the
[activemq](https://github.com/umd-lib/umd-fcrepo-docker/tree/1.0.1/activemq)
subdirectory of the [umd-fcrepo-docker] project at the 1.0.1 release.

## License

See the [LICENSE](LICENSE) file for license rights and limitations (Apache 2.0).


[ActiveMQ]: https://activemq.apache.org/components/classic/
[Camel]: https://camel.apache.org/
[umd-fcrepo-docker]: https://github.com/umd-lib/umd-fcrepo-docker
[fixity Camel route]: activemq/conf/camel/fixity.xml
[STOMP]: https://stomp.github.io/
[OpenWire]: https://activemq.apache.org/openwire.html
