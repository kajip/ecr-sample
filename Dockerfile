#
# Copyright (c) 2017 BIGLOBE Inc. All rights reserved.
#
FROM alpine:latest

MAINTAINER Tomomi Kajita <t-kajita@biglobe.co.jp>

RUN apk update
RUN apk add bash

CMD echo "Hello, World!"