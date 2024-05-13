# walk

This is a demo for mobile to try to count user steps for a game that will use step counter as a game element.

## Setup

This project is made with Godot Engine 4.2.2 (64bit on Windows).

On my decade old windows 10 laptop, it may throw up an "unable to initialize vulkan drivers" error. You can work around this by starting the engine with the `--rendering-driver opengl3` argument. For convenience, I've modified my godot shortcut to have this flag set automatically.

    * Right click on the shortcut icon and then click "Properties".
    * Under the "Shortcut" tab, look for the value next to "Target".
    * It should say something like "C:\Program Files\Godot Engine\Godot_v4.2.2-stable_win64.exe"
    * *Outside of the quotes* add the `--rendering-driver opengl3` flag, so:
      `"C:\Program Files\<etc>\Godot_v4.2.2-stable_win64.exe" --rendering-driver opengl3`

## Android plugin

TBD

## Debugging on real android phone

### Wireless debugging on Android

For every reboot of the computer, you must setup the adb to be connected to the device.

1. Hook up the phone to computer via USB (usb-c to usb-a cable).
1. Set up android bridge (adb) and add to path. Run `adb devices`. Make sure the phone is detected.
1. If not enabled already, go to developer settings and toggle "Enable wireless debugging on". Pair the device with the computer (skip this if already paired).
1. Run `adb tcpip <random port number>`. It does not matter which port num you use, as long as nothing else is using it.
1. Run `adb connect <ip address of phone>:<port num of phone>`. This should be listed under "IP address & Port" in the Wireless Debugging menu of the developer options.
1. `adb devices` should now list two entries for the device. You can disconnect the usb cable now.
1. Wireless debugging should be set up now. You can run the debugger on the device wirelessly by click on the play button that looks like a TV in the upper right corner.
1. If this is not working, make sure you go to "Debug" in the godot menu and check "Deploy with Remote Debug".
1. Next, click on "Editor > Editor Settings > Export > Android" and check "Use Wi-Fi for Remote Debug".
