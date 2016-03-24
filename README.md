# Schnüffelstück
*| < schnueffel > ˈstuːk |* *german* – *snifter valve [noun]*: a valve on a steam engine that allows air in or out.

A piece of service that extracts realtime metrics from fastly logs and pushes them into your metrics system.

## Road to v1
- [ ] switch config to yaml
- [ ] add service to reporter mapping in yaml file
- [ ] add installation instructions to the Readme

## Installation

*tbd*

## Configuration

### Schnüffelstück

*tbd*

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
