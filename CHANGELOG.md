# WaterAuth Docker Image

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [UNRLEASED]
### Updated
- kmschoep@usgs.gov - use version 0.0.4 wma-spring-boot-base docker image from dockerhub

## [0.3.6] - 2018-06-21
### Updated
- zmoore@usgs.gov - Updated the Water Auth Java artifact version to 0.3.6.
### Removed
- isuftin@usgs.gov - Completely remove the keystore if it exists early in the
  entrypoint
### Added
- isuftin@usgs.gov - Add example liquibase code for client updates
- isuftin@usgs.gov - Added container names to compose config

## [0.1.3] - 2018-04-03
### Updated
- zmoore@usgs.gov - Updated the Water Auth Java artifact version to 0.3.5.

## [0.1.2] - 2018-03-09
### Updated
- isuftin@usgs.gov - Remove echoing from entrypoint
- isuftin@usgs.gov - Use PKCS12 trust store instead of JKS
- isuftin@usgs.gov - Update healthcheck to use metadata pull

## [0.1.1] - 2018-03-09
### Added
- isuftin@usgs.gov - Initial creation
