# Plumi video hosting Dockerfile
#
# (C) 2017 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# Note: Plumi was last I checked licensed GPLv2+ but included some other
# imported code with other licenses.  Make sure you check this on your own.

# Baseimage (Ubuntu based):  Credits: https://github.com/phusion/baseimage-docker/
# (If you feel more comfortable with a standard distro image, you might change,
# but this works quite well for daemons/services).
FROM phusion/baseimage:latest
ENV PLUMI_VERSION=4.5rc1

# Your settings here
ENV SERVER_NAME=dummy.foo.bar
ENV VIDEOSERVER_NAME=videodummy.foo.bar

MAINTAINER Gunnar Andersson <gand@acm.org>

# As instructed in the README https://github.com/plumi/plumi.app/
RUN apt-get update;  apt-get install -y build-essential pkg-config git-core python-dev libssl-dev zlib1g-dev libxslt1-dev libjpeg62-dev groff-base python-virtualenv vim libpcre3 libpcre3-dev ffmpeg

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development.
#ADD dummy /tmp/dummy

# Clean up APT
RUN apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/plumi/plumi.app 

RUN useradd zope 
RUN useradd www-data || true  # This failed I think

WORKDIR plumi.app

# Assuming you want to run a fixed known version...
RUN git checkout $PLUMI_VERSION -b this

# Modify site config with your settings
ADD site.cfg site.cfg

RUN virtualenv --no-setuptools .

RUN ./bin/python bootstrap.py && ./bin/buildout -v

# For a test installation it's necessary to resolve the IP addresses somehow,
# for example hosts file.  (For a real installation remove this and let DNS
# resolve them).

# Actually, you'll be accessing the service from outside your docker container
# presumably - so you may need to set the docker host's /etc/hosts to something
# similar, (or at whatever computer you are testing your setup from)

RUN echo "127.0.0.1 $SERVER_NAME $VIDEOSERVER_NAME" >>/etc/hosts

# This is just to make sure it also matches site config
# (For all other settings, put them in site.cfg directly)
RUN sed -i "s/www-server-name.*/www-server-name = $SERVER_NAME/" site.cfg
RUN sed -i "s/www-videoserver-name.*/www-videoserver-name = $VIDEOSERVER_NAME/" site.cfg

# Add service script for "runit" i.e the init/pid 1 used by phusion/baseimage
# Just point it to plumi's own supervisor daemon
RUN mkdir /etc/service/plumi && cd /etc/service/plumi && ln -s /plumi.app/bin/supervisord run

# Use baseimage-docker's init system as default command
CMD ["/sbin/my_init"]

