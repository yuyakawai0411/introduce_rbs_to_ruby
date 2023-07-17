FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    gdb \
    valgrind \
    strace

WORKDIR /myapp
COPY . .
