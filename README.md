notes on openshift and sbt
===

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


Executables are not group executable by default

```
#! ls -al target/docker/stage/opt/docker/bin
total 28K
drwxr-xr-x 2 wassj dialout 4.0K Jan 17 08:38 ./
drwxr-xr-x 4 wassj dialout 4.0K Jan 17 08:38 ../
-rwxr--r-- 1 wassj dialout 9.2K Jan 17 08:38 example-openshift-read-only*
-rw-r--r-- 1 wassj dialout 5.1K Jan 17 08:38 example-openshift-read-only.bat
```

Regular user cannot set root group 0

```
#! chgrp 0 example-openshift-read-only
chgrp: changing group of 'example-openshift-read-only': Operation not permitted
```

which is why the build script had `if [[ $(id -u) -eq 0 ]]; then`, only CI or sudo can produce OpenShift images
  - which is a great reason to adopt a [multistage build approach](https://github.com/sbt/sbt-native-packager/issues/1189#issuecomment-454629204)
