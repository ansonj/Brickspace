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

+ (NSString *)designName {
	return @"Flat Pyramid";
}

+ (NSString *)designDescription {
	return @"A triangular pyramid, only one brick deep, of full-height 2x4s.";
}

+ (NSString *)description {
	return [NSString stringWithFormat:@"GenericDesign %@: %@", [self designName], [self designDescription]];
}

+ (BOOL)canBeBuiltFromBricks:(NSSet *)inputBricks {
	return [[self bricksToBeUsedInModelFromSet:inputBricks] count] > 0;
}

+ (BKPRealizedModel *)createRealizedModelUsingBricks:(NSSet *)inputBricks {
	BKPRealizedModel *model = [[BKPRealizedModel alloc] initWithSourceDesignName:[self designName]];
	
	NSMutableSet *bricksToUse = [NSMutableSet setWithSet:[self bricksToBeUsedInModelFromSet:inputBricks]];
	
	// assign bricks (you have the perfect number) to the realized model
	int bricksUsedSoFar = 0;
	int totalBricksToUse = (int)[bricksToUse count];
	int currentX = 3.0 - sqrtf(1 + 8 * totalBricksToUse);
	int currentDirection = 1;
	int currentZ = 0;
	int currentRowCount = 0;
	int targetRowCount = (-1.0 + sqrtf(1 + 8 * totalBricksToUse)) / 2.0;
	while (bricksUsedSoFar < totalBricksToUse) {
		BKPBrick *currentBrick = [bricksToUse anyObject];
		
		BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
		placedBrick.brick = currentBrick;
		placedBrick.isRotated = NO;
		[placedBrick setX:currentX Y:0 andZ:currentZ];
		[model addPlacedBrick:placedBrick];
		
		[bricksToUse removeObject:currentBrick];
		
		bricksUsedSoFar++;
		
		currentRowCount++;
		if (currentRowCount == targetRowCount) {
			currentDirection *= -1;
			currentX += currentDirection * 2;
			currentZ++;
			currentRowCount = 0;
			targetRowCount--;
		} else {
			currentX += currentDirection * 4;
		}
		
	}
	
	return model;
}

+ (float)percentUtilizedIfBuiltWithSet:(NSSet *)inputBricks {
	assert([self canBeBuiltFromBricks:inputBricks]);
	
	return 100.0 * [[self bricksToBeUsedInModelFromSet:inputBricks] count] / [inputBricks count];
}

+ (NSSet *)bricksToBeUsedInModelFromSet:(NSSet *)inputBricks {
	NSMutableSet *bricksToBeUsed = [NSMutableSet set];
		
	for (BKPBrick *brick in inputBricks) {
		if (brick.height == 3 && brick.shortSideLength == 2 && brick.longSideLength == 4) {
			[bricksToBeUsed addObject:brick];
		}
	}
	
	int triangularIndex = (int)((-1.0 + sqrtf(1 + 8 * [bricksToBeUsed count])) / 2.0);
	int numberOfBricksInPyramid = triangularIndex * (triangularIndex + 1) / 2.0;
	
	while ([bricksToBeUsed count] > numberOfBricksInPyramid) {
		[bricksToBeUsed removeObject:[bricksToBeUsed  anyObject]];
	}
	
	return bricksToBeUsed;
}

@end
