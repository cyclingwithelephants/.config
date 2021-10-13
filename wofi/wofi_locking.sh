#!/usr/bin/env bash

# Unfortunately wofi doesn't seem to have a locking machanism i.e. when we open it 10 times we get 10 wofi windows. We use flock to implement this behavious

flock --nonblock /tmp/wofi.lock  wofi "$@"

