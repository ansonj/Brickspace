//
//  BKP_GD_FlatPyramid.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKP_GD_FlatPyramid.h"

@implementation BKP_GD_FlatPyramid

+ (BOOL)shouldBeOfferedToUser {
	return YES;
}

+ (NSString *)name {
	return @"Flat Pyramid";
}

+ (BOOL)canBeBuiltFromBrickSet:(BKPBrickSet *)inputBricks {
	return [inputBricks brickCount] > 0;
}




+ (float)percentUtilizedIfBuiltWithSet:(BKPBrickSet *)inputBricks {
	assert([self canBeBuiltFromBrickSet:inputBricks]);
	
	int brickCount = (int)[inputBricks brickCount];
	
	return 100.0 * [self numberOfBricksUsedInPyramidIfGiven:brickCount] / brickCount;
}


// helpers

+ (float)numberOfBricksUsedInPyramidIfGiven:(int)bricks {
	// https://en.wikipedia.org/wiki/Triangular_number
	int triangularIndex = (int)((-1.0 + sqrtf(1 + 8 * bricks)) / 2.0);
	
	return triangularIndex * (triangularIndex + 1) / 2.0;
}

@end
