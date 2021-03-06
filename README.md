notes on openshift and sbt
===

#### tl;dr;

A configurable [multistage build](https://github.com/sbt/sbt-native-packager/issues/1189#issuecomment-454629204) would be ideal
- enabled: you get a smaller image
- disabled: you get compatiblity on earlier docker versions but at cost of larger image

---


Dockerfile produced by this configuration

```dockerfile
FROM openjdk:8-jre-slim
WORKDIR /opt/docker
ADD --chown=daemon:root opt /opt
ENV PATH="$PATH:/opt/docker/bin"
USER daemon
ENTRYPOINT []
CMD []
```

```
#! docker run --rm -it myimage example-openshift-read-only
hello, OpenShift from daemon
```

```
#! docker run -u9999 --rm -it myimage example-openshift-read-only
standard_init_linux.go:190: exec user process caused "permission denied"
```
---

Executables are not group executable by default

```
#! ls -al target/docker/stage/opt/docker/bin
total 28K
drwxr-xr-x 2 wassj dialout 4.0K Jan 17 08:38 ./
drwxr-xr-x 4 wassj dialout 4.0K Jan 17 08:38 ../
-rwxr--r-- 1 wassj dialout 9.2K Jan 17 08:38 example-openshift-read-only*
-rw-r--r-- 1 wassj dialout 5.1K Jan 17 08:38 example-openshift-read-only.bat
```
---

Executables wont work in OpenShift like this
```
#! docker run --rm -it myimage ls -al /opt/docker/bin
total 28
drwxr-xr-x 2 daemon root 4096 Jan 17 13:45 .
drwxr-xr-x 1 daemon root 4096 Jan 17 13:45 ..
-rwxr--r-- 1 daemon root 9411 Jan 17 13:45 example-openshift-read-only
-rw-r--r-- 1 daemon root 5210 Jan 17 13:45 example-openshift-read-only.bat
```


Multistage Dockerfile would look something like this

```dockerfile
FROM openjdk:8-jre-slim
WORKDIR /opt/docker
ADD opt /opt
RUN chgrp -R 0 /opt && chmod -R g=u /opt

FROM openjdk:8-jre-slim
COPY --from=0 /opt/docker /opt/docker
USER daemon
ENTRYPOINT []
CMD []
```


and now, it works

```
#! docker run --rm -it myimage:multi ls -al /opt/docker/bin
total 28
drwxrwxr-x 2 root root 4096 Jan 17 14:57 .
drwxr-xr-x 4 root root 4096 Jan 17 14:59 ..
-rwxrwxr-- 1 root root 9411 Jan 17 14:57 example-openshift-read-only
-rw-rw-r-- 1 root root 5210 Jan 17 14:57 example-openshift-read-only.bat
```


### corrections

- A regular user cannot set root group 0, which is why the build script had `if [[ $(id -u) -eq 0 ]]; then`, only CI or sudo can produce OpenShift images
    - which is a great reason to adopt a multistage build


```
#! chgrp 0 example-openshift-read-only
chgrp: changing group of 'example-openshift-read-only': Operation not permitted
```
---

### other notes
- It pays to make sure the configuration you create works both in openshift and out, it sucks to produce an image you cant run on your local machine for development



### versions and features
- Multistage added in 17.05 https://docs.docker.com/develop/develop-images/multistage-build/
- chown on add added in 17.09 https://github.com/docker/docker-ce/releases/tag/v17.09.0-ce
- the latest openshift, v3.11, at 1.13 https://docs.openshift.com/container-platform/3.11/release_notes/ocp_3_11_release_notes.html#ocp-311-about-this-release

