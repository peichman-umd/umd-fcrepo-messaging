# umd-fcrepo-messaging

UMD Libraries Fedora Messaging Infrastructure

## Key Components

* [ActiveMQ] is the message broker
* [Camel] configures message routing

## Related Repositories

* [umd-camel-processors](https://github.com/umd-lib/umd-camel-processors)
* [umd-fcrepo-docker]

## Camel Routes

[Route definitions](activemq/conf/camel) (written in the
[Camel Spring XML DSL]).

## Docker Image

This repository contains a [Dockerfile](Dockerfile) for creating a Docker image.

This image is based on the [OpenJDK 8 Docker base image], and runs
[ActiveMQ 5.16.0] with [umd-camel-processors 1.0.0].

### Volumes

|Mount point|Purpose|
|-----------|-------|
|`/var/opt/activemq`|Persistent data for ActiveMQ (queues, logs, etc.)|
|`/var/log/fixity`  |Fixity check logs (see the [fixity Camel route])|

### Ports

|Port number|Purpose|
|-----------|-------|
|8161       |ActiveMQ web admin console|
|11099      |[JMX] remote connection|
|61613      |[STOMP] messaging|
|61616      |[OpenWire] messaging|

### Build

The [POM file](pom.xml) includes the [fabric8io docker-maven-plugin], so 
creating the image is as simple as running:

```bash
mvn docker:build
```

The resulting image will be tagged as `docker.lib.umd.edu/fcrepo-messaging`,
plus a version string. If the `project.version` property defined in the POM
file is a SNAPSHOT, the version string will be "latest". Otherwise, it will
be the `project.version` property value from the POM file.

### Run

TODO: specify required environment to run this image

```bash
docker run -it --rm --name docker.lib.umd.edu/fcrepo-messaging \
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
[Camel Spring XML DSL]: https://camel.apache.org/components/latest/spring-summary.html 
[umd-fcrepo-docker]: https://github.com/umd-lib/umd-fcrepo-docker
[fixity Camel route]: activemq/conf/camel/fixity.xml
[STOMP]: https://stomp.github.io/
[OpenWire]: https://activemq.apache.org/openwire.html
[OpenJDK 8 Docker base image]: https://hub.docker.com/_/openjdk
[ActiveMQ 5.16.0]: https://activemq.apache.org/activemq-5016000-release
[umd-camel-processors 1.0.0]: https://github.com/umd-lib/umd-camel-processors/tree/1.0.0
[fabric8io docker-maven-plugin]: https://dmp.fabric8.io/
[JMX]: https://activemq.apache.org/jmx#activemq-mbeans-reference
