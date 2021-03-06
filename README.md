# Qt AR Demo

This is a small demonstration of the open-source augmented reality system part of the [Thymio programming adventure](https://github.com/aseba-community/thymio-adventure) game. The demo was developed as part of a bachelor thesis whose report can be found [here](https://github.com/aseba-community/transmem/releases/download/bachelor-thesis/report.pdf). The intend behind this demo is easiest understood by going through [these](https://github.com/aseba-community/transmem/releases/download/bachelor-thesis/presentation.pdf) slides.

## Authors and license

Please see the files [AUTHORS.md](AUTHORS.md) and [LICENSE.txt](LICENSE.txt).

## How to use AR

To see an AR world, you have to print markers, that you can find at https://github.com/aseba-community/thymio-adventure-assets/tree/master/markers.
The following images are used in this demo:
- [adahouse_3D.pdf](https://github.com/aseba-community/thymio-adventure-assets/raw/master/markers/adahouse_3D.pdf)
- [orangehouse_3D.pdf](https://github.com/aseba-community/thymio-adventure-assets/raw/master/markers/orangehouse_3D.pdf)
- [worldcenter_orig.png](https://github.com/aseba-community/thymio-adventure-assets/raw/master/markers/worldcenter_orig.png), at a size of 11 cm x 11 cm.

## Understanding the source tree

This repository makes heavy use of [git submodule](https://git-scm.com/docs/git-submodule) to include its dependencies:
```
. – this demo
├── transmem - spatio-temporal frame library
├── assets – visual assets for this demo
└── thymio-ar – Qt integration of the tracking library
	└── thymio-tracker – tracking library using OpenCV
```

## Linux and Android Compilation

This guide assumes a basic knowledge of Linux development tools.

### Pre-requisites

This documentation assumes you are using Ubuntu 16.04.
If you use another version, some packages might have different names or the compilation might not work at all (especially on older systems).

First, install a development environment.
In a terminal, type:
```sh
sudo apt-get install build-essential cmake-gui mesa-common-dev libglu1-mesa-dev git gitk libeigen3-dev libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libtiff-dev libjasper-dev libudev-dev
```

Then, install Qt 5 and Qt creator.
Go on the [Qt5 open source download page](https://www.qt.io/download-open-source/), and download the installer.
Run it in a terminal (the exact name of the file might change slightly):
```sh
chmod +x qt-unified-linux-x64-online.run
./qt-unified-linux-x64-online.run
```

Then, install and compile OpenCV.
Go on the [OpenCV download page](http://opencv.org/downloads.html), and download the Linux archive for version 3.X.
Unzip and compile it; in a terminal in the OpenCV directory:
```sh
mkdir -p build && cd build && cmake .. && make
```

You now have a development environment ready to compile the Thymio-AR-Demo on Ubuntu.

### Download

Download it with git and update submodules:
```sh
git clone --recursive https://github.com/fluckmic/thymio-ar-demo.git
```

### Work-around missing qgltf for Android

When compiling for Android, the `qgltf` binary is not provided in `android_armv7/bin`.
To work around this problem, in that directory, simply link the `gcc_64` version: `ln -s ../../gcc_64/bin/qgltf`.

### Compile

Launch Qt Creator and open `thymio-ar-demo.pro`.

Go to the _Projects_ tab, click _Configure Project_.

Still in the _Projects_ tab, go to _Desktop [...]_, select _Build_.
In _Build Steps_, click _Details_ on the _qmake_ pane.

In the additional arguments field, add:
```
"OPENCV_SRC=YOUR_OPENCV_SRC" "OPENCV_BIN=YOUR_OPENCV_BIN" "EIGEN_INCLUDE=/usr/include/eigen3/"
```

where `YOUR_OPENCV_SRC` is where you have unzipped OpenCV, and `YOUR_OPENCV_BIN` is where you have built it.
If you followed this document to build OpenCV, your `YOUR_OPENCV_BIN` is `YOUR_OPENCV_SRC/build`.

You can now run the app on your computer by clicking on the green run button at the bottom-left of the Qt Creator window.

### Android

First install the Ubuntu environment as described above.
Then, install the Android environment as [explained in the Qt5 documentation](http://doc.qt.io/qt-5/androidgs.html).

Then, go to the [OpenCV download page](http://opencv.org/downloads.html), and download the Android archive for version 3.X.

Launch Qt Creator and open `thymio-ar-demo.pro`.

Go to the _Projects_ tab, go to _Android [...]_, select _Build_.
In _Build Steps_, click _Details_ on the _qmake_ pane.

In the additional arguments field, add:
```
"OPENCV_SDK=YOUR_OPENCV_SDK" "EIGEN_INCLUDE=/usr/include/eigen3/" 
```

where `YOUR_OPENCV_SDK` is the directory where you unziped the OpenCV archive.

You can now deploy the app on your Android device by selecting the Android target in the bottom-left of the Qt Creator window, and then clicking the green run button.
