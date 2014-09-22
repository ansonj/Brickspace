//
//  BKPScannedImageAndBricks.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPKeypointBrickPair.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <Structure/Structure.h>

@interface BKPScannedImageAndBricks : NSObject

- (id)initWithAVFColorBuffer:(CMSampleBufferRef)buffer;
- (id)initWithSTColorBuffer:(CMSampleBufferRef)buffer
			  andDepthFrame:(STDepthFrame *)depthFrame;

- (UIImage *)sourceImage;
- (UIImage *)processedImage;
- (UIImage *)thumbnailImage;

- (void)addKeypointAtX:(float)x andY:(float)y;
- (void)removeKeypointNearestToX:(float)x andY:(float)y;
- (void)removeCurrentlyHighlightedKeypoint;

- (BKPKeypointBrickPair *)getCurrentlyHighlightedKeypointPair;
- (void)highlightNextKeypoint;
- (void)highlightPreviousKeypoint;

- (void)resetProcessedImage;

- (NSSet *)bricksFromImage;

@end
