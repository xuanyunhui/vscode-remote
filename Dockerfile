FROM quay.xiaodiankeji.net/ruining/fedora-systemd:latest
MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV container docker

RUN pip install ansible_alicloud

COPY vscode-remote.yaml /tmp/vscode-remote.yaml
RUN ansible-playbook /tmp/vscode-remote.yaml

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/sbin/init"]
