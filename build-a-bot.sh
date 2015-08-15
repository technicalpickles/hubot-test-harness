#!/bin/bash

[[ -d hubot-under-test ]] && rm -rf hubot-under-test
mkdir hubot-under-test
cd hubot-under-test
yo hubot:app --adapter=irc --defaults

# Hack to install an 'npm link'ed version of Hubot
npm install "$(npm link hubot | awk -F"->" '{print $NF}' | tail -n 1)"
