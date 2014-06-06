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

+ (BOOL)canBeBuiltFromBrickSet:(BKPBrickSet *)inputBricks {
	return [[self bricksToBeUsedInModelFromSet:inputBricks] brickCount] > 0;
}

+ (BKPRealizedModel *)createRealizedModelUsingBrickSet:(BKPBrickSet *)inputBricks {
	BKPRealizedModel *model = [[BKPRealizedModel alloc] initWithSourceDesignName:[self designName]];
	
	BKPBrickSet *bricksToUse = [self bricksToBeUsedInModelFromSet:inputBricks];
	
	// assign bricks (you have the perfect number) to the realized model
	int bricksUsedSoFar = 0;
	int totalBricksToUse = [bricksToUse brickCount];
	int currentX = 3.0 - sqrtf(1 + 8 * totalBricksToUse);
	int currentDirection = 1;
	int currentZ = 0;
	int currentRowCount = 0;
	int targetRowCount = (-1.0 + sqrtf(1 + 8 * totalBricksToUse)) / 2.0;
	while (bricksUsedSoFar < totalBricksToUse) {
		BKPBrick *currentBrick = [[bricksToUse setOfBricks] anyObject];
		
		BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
		placedBrick.brick = currentBrick;
		placedBrick.orientation = BKPPlacedBrickOrientationAlongXAxis;
		[placedBrick setX:currentX Y:0 andZ:currentZ];
		[model addPlacedBrick:placedBrick];
		
		[bricksToUse removeBrick:currentBrick];
		
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

+ (float)percentUtilizedIfBuiltWithSet:(BKPBrickSet *)inputBricks {
	assert([self canBeBuiltFromBrickSet:inputBricks]);
	
	return 100.0 * [[self bricksToBeUsedInModelFromSet:inputBricks] brickCount] / [inputBricks brickCount];
}

+ (BKPBrickSet *)bricksToBeUsedInModelFromSet:(BKPBrickSet *)inputBricks {
	BKPBrickSet *bricksToBeUsed = [BKPBrickSet set];
		
	for (BKPBrick *brick in [inputBricks setOfBricks]) {
		if ([brick height] == BKPBrickHeightFull && [brick size] == BKPBrickSize2x4) {
			[bricksToBeUsed addBrick:brick];
		}
	}
	
	int triangularIndex = (int)((-1.0 + sqrtf(1 + 8 * [bricksToBeUsed brickCount])) / 2.0);
	int numberOfBricksInPyramid = triangularIndex * (triangularIndex + 1) / 2.0;
	
	while ([bricksToBeUsed brickCount] > numberOfBricksInPyramid) {
		[bricksToBeUsed removeBrick:[[bricksToBeUsed setOfBricks] anyObject]];
	}
	
	return bricksToBeUsed;
}

@end
