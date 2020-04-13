FROM quay.xiaodiankeji.net/ruining/fedora:31
MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV container docker

RUN dnf -y update && dnf clean all

RUN dnf -y install systemd python3-pip && dnf clean all && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN pip install ansible_alicloud

ADD vscode-remote.yaml /tmp/vscode-remote.yaml
RUN ansible-playbook /tmp/vscode-remote.yaml

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/sbin/init"]
