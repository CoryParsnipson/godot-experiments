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

#### Initial Setup

These steps need to be done once.

1. Go to "Debug" in the godot menu and check "Deploy with Remote Debug".
1. Next, click on "Editor > Editor Settings > Export > Android" and check "Use Wi-Fi for Remote Debug".
1. Hook up the phone to computer via USB (usb-c to usb-a cable).
1. Set up android bridge (adb) and add to path. Run `adb devices`. Make sure the phone is detected.
1. If not enabled already, go to developer settings and toggle "Enable wireless debugging on". Pair the device with the computer (skip this if already paired).
1. Run `adb tcpip <random port number>`. It does not matter which port num you use, as long as nothing else is using it.

#### Connecting to Device Wirelessly

These steps need to be repeated every time you want to debug wirelessly. (This means after every reboot of the computer or after a certain amount of time, the Android device will automatically disable wireless debugging.)

1. Browse to "System > Developer Options > Enable Wireless Debugging" on the Android device and toggle this on. Keep track of the ip address and port num displayed here.
1. Run `adb connect <ip address of phone>:<port num of phone>`.
1. `adb devices` should now list an entry for this device.
1. Wireless debugging should be set up now. You can run the debugger on the device wirelessly by click on the play button that looks like a TV in the upper right corner.
