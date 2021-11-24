# Go cross compiler (xgo): Go develop layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM starslab/xgo2:base

LABEL MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Clone and bootstrap the latest Go develop branch
RUN $BOOTSTRAP_REPO master
ENV GO_VERSION 1173
