# Schnüffelstück [![Build Status](https://travis-ci.org/Jimdo/schnueffelstueck.svg?branch=master)](https://travis-ci.org/Jimdo/schnueffelstueck)
*| < schnueffel > ˈstuːk |* [¹](https://www.youtube.com/watch?v=iTp5wrX1w64) *german* – *snifter valve [noun]*: a valve on a steam engine that allows air in or out.

A piece of software that extracts realtime metrics from fastly logs and pushes them into your metrics system.

## How it works

Fastly has no way of exporting realtime metrics. But in order to monitor your services monitoring CDN metrics might be helpful. And having your CDN metrics in YOUR metrics system might come handy. Here *Schnüffelstück* comes into play.

Fastly will stream it's real-time logs to the *Schnüffelstück* where it's parsing out a set of different CDN specific metrics and pushes them to all configured metric backends.

*Schnüffelstück* can handle multiple fastly services each reporting to multiple metrics backends.

## Installation

1. Install [erlang](https://www.erlang.org/downloads)

2. Magic
```bash
mkdir -p ./schnueffelstueck
wget https://github.com/Jimdo/schnueffelstueck/releases/download/v1.0.0/schnueffelstueck-1.0.0-linux-x64.tar.gz # download
cd schnueffelstueck/
tar -xf ../schnueffelstueck-1.0.0-linux-x64.tar.gz # unpack...
vim schnueffelstueck-config.yml # adjust config to your needs
bin/schnueffelstueck start # start your schnueffelstueck
bin/schnueffelstueck ping # check if starting was successful
```

3. Enjoy your metrics

## Configuration

### Schnüffelstück

You can configure your Schnüffelstück with a [yaml file](http://yaml.org/), copy the [example](schnueffelstuck-config.example.yml) to `schnueffelstuck-config.yml` into your production *cwd* and adjust to your needs.

Here is a simple example with comments:

```yaml
---
services:                           # base key for all your configured services
- fastly_service_token: s3cr3tt0ken # fastly token, you have to configure in fastly as well (basically a shared secret per fastly service)
  reporter:
    - librato:                      # reporter key to determine to which metrics service you want to report to. it contains custom config per reporter
        user: bla@jimdo.com         # your librato user
        token: 12345                # your librato token (write access)
        service: catwalk            # will be used as a prefix to generate the metrics (e.g. catwalk.fastly.method.GET)
```

### Fastly

Add a syslog logging endpoint to your fastly service like so:

Token: `s3cr3tt0ken`

Format:
```
%h %t %r %>s %b fastly_info.state obj.hits obj.lastuse time.elapsed
```

which will result in the following log lines:
```
s3cr3tt0ken<134>2016-03-07T15:22:04Z cache-lhr6325 schnueffelstueck-syslog[396422]: 109.17.194.160 Tue, 22 Mar 2016 12:01:01 GMT GET /some/path 200 73080 HIT 3 29.309 0.000
```

### Reporters
There is only one reporter at the moment. But the reporters follow a clean protocol (behaviour), implementing more should be relativly easy.

#### Librato
Reports the metrics into [Librato Metrics system](https://metrics.librato.com) you configure the reporter with the following values:

- `user` and `token` your librato credentials
- `service` is used as a prefix (see below)

This reporter creates the following set of metrics per request:
- *service*.fastly.bytes
- *service*.fastly.cache_hit.HIT
- *service*.fastly.cache_hit.HIT-CLUSTER
- *service*.fastly.cache_hit.HIT-STALE
- *service*.fastly.cache_hit.HIT-STALE-CLUSTER
- *service*.fastly.cache_hit.MISS-CLUSTER
- *service*.fastly.cache_hit.PASS
- *service*.fastly.method.GET
- *service*.fastly.method.HEAD
- *service*.fastly.origin_latency
- *service*.fastly.requests
- *service*.fastly.status.200
- *service*.fastly.status.304
- *service*.fastly.status.400

## Roadmap and Ideas
- Add prometheus support
- Report schnüffelstück metrics to a given service
