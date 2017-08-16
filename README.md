# nginx-ldap-docker
A small Nginx docker image that supports LDAP-based authentication.

## Available Docker Images at DockerHub

Image Name       | Tag    | Alpine Linux | Nginx  | Nginx-LDAP module
-----------------|--------|--------------|--------|--------------------------------------------------------
m00re/nginx-ldap | 1.13.4 | 3.4          | 1.13.4 | 42d195d7a7575ebab1c369ad3fc5d78dc2c2669c (Jul 25, 2017)
m00re/nginx-ldap | 1.9.15 | 3.4          | 1.9.15 | b80942160417e95adbadb16adc41aaa19a6a00d9 (Feb 4, 2017)

See: https://hub.docker.com/r/m00re/nginx-ldap/

## Building
You can simple rebuild this image using the following command
```
docker build . -t <YourTag>
```

## Acknowledgments
A huge thank you goes to [Jacob Blain Christen](https://github.com/dweomer) for https://github.com/dweomer/dockerfiles-nginx-auth-ldap, on which this Docker image is based.
