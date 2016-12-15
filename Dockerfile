FROM openshift/base-centos7

MAINTAINER Julian Tescher <julian@outtherelabs.com>

# Current stable version
ENV NGINX_VERSION=1.10.2

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Platform for serving static directories" \
      io.k8s.display-name="Nginx 1.10.2" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,html,nginx"

# Add yum repo for nginx
ADD etc/nginx.repo /etc/yum.repos.d/nginx.repo

# Install the current version
RUN yum install -y --setopt=tsflags=nodocs nginx-$NGINX_VERSION && \
    yum clean all -y

# Install source to image
COPY ./.s2i/bin/ /usr/libexec/s2i

# Copy the nginx config file
COPY ./etc/nginx.conf /etc/nginx/conf.d/default.conf

RUN  chmod -R 777 /var/log/nginx /var/cache/nginx/ /var/run \
     && chmod 644 /etc/nginx/* \
     && chmod 755 /etc/nginx/conf.d \
     && chmod 644 /etc/nginx/conf.d/default.conf

# Set to non root user provided by parent image
USER 1001

# Expose port 8080
EXPOSE 8080

# Run usage command by default
CMD ["/usr/libexec/s2i/usage"]
