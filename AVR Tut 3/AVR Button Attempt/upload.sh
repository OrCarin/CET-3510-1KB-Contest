#!/bin/bash
avrdude -F -p m328p -c stk500v1 -P /dev/cu.usbmodemFA131 -U flash:w:main.hex
