#!/bin/bash

comm -23 <(equery b -n $(ldd * | grep lib64 | sed 's/(.*)//' | sed 's/^.*=> //' | sed 's/^\s//' | sort -u) | sed 's/(.*)//' | sort -u) <(equery l -F '$cp' @system)
