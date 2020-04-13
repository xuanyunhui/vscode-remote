FROM quay.xiaodiankeji.net/ruining/fedora-systemd:latest
MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV container docker

RUN dnf install -y python3-pip && pip install ansible_alicloud

COPY vscode-remote.yaml /opt/vscode-remote.yaml
RUN ansible-playbook /opt/vscode-remote.yaml

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/sbin/init"]
