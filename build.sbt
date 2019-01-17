
name := "example-openshift-read-only"
version := "0.1"
scalaVersion := "2.12.7"

dockerBaseImage := "openjdk:8-jre-slim"
daemonGroup in Docker := "root"
dockerEntrypoint := Seq()
dockerUpdateLatest := true
dockerEnvVars += "PATH" → "$PATH:/opt/docker/bin"

enablePlugins(JavaServerAppPackaging, DockerPlugin)