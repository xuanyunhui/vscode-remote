FROM registry-vpc.cn-beijing.aliyuncs.com/xdmirrors/fedora:latest
MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV container docker

RUN curl -o /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo && \
    curl -o /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo && \
    dnf install -y python3-pip && pip install ansible_alicloud

COPY vscode-remote.yaml /opt/vscode-remote.yaml
RUN ansible-playbook /opt/vscode-remote.yaml && \
    rm -f /opt/vscode-remote.yaml

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/sbin/init"]
