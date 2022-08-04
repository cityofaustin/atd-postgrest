# atd-postgrest

![Service diagram](images/diagram.png)

This repository contains configuration files for orchestrating Austin Transportation's [PostgREST](https://postgrest.org/) services.

## Design

ATD relies on multiple postgREST services. These services are fronted by a single [HAProxy](http://www.haproxy.org/) load balancer, which functiones as a reverse proxy to route requests to each postgREST instance.

The root endpoint is available at [http://atd-postgrest.austinmobility.io/](http://atd-postgrest.austinmobility.io/).

## Services

- knack services ([repo](https://github.com/cityofaustin/atd-knack-services)) - (`/knack-services/`)
- legacy scripts ([repo](https://github.com/cityofaustin/atd-data-deploy)) - (`/legacy-scripts/`)
- parking ([repo](https://github.com/cityofaustin/atd-parking-data)) - (`/parking/`)
- data lake ([repo](https://github.com/cityofaustin/atd-data-lake)) - (`/ctr-data-lake/`)

## Configuration

### Environment variables

Because each of the services's databases are hosted in the same RDS cluster, the following environment variables are applied to all postgREST services.

- `PG_HOST`: the postgres server host name
- `PG_USER`: the postgres user name
- `PG_PASSWORD`: the postgres password
- `PGREST_MAX_ROWS`: the maximum rows to be returned by a postgREST request

As well, each postgREST service requires a unique (32-char minimum) JWT secret. The var can be named as you whish, and must be referenced in `docker-compose.yaml` (look there for example).

### Docker

Each postgREST service must be defined in `docker-compose.yaml`. The service name defined in the compose yaml wil be referenced as a host in the HA proxy config.

### HAProxy

A dockerized HAProxy service reverse-proxy routing to the available postgREST instances.

### `happroxy/config/haproxy.cfg`

This file defines the HAProxy configuration. Each "backend" postgREST service must be fined here. See the comments in that file for details.

### `happroxy/maps/routes.map`

This filed defines which how an inbound HTTP request's path will be mapped to the various backend postgREST services. See the comments in that file for details.
