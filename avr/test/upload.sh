#!/bin/bash
avrdude -F -p m328p -c stk500v1 -P /dev/ttyACM0 -U flash:w:test.hex
