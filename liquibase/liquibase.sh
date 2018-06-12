#!/bin/bash

docker run --rm --network container:database -v "$(pwd)":/liquibase/ --env-file liquibase.env webdevops/liquibase:mysql update
