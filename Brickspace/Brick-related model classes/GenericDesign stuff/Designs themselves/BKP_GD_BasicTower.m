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

+ (NSString *)description {
	return [NSString stringWithFormat:@"GenericDesign %@: %@", [self designName], [self designDescription]];
}

+ (BOOL)canBeBuiltFromBricks:(NSSet *)inputBricks {
	return [[self bricksToBeUsedInModelFromSet:inputBricks] count] >= 2;
}

+ (BKPRealizedModel *)createRealizedModelUsingBricks:(NSSet *)inputBricks {
	BKPRealizedModel *model = [[BKPRealizedModel alloc] initWithSourceDesignName:self.designName];
	
	NSSet *bricksToUse = [self bricksToBeUsedInModelFromSet:inputBricks];
	
	float zCoord = 0;
	for (BKPBrick *brick in bricksToUse) {
		BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
		placedBrick.brick = brick;
		placedBrick.orientation = BKPPlacedBrickOrientationAlongXAxis;
		[placedBrick setX:0 Y:0 andZ:zCoord];
		zCoord++;
		[model addPlacedBrick:placedBrick];
	}
	
	return model;
}

+ (float)percentUtilizedIfBuiltWithSet:(NSSet *)inputBricks {
	assert([self canBeBuiltFromBricks:inputBricks]);
	
	return 100;
}

+ (NSSet *)bricksToBeUsedInModelFromSet:(NSSet *)inputBricks {
	NSMutableSet *bricksToBeUsed = [NSMutableSet set];
	
	for (BKPBrick *brick in inputBricks) {
		if ([brick height] == BKPBrickHeightFull && [brick size] == BKPBrickSize2x4) {
			[bricksToBeUsed addObject:brick];
		}
	}
	
	return [NSSet setWithSet:bricksToBeUsed];
}

@end
