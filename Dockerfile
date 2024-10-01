# First stage builds the application
FROM ubi8/nodejs-20 as builder

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD * /tmp/src
ADD app.js /tmp/src
RUN chown -R 1001:0 /tmp/src
USER 1001

# Install the dependencies
RUN npm install express body-parser axios

# Second stage copies the application to the minimal image
FROM ubi8/nodejs-20-minimal

# Copy the application source and build artifacts from the builder image to this one
COPY --from=builder /tmp/src $HOME


USER root 
RUN microdnf -y install wget &&\
    microdnf -y install gzip &&\
    microdnf -y install vi &&\
    microdnf -y install tar
USER 1001

RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-amd64-rhel8.tar.gz &&\
   tar xzvf openshift-client-linux-amd64-rhel8.tar.gz -C /usr/bin/

# Install the dependencies
RUN npm install express body-parser axios

# Set the default command for the resulting image
EXPOSE 3000
CMD ["node", "app.js"]
# CMD node app.js
# CMD /bin/bash

