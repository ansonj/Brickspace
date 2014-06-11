//
//  BKPDetectorParameterInitializer.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/5/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPDetectorParameterInitializer.h"

@implementation BKPDetectorParameterInitializer

+ (void)setParameters:(BKPDPIParameterSet)parameters forCounter:(BKPBrickCounter *)counter {
	switch (parameters) {
		case BKPDPIParameterSetDefault:
			[BKPDetectorParameterInitializer assignDefaultParamsToCounter:counter];
			break;
		case BKPDPIParameterSetLego1:
			[BKPDetectorParameterInitializer assignLego1ParamsToCounter:counter];
			break;
			
		default:
			break;
	}
}

+ (void)assignDefaultParamsToCounter:(BKPBrickCounter *)counter {
	counter.det_thresholdStep = 10;
	counter.det_minThreshold = 50;
	counter.det_maxThreshold = 220;
	counter.det_minRepeatability = 2;
	counter.det_minDistBetweenBlobs = 10;
	counter.det_filterByColor = YES;
	counter.det_blobColor = 0;
	counter.det_filterByArea = YES;
	counter.det_minArea = 0; // bum value
	counter.det_maxArea = 5000;
	counter.det_filterByCircularity = NO;
	counter.det_minCircularity = 0; // bum value
	counter.det_maxCircularity = FLT_MAX;
	counter.det_filterByInertia = YES;
	counter.det_minInertiaRatio = 0; // bum value
	counter.det_maxInertiaRatio = 0; // bum value
	counter.det_filterByConvexity = YES;
	counter.det_minConvexity = 0; // bum value
	counter.det_maxConvexity = FLT_MAX;
}

+ (void)assignLego1ParamsToCounter:(BKPBrickCounter *)counter {
	counter.det_thresholdStep = 5;
	counter.det_minThreshold = 0;
	counter.det_maxThreshold = 220;
	counter.det_minRepeatability = 4;
	counter.det_minDistBetweenBlobs = 0;
	counter.det_filterByColor = NO;
	counter.det_blobColor = 0;
	counter.det_filterByArea = YES;
	counter.det_minArea = 5000;
	counter.det_maxArea = FLT_MAX;
	counter.det_filterByCircularity = NO;
	counter.det_minCircularity = 0; // bum value
	counter.det_maxCircularity = FLT_MAX;
	counter.det_filterByInertia = NO;
	counter.det_minInertiaRatio = 0; // bum value
	counter.det_maxInertiaRatio = 1; // bum value
	counter.det_filterByConvexity = NO;
	counter.det_minConvexity = 0; // bum value
	counter.det_maxConvexity = FLT_MAX;
}

@end
