//
//  BKPKeypointBrickPair.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPKeypointBrickPair.h"

@implementation BKPKeypointBrickPair

- (id)init {
	return [self initWithKeypoint:cv::KeyPoint() andBrick:nil];
}

- (id)initWithKeypoint:(cv::KeyPoint)keypoint {
	return [self initWithKeypoint:keypoint andBrick:nil];
}

- (id)initWithKeypoint:(cv::KeyPoint)keypoint andBrick:(BKPBrick *)brick {
	self = [super init];
	
	if (self) {
		[self setKeypoint:keypoint];
		[self setBrick:brick];
	}
	
	return self;
}

@end
