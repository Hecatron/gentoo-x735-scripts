#!/bin/bash

# First setup gpio4 as an input, this will tell us when someone has triggered
# the power switch on the front
SHUTDOWN=4
echo "$SHUTDOWN" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$SHUTDOWN/direction

# Next setup gpio 17 as an output, set this to 1 to switch the x735 / x730
# into a special mode where it will feed a pulse of 1's back through gpio4
# depending on how long the switch was pressed for
BOOT=17
echo "$BOOT" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$BOOT/direction
echo "1" > /sys/class/gpio/gpio$BOOT/value

# Between 200 - 600 pules trigger a reboot
# any longer trigger a shutdown
REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600


while [ 1 ]; do

  # Check the input of GPIO4 to see when it rises to 1
  shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
  if [ $shutdownSignal = 0 ]; then
    /bin/sleep 0.2
  else

    # Figure out how long it's been pressed for
    pulseStart=$(date +%s%N | cut -b1-13)
    pulseLength=0
    while [ $shutdownSignal = 1 ]; do
      /bin/sleep 0.02
      pulseLength=$(($(date +%s%N | cut -b1-13)-$pulseStart))
      shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)

      # Trigger a shutdown of the OS
      if [ $pulseLength -gt $REBOOTPULSEMAXIMUM ]; then
        echo "X735 Shutting down"
        #echo $pulseLength
        sudo poweroff -h
        exit
      fi

    done

    # Trigger a reboot of the OS
    if [ $pulseLength -gt $REBOOTPULSEMINIMUM ]; then
      echo "X735 Rebooting"
      #echo $pulseLength
      sudo reboot
      exit
    fi

  fi
done

