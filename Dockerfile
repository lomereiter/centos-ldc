FROM blalor/centos

MAINTAINER Artem Tarasov <lomereiter@gmail.com>

ADD d-runtime-qsort.patch /tmp/d-runtime-qsort.patch
RUN chmod 644 /tmp/d-runtime-qsort.patch

ADD install-software.sh /tmp/install-software.sh
RUN chmod 755 /tmp/install-software.sh
RUN /tmp/install-software.sh
