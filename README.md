notes on openshift and sbt
===




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
