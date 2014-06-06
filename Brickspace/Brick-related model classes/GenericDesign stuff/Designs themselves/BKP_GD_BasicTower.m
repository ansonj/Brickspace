//
//  BKP_GD_BasicTower.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKP_GD_BasicTower.h"

@implementation BKP_GD_BasicTower

+ (BOOL)shouldBeOfferedToUser {
	return YES;
}

+ (NSString *)designName {
	return @"Basic Tower";
}

+ (NSString *)designDescription {
	return @"A tower of full-height 2x4s stacked atop one another.";
}

+ (BOOL)canBeBuiltFromBrickSet:(BKPBrickSet *)inputBricks {
	return [[self bricksToBeUsedInModelFromSet:inputBricks] brickCount] >= 2;
}

+ (BKPRealizedModel *)createRealizedModelUsingBrickSet:(BKPBrickSet *)inputBricks {
	BKPRealizedModel *model = [[BKPRealizedModel alloc] initWithSourceDesignName:self.designName];
	
	BKPBrickSet *bricksToUse = [self bricksToBeUsedInModelFromSet:inputBricks];
	
	float zCoord = 0;
	for (BKPBrick *brick in [bricksToUse setOfBricks]) {
		BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
		placedBrick.brick = brick;
		placedBrick.orientation = BKPPlacedBrickOrientationAlongXAxis;
		[placedBrick setX:0 Y:0 andZ:zCoord];
		zCoord++;
		[model addPlacedBrick:placedBrick];
	}
	
	return model;
}

+ (float)percentUtilizedIfBuiltWithSet:(BKPBrickSet *)inputBricks {
	assert([self canBeBuiltFromBrickSet:inputBricks]);
	
	return 100;
}

+ (BKPBrickSet *)bricksToBeUsedInModelFromSet:(BKPBrickSet *)inputBricks {
	BKPBrickSet *bricksToBeUsed = [BKPBrickSet set];
	
	for (BKPBrick *brick in [inputBricks setOfBricks]) {
		if ([brick height] == BKPBrickHeightFull && [brick size] == BKPBrickSize2x4) {
			[bricksToBeUsed addBrick:brick];
		}
	}
	
	return bricksToBeUsed;
}

@end
