Description
============

Download and install the newest [CyanogenMod](http://www.cyanogenmod.org/) 
release for your phone. Supports sideloading for folks using full-phone encryption.

Automatically verifies checksums after downloading new images.

Dependencies
============

 - Android SDK (in $PATH)
 - sudo privileges (for executing `adb run-server`)

Usage
=====

Check the [CyanogenMod Downloads page](http://download.cyanogenmod.org/) for info on your device. 
Clone this repo. 
`cd` into it.
Run `./update-phone --build nightly --device mako`, substituting the appropriate arguments for your device.

To Do
=====
- write Vagrantfile to take care of dependencies
- package Adb as a Perl module
