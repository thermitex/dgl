# docker build -t dgl-cpu -f Dockerfile .
FROM dgl-base:latest

# Activate env
SHELL ["conda", "run", "--no-capture-output", "-n", "dgl-dev-cpu", "/bin/bash", "-c"]

# Copy code
COPY . /dgl
WORKDIR /dgl

# Build shared lib
ENV DGL_HOME=/dgl
RUN bash script/build_dgl.sh -c

# Python binding
WORKDIR /dgl/python
RUN python setup.py install
RUN python setup.py build_ext --inplace

# SSH
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i'' -e's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^#PermitEmptyPasswords no$/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]

RUN ["/bin/bash", "-i", "-c", "ssh-keygen -f ~/.ssh/id_rsa -N ''"]
RUN ["/bin/bash", "-i", "-c", "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"]
RUN ["/bin/bash", "-i", "-c", "cat /dgl/master.pub >> ~/.ssh/authorized_keys"]

# Generate workspace
RUN mkdir -p ~/workspace
RUN cp /dgl/dist_train/* ~/workspace/

WORKDIR /dgl
ENTRYPOINT bash /dgl/docker_entry.sh
