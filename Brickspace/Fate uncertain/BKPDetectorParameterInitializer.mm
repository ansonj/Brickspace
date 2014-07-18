//
//  BKPDetectorParameterInitializer.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/5/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import "BKPDetectorParameterInitializer.h"

@implementation BKPDetectorParameterInitializer

//???: change thresholdStep to lower? http://docs.opencv.org/modules/features2d/doc/common_interfaces_of_feature_detectors.html#simpleblobdetector may help the generation of binary images

+ (NSArray *)getDefaultParameters {
	cv::SimpleBlobDetector::Params params;
	params.thresholdStep = 10;
	params.minThreshold = 50;
	params.maxThreshold = 220;
	params.minRepeatability = 2;
	params.minDistBetweenBlobs = 10;
	params.filterByColor = YES;
	params.blobColor = 0;
	params.filterByArea = YES;
	params.minArea = 0; // bum value
	params.maxArea = 5000;
	params.filterByCircularity = NO;
	params.minCircularity = 0; // bum value
	params.maxCircularity = FLT_MAX;
	params.filterByInertia = YES;
	params.minInertiaRatio = 0; // bum value
	params.maxInertiaRatio = 0; // bum value
	params.filterByConvexity = YES;
	params.minConvexity = 0; // bum value
	params.maxConvexity = FLT_MAX;
	
	NSValue *defaultParamValue = [NSValue valueWithBytes:&params objCType:@encode(cv::SimpleBlobDetector::Params)];
	
	return @[defaultParamValue];
}

+ (NSArray *)getParametersForLegoUpClose {
	NSMutableArray *legoUpCloseParams = [NSMutableArray array];
	
	// original set
	{
		cv::SimpleBlobDetector::Params params;
		params.thresholdStep = 5;
		params.minThreshold = 0;
		params.maxThreshold = 220;
		params.minRepeatability = 4;
		params.minDistBetweenBlobs = 0;
		params.filterByColor = NO;
		params.blobColor = 0;
		params.filterByArea = YES;
		params.minArea = 5000;
		params.maxArea = FLT_MAX;
		params.filterByCircularity = NO;
		params.minCircularity = 0; // bum value
		params.maxCircularity = FLT_MAX;
		params.filterByInertia = NO;
		params.minInertiaRatio = 0; // bum value
		params.maxInertiaRatio = 1; // bum value
		params.filterByConvexity = NO;
		params.minConvexity = 0; // bum value
		params.maxConvexity = FLT_MAX;
		
		NSValue *paramValue = [NSValue valueWithBytes:&params objCType:@encode(cv::SimpleBlobDetector::Params)];
		
		[legoUpCloseParams addObject:paramValue];
	}
	
	// max area 10000
	{
		cv::SimpleBlobDetector::Params params;
		params.thresholdStep = 5;
		params.minThreshold = 0;
		params.maxThreshold = 220;
		params.minRepeatability = 4;
		params.minDistBetweenBlobs = 0;
		params.filterByColor = NO;
		params.blobColor = 0;
		params.filterByArea = YES;
		params.minArea =  5000;
		params.maxArea = 10000;
		params.filterByCircularity = NO;
		params.minCircularity = 0; // bum value
		params.maxCircularity = FLT_MAX;
		params.filterByInertia = NO;
		params.minInertiaRatio = 0; // bum value
		params.maxInertiaRatio = 1; // bum value
		params.filterByConvexity = NO;
		params.minConvexity = 0; // bum value
		params.maxConvexity = FLT_MAX;
		
		NSValue *paramValue = [NSValue valueWithBytes:&params objCType:@encode(cv::SimpleBlobDetector::Params)];
		
		[legoUpCloseParams addObject:paramValue];
	}
	
	return [NSArray arrayWithArray:legoUpCloseParams];
}

+ (NSArray *)getParametersForLegoAfarWithStructure {
	NSMutableArray *legoAfarParams = [NSMutableArray array];
	
	// minArea much smaller, for bricks that are far away
	if (YES) {
		cv::SimpleBlobDetector::Params params;
		params.thresholdStep = 5;
		params.minThreshold = 0;
		params.maxThreshold = 220;
		params.minRepeatability = 4;
		params.minDistBetweenBlobs = 0;
		params.filterByColor = NO;
		params.blobColor = 0;
		params.filterByArea = YES;
		params.minArea =   500;
		params.maxArea = 10000;
		params.filterByCircularity = NO;
		params.minCircularity = 0; // bum value
		params.maxCircularity = FLT_MAX;
		params.filterByInertia = NO;
		params.minInertiaRatio = 0; // bum value
		params.maxInertiaRatio = 1; // bum value
		params.filterByConvexity = NO;
		params.minConvexity = 0; // bum value
		params.maxConvexity = FLT_MAX;
		
		NSValue *paramValue = [NSValue valueWithBytes:&params objCType:@encode(cv::SimpleBlobDetector::Params)];
		
		[legoAfarParams addObject:paramValue];
	}
		
	return [NSArray arrayWithArray:legoAfarParams];
}

@end
