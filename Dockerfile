FROM ruby:3.0

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    gdb \
    valgrind \
    strace

WORKDIR /myapp
COPY . .
