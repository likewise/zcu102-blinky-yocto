#!/bin/sh

# this scripts initiates a tmux setup for quick development iterations
# on major components

SESSIONNAME=zcu102
DIR=$PWD
BUILDDIR=build

#BUILDTMP=tmp
# currently configured to work in libc-dependent dir
BUILDTMP=tmp
#BUILDTMP=tmp-glibc
#BUILDTMP=tmp-musl

tmux start-server

#tmux kill-session -t ${SESSIONNAME}

mkdir -p ${DIR}/${BUILDDIR}/${BUILDTMP}
(cd ${DIR}/${BUILDDIR} && sudo -n mount -t tmpfs tmpfs ./tmp || echo "Not mounting tmpfs on build/tmp")

mkdir -p ${DIR}/${BUILDDIR}/${BUILDTMP}/work
mkdir -p ${DIR}/${BUILDDIR}/${BUILDTMP}/deploy/images/zcu102-zynqmp

tmux has-session -t ${SESSIONNAME}
if [ $? -gt 0 ]; then
  echo "Session ${SESSIONNAME} not found. Creating new session."
  tmux new-session -d -s ${SESSIONNAME}

  # CTRL-D will exit the shell only after three consecutive CTRL-D
  # Typically the user wants to detach (CTRL-B d) instead of closing the shell.
  tmux set-environment -g 'IGNOREEOF' 3

  tmux new-window -d -k -t ${SESSIONNAME}:0 -n source -c ${DIR}
  tmux new-window -d -k -t ${SESSIONNAME}:1 -n build -c ${DIR}
#  tmux send-keys -t ${SESSIONNAME}:build ". ./openembedded-core/oe-init-build-env ${BUILDDIR}/" C-m
  tmux send-keys -t ${SESSIONNAME}:build ". ./poky/oe-init-build-env ${BUILDDIR}/" C-m
  tmux new-window -d -k -t ${SESSIONNAME}:2 -n work -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work
  tmux new-window -d -k -t ${SESSIONNAME}:3 -n deploy -c ${DIR}/${BUILDDIR}/${BUILDTMP}/deploy
  tmux new-window -d -k -t ${SESSIONNAME}:4 -n images -c ${DIR}/${BUILDDIR}/${BUILDTMP}/deploy/images/zcu102-zynqmp

  # SMARC remote syslog
  tmux new-window -d -k -t ${SESSIONNAME}:5 -n syslog -c ${DIR}
  tmux send-keys -t ${SESSIONNAME}:syslog "tail -F /var/log/remote/smarc.log" C-m

  # Qt app
  tmux new-window -d -k -t ${SESSIONNAME}:6 -n qml \
    -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work/corei7-64-oe-linux/opengl-with-qml/1.0.0-r0/git

  # Qt plug-in
  tmux new-window -d -k -t ${SESSIONNAME}:7 -n kms \
    -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work/corei7-64-oe-linux/eglfs-kms-axon/1.0.0-r0/git

  # XDMA kernel driver
  tmux new-window -d -k -t ${SESSIONNAME}:8 -n xdma \
    -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work/congatec_tca5_64-oe-linux*/xdma-smarc/git-r0/git/

  # Audio app
  tmux new-window -d -k -t ${SESSIONNAME}:9 -n audio \
    -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work/corei7-64-oe-linux*/audio-app/*/git

  # Audio app
  tmux new-window -d -k -t ${SESSIONNAME}:10 -n ssh

  # Kernel source
  tmux new-window -d -k -t ${SESSIONNAME}:11 -n kernel-src \
    -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work/congatec_tca5_64-oe-linux*/linux*/*/git

  # Kernel build
  tmux new-window -d -k -t ${SESSIONNAME}:12 -n kernel-build \
    -c ${DIR}/${BUILDDIR}/${BUILDTMP}/work/congatec_tca5_64-oe-linux*/linux*/*/git

else
  echo "Attaching to existing session."
fi

tmux list-clients -t ${SESSIONNAME}

#if [ "$DISPLAY" != "" ]; then
#  gnome-terminal \
#    --tab --title=source -e tmux attach-session -t ${SESSIONNAME}:0 \
#    --tab --title=build -e tmux attach-session -t ${SESSIONNAME}:1
#else
  :
  tmux attach-session -t ${SESSIONNAME}
#fi
