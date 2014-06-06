//
//  BKPBrickCounter.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPBrickSet.h"

@interface BKPBrickCounter : NSObject


#pragma mark - Properties (primary)

@property (nonatomic) UIImage *sourceImage;
@property (nonatomic) UIImage *processedImage;


#pragma mark - Methods (primary)

- (id)initWithSourceImage:(UIImage *)newSourceImage;

- (BKPBrickSet *)countedSetOfBricks;
- (unsigned long)numberOfBricksDetected;


#pragma mark - Properties for parameters of detector

@property (nonatomic) float det_thresholdStep;
@property (nonatomic) float det_minThreshold;
@property (nonatomic) float det_maxThreshold;
@property (nonatomic) size_t det_minRepeatability;
@property (nonatomic) float det_minDistBetweenBlobs;

@property (nonatomic) bool det_filterByColor;
@property (nonatomic) unsigned det_blobColor;

@property (nonatomic) bool det_filterByArea;
@property (nonatomic) float det_minArea, det_maxArea;

@property (nonatomic) bool det_filterByCircularity;
@property (nonatomic) float det_minCircularity, det_maxCircularity;

@property (nonatomic) bool det_filterByInertia;
@property (nonatomic) float det_minInertiaRatio, det_maxInertiaRatio;

@property (nonatomic) bool det_filterByConvexity;
@property (nonatomic) float det_minConvexity, det_maxConvexity;


@end
