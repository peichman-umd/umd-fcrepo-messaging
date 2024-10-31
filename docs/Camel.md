# Camel

This project uses [Apache Camel] to define message routing between
persistent queues in [ActiveMQ], databases, HTTP services, and other
endpoints.

## Route Naming Conventions

* All route IDs begin with `edu.umd.lib.camel.routes`
* If a route's source is a queue, the ID should continue with `queue.`,
  followed by the name of the queue. For example:
  
  ```xml
  <route id="edu.umd.lib.camel.routes.queue.index.solr">
    <from uri="activemq:index.solr"/>
    <!-- ... -->
  </route>
  ```

* If the route's source is a `direct:` endpoint, the ID should continue
  with the name of that endpoint. For example:

  ```xml
  <route id="edu.umd.lib.camel.routes.solr.AddToIndex">
    <from uri="direct:solr.AddToIndex"/>
    <!-- ... -->
  </route>
  ```
  
## Endpoint Naming Conventions

* `direct:` endpoint names should start with the basename of the XML
  file they are defined in. For example, all the `direct:` endpoints
  defined in [solr.xml](../activemq/conf/camel/solr.xml) start with
  `solr`
  * **Exception:** Endpoints in [routes.xml](../activemq/conf/camel/routes.xml)
    do *not* start with `routes`, so that their corresponding routes
    do not contain the string `routes.routes`

[ActiveMQ]: https://activemq.apache.org/components/classic/
[Camel]: https://camel.apache.org/
