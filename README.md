# Brickspace

An iPad application that counts your Lego bricks and tells you what to build. Optionally works with the [Structure Sensor](http://structure.io) from Occipital.

By [Anson Jablinski](http://ansonj.org). Created for the [University of Houston](http://uh.edu)'s 2014 Summer Undergraduate Research Fellowship project, and developed under the supervision of Ioannis Kakadiaris and the [UH Computational Biomedicine Laboratory](http://cbl.uh.edu/).

## Requirements

1. iPad of your choice.
1. Building bricks of various colors. Designed for red, orange, yellow, green, blue, and black Lego 2x4 bricks.
1. A white or lightly-colored surface.

### Optional accessories

1. Structure Sensor with iPad mounting bracket.
1. Lego bricks in the same colors as above, but 2x1, 2x2, or 2x3.

## The process

1. Dump out your bricks onto your white surface.
1. Spread the bricks out a bit so that they're not touching each other.
1. Use the app to take a picture of the bricks. The app will detect the bricks in the image.
1. Review the results of the image capture and processing. You may need to change the size or color of the bricks. The app also tends to count extra shapes (like shadows) as bricks, which you can delete.
If you're scanning with a Structure Sensor, then the app will try to determine what size the bricks are (2x4, 2x3, etc.). Otherwise, the app assumes all bricks are 2x4.
1. The app will then give you custom model instructions using the bricks that it has detected. Build away!

## Limitations

- Structure Sensor: The app is roughly 50% accurate when estimating brick size with depth data from the Structure Sensor.
- Adding bricks: The app does not yet support tapping the image to add bricks that the image processing missed, but this will be supported in a future release.
- Available models: The app currently knows how to build three different models. More models will be available in future updates.
    1. Basic Tower: All of your 2x4s stacked on top of each other.
    1. Flat Pyramid: All of your 2x4s arranged into a pyramid.
    1. Spiral Tower: All of your 2x4s arranged into a square tower with jagged, spiraling edges and a colorful pattern.
- Scanning / image detection: The image processing stumbles over shadows and any patterns on the scanning surface. Small bricks that are close together are seen as one brick. Tweaking parameters to detect smaller objects often results in the detector registering the studs on top of a brick as bricks.
