# webpage-timing

`goenning/webpage-timing` is a docker image that collects performance metrics from a webpage using a real browser.

# how to use it

```
$ docker run goenning/webpage-timing
```

The command above will load `https://example.org/` inside a container and print out a timing object in json format.

The following parameters are available as environment variables:

| Name  | Default Value | Comments |
| ------------- | ------------- | ------------- |
| ORIGIN  | `os.hostname()` | Sets a `origin` property on the timing object. Useful to specify from where the container is being executed. |
| REQUEST_URL | https://example.org/ | Specify which page to load |
| MONGO_URL | <empty> | If specified, the timing object will be stored on given MongoDB instance |

# run it on the cloud

Read [Measuring the performance of a website from multiple locations on a budget](https://goenning.net/2019/02/10/measuring-performance-website-multiple-locations-budget/) to learn how to use this image to collect metrics from locations all around the world. 