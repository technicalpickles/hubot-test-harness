#!/bin/bash

[[ -d hubot-under-test ]] && rm -rf hubot-under-test
mkdir hubot-under-test
cd hubot-under-test
yo hubot:app --adapter=irc --defaults
