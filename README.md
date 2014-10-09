# Brickspace

An iPad application that counts your Lego bricks and tells you what to build.

By [Anson Jablinski](http://ansonj.org). Created for the [University of Houston](http://uh.edu)'s 2014 Summer Undergraduate Research Fellowship project, and developed under the supervision of Ioannis Kakadiaris and the [UH Computational Biomedicine Laboratory](http://cbl.uh.edu/).

## Requirements

The [OpenCV](http://opencv.org) framework for iOS (not included) is required to build Brickspace. OpenCV is used to detect bricks in the captured image and estimate their color.

## Download

If you'd just like to run Brickspace, the app is available as a [free download from the iOS App Store](https://itunes.apple.com/us/app/brickspace/id922275889?ls=1&mt=8).

## Read more

Detailed information about the app is available at [the project website](http://ansonj.org/brickspace).

There also exists [a research version](https://github.com/ansonj/Brickspace/tree/structureEnabled) of the application. This version optionally uses the [Structure Sensor](http://structure.io) by Occipital to estimate the size of bricks. I've removed this feature from the public App Store version of Brickspace, but I encourage you to [read more about how it worked](http://ansonj.org/blog/2014/10/2/brickspace-and-the-structure-sensor) if you're interested.

## Class diagram

![Class diagram](classdiagram.png "Class diagram")
