# Appname

Image based on Ubuntu Core and monitored by s6-overlay.

#### weekly builds @Saturday at 3:00 (AM)
* Rebuilds new base image from scratch @https://partner-images.canonical.com/core/${REL}/current/ubuntu-${REL}-core-cloudimg-${ARCH}-root.tar.gz
  * Base OS is updated
  * Packages are updated
  * Application within image(container) gets updated if new release is available. 
  * Don't manual update Application within container unless you know what you're 		doing.
  * Application settings are restored if mapped correctly to a host folder, your /config folder and settings will be preserved

### docker setup

```
docker create \
  --name=containername \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Amsterdam \
  -p 80:80 \
  -p 443:443 `#optional` \
  -v /path/to/config:/config \
  --restart unless-stopped \
  thies88/imagename
```
After starting the container check log for instructions. go to https://ipdockerhost/spotweb

### update your container:

Via Docker Run/Create

    -Update the image: docker pull thies88/containername
    -Stop the running container: docker stop containername
    -Delete the container: docker rm containername
    -Recreate a new container with the same docker create parameters used at the setup of the container (if mapped correctly to a host folder, your /config folder and settings will be preserved)
    -Start the new container: docker start containername
    -You can also remove the old dangling images: docker image prune

Unraid users can use "Check for updates" within Unraid WebGui

&nbsp;

A custom base image built with [Ubuntu Core](https://partner-images.canonical.com) and [S6 overlay](https://github.com/just-containers/s6-overlay) Based on: https://github.com/linuxserver/docker-baseimage-ubuntu