# Readme

This is a series of re-writen scripts for use with the X735 Power supply control board for use with the Rpi <br>
I've also included some notes here on how the GPIO pins work and some relevant links

  * https://raspberrypiwiki.com/X735
  * https://github.com/geekworm-com/x730-script
  * https://github.com/Tristan79/x720
  * https://github.com/Tristan79/x720/blob/master/README.md

## Scripts

  * **src/original** - original scripts, I had trouble getting these to recognise the difference between reboot and shutdown
  * **src/modifed/x730-shutdown.sh** - triggers a shutdown by simulating a button press on the front of the psu
  * **src/modified/x730-daemon.sh** - daemon scrip that sets GPIO17 to high, and monitors GPIO4 as an input to trigger a shutdown / reboot
  * **src/modified/openrc/x730-openrc** - can be placed under /etc/init.d/ for use as a service

I had trouble with the original script in that it would always trigger a shutdown for some reason on a short or long button press. <br>
So I modified them slighlty and added an openrc file for use on bootup, since gentoo doesn't use rc.local like raspian


## Fan

Typically inside a geekworm enclosure there are two fans <br>
one powered directly from 5V, a second mounted on the x735 above the Rpi

The x735 Fan is automatic in terms of speed, some how picks up on the temperature
(I'm assuming via it's own temperature sensor since there's no GPIO communication for that)

The fan has 3 speed settings

  * Board temperature <34C - Fan running at low speed
  * Board temperature >34C - Fan running at medium speed
  * Board temperature >45C - Fan running at full speed

## GPIO

There are 3 gpio pins used by the X735, on they're website they just label it as for use with "power management"
With a bit of experimentation I've discovered.

  * **GPIO18** - output - this is the same as pushing the power button, if left on for too long, will cause a full power off
  * **GPIO17** - output - when set to 1, puts the power control board into a special mode to signal on GPIO4 when the power switch is pressed
  * **GPIO4** - input - signals back when the power button is pressed but only when GPIO17 is set to 1

With **GPIO18** this is an output which is identical to pushing the power button on the front of the device. <br>
if set to 1 for more than 8 seconds this will force the power off similar to holding down the power switch on an ATX supply. <br>
The x730-shutdown.sh script just raises pin18 to 1 for a fixed time to trigger the shutdown process via the other daemon script. <br>
It's not normally used to force power off the machine.


## Modes of Operation

The X735 board has two modes of operation depending on if GPIO17 is set to 0 or 1


### GPIO17 = 0 (default)

In this mode the power switch dims slighlty when pushed (or if GPIO18 is triggered) <br>
no feedback is sent via GPIO pin 4, and the only action you can take is to hold down the power switch more than 7 seconds

Typically to shutdown the system you'd need to trigger a "shutdown -h now" from the console or ssh session. <br>
Then once the OS had finsihed unmounting everything, manually power the box off by holding down the button for more than 7 seconds.


### GPIO17 = 1 Power Management mode

In this mode

When the psu switch is pressed for 1 - 2 seconds <br>
power switch led will flash quickly <br>
A pulse of 1's will be sent to GPIO4 to trigger a reboot in software (short period, less than 600)

When the psu switch is pressed for 3 - 7 seconds <br>
power switch led will flash slowly <br>
A pulse of 1's will be sent to GPIO4 to trigger a shutdown in software (long period, longer than 600 typically up to 49603)

Additionally in shutdown mode the x735 board will pick up on when the rpi board is halted / shutdown
and will then kill the power to the rpi / Hard disk board if one is connected.
I suspect it's detecting a low on GPIO17 during the flashing period but I've not tested this.
