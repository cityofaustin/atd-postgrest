# atd-postgrest

![Service diagram](images/diagram.png)

This repository contains configuration files for orchestrating Austin Transportation's [PostgREST](https://postgrest.org/) services.

## Table of contents

- [atd-postgrest](#atd-postgrest)
  - [Table of contents](#table-of-contents)
  - [Design](#design)
  - [Services](#services)
  - [Configuration](#configuration)
    - [Environment variables](#environment-variables)
    - [Docker](#docker)
    - [HAProxy](#haproxy)
    - [`haproxy/config/haproxy.cfg`](#happroxyconfighaproxycfg)
    - [`haproxy/maps/routes.map`](#happroxymapsroutesmap)
  - [Get it running](#get-it-running)
  - [Deployment](#deployment)
  - [Maintenance](#maintenance)

## Design

ATD relies on multiple postgREST services. These services are fronted by a single [HAProxy](http://www.haproxy.org/) load balancer, which functions as a reverse proxy to route requests to each postgREST instance.

The root endpoint is available at [http://atd-postgrest.austinmobility.io/](http://atd-postgrest.austinmobility.io/).

## Services

| name            | repo                                                                       | route               |
| --------------- | -------------------------------------------------------------------------- | ------------------- |
| knack services  | [atd-knack-services](https://github.com/cityofaustin/atd-knack-services)   | `/knack-services/`  |
| legacy scripts  | [atd-data-deploy](https://github.com/cityofaustin/atd-data-deploy)         | `/legacy-scripts/`  |
| parking         | [atd-parking-data](https://github.com/cityofaustin/atd-parking-data)       | `/parking/`         |
| road conditions | [atd-road-conditions](https://github.com/cityofaustin/atd-road-conditions) | `/road-conditions/` |
| bond reporting  | [atd-bond-reporting](https://github.com/cityofaustin/atd-bond-reporting)   | `/bond-reporting/`  |

## Configuration

### Environment variables

Because each of the services's databases are hosted in the same RDS cluster, the following environment variables are applied to all postgREST services.

- `PG_HOST`: the postgres server host name
- `PG_USER`: the postgres user name
- `PG_PASSWORD`: the postgres password
- `PGREST_MAX_ROWS`: the maximum rows to be returned by a postgREST request

As well, each postgREST service requires a unique (32-char minimum) JWT secret. The var can be named as you wish, and must be referenced in `docker-compose.yaml` (look there for example).

The environment file *must* be named `.env` and stored in the root of the repository. This will ensure that variables are [properly interpolated](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#ways-to-set-variables-with-interpolation) into the docker-compose environment. The variable values can be sourced from 1Password in the `atd-postgrest` entry of the developer vault. 

### Docker

Each postgREST service must be defined in `docker-compose.yaml`. The service name defined in the compose yaml wil be referenced as a host in the HA proxy config.

### HAProxy

A dockerized HAProxy service reverse-proxy routing to the available postgREST instances.

### `happroxy/config/haproxy.cfg`

This file defines the HAProxy configuration. Each "backend" postgREST service must be fined here. See the comments in that file for details.

### `happroxy/maps/routes.map`

This filed defines which how an inbound HTTP request's path will be mapped to the various backend postgREST services. See the comments in that file for details.

## Get it running

1. Modify `docker-compose.yaml`, `haproxy.cfg`, and `routes.map` as needed.
2. Create an environment file in the root directory. Name it `env`.
3. Start the services: `$ docker compose up -d`

## Deployment

Access to the production postgREST endpoints is restricted to COA IP addresses. Docker is configured on the production server to restart on boot.

The script `/scripts/docker-keepalive.sh` checks if the HAProxy service is running, and restarts all containers if not. This script is deployed to the prod server's crontab to run every hour.

You can inspect the crontab with `sudo crontab -l`.

## Maintenance

Any changes to this repository must be manually pulled on the prod server.

If you make changes to the schema, permissions, or secrets of any of the running postgREST services, you will need to restart the docker compose service.

```
$ docker compose restart
```

## Local dev

We don't currently have a complete local dev environment, although it is possible to launch a basic end-to-end test of the `knack-services` service. There is a bit of commentary on this subject in https://github.com/cityofaustin/atd-postgrest/pull/8. 

To start the `knack-services` test environment.

1. Terminate any other process you have using port `5432`.

2. In the root of the repo, save an `.env` file which contains the following:

```shell
PG_HOST=postgres
PG_USER=postgres
PG_PASSWORD=postgres
PGRST_JWT_SECRET_KNACK_SERVICES=----for-testing-purposes-only----
PGRST_JWT_SECRET_PARKING=----for-testing-purposes-only----
PGRST_JWT_SECRET_LEGACY_SCRIPTS=----for-testing-purposes-only----
PGRST_JWT_SECRET_ROAD_CONDITIONS=----for-testing-purposes-only----
PGREST_MAX_ROWS=1000
```

1. Start the local stack using the primary compose file and the `local` one. This second compose file adds a postgres database with an empty database matching the `knack-services` schema.

```shell
docker compose -f docker-compose.yaml -f docker-compose-local.yaml up
```

2. Should now be able to make an authenticated request to the `/knack-services/knack` endpoint. Note the use of the JWT, which configured using the JWT secret in the `.env` file.

```
curl http://127.0.0.1:9001/knack-services/knack -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXBpX3VzZXIifQ.z2R8GY8J23EBFWpyLQGqs8iJK1gsCm3Izg1Ez3qq5CQ"
```

It should return an empty array: `[]`.

3. Lastly, try to `GET` any endpoint without the bearer token, and observe that access is restricted

```
curl http://127.0.0.1:9001/knack-services/knack
```
