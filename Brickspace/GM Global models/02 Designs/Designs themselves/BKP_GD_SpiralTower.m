//
//  BKP_GD_BasicTower.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKP_GD_SpiralTower.h"

@implementation BKP_GD_SpiralTower

+ (BOOL)shouldBeOfferedToUser {
	return YES;
}

+ (NSString *)designName {
	return @"Spiral Tower";
}

+ (NSString *)designDescription {
	return @"a colorful, winding tower of full-height 2x4s that goes up and up and up";
}

+ (NSString *)description {
	return [NSString stringWithFormat:@"GenericDesign %@: %@", [self designName], [self designDescription]];
}

+ (BOOL)canBeBuiltFromBricks:(NSSet *)inputBricks {
	return [[self bricksToBeUsedInModelFromSet:inputBricks] count] >= 29;
}

+ (BKPRealizedModel *)createRealizedModelUsingBricks:(NSSet *)inputBricks {
	// We want to represent as many colors as possible, given what we have
	// This block will pare down the set of input bricks until we have the exact number needed to build a tower
	// WITHOUT removing the last brick in any present color
	NSMutableSet *bricksToUse = [NSMutableSet setWithSet:[self bricksToBeUsedInModelFromSet:inputBricks]];
	{
		int colorCount = [BKPBrickColorOptions colorCount];
		
		// This will only work if we have less than 29 colors
		assert(colorCount <= 29);
				
		NSMutableArray *colorCounts = [[NSMutableArray alloc] initWithCapacity:colorCount];
		{
			for (int i = 0; i < colorCount; i++) {
				NSSet *bricksWithColor = [bricksToUse objectsPassingTest:^BOOL(id obj, BOOL *stop) {
					BKPBrick *brick = obj;
					return [brick color] == i;
				}];
				[colorCounts addObject:[NSNumber numberWithUnsignedLong:[bricksWithColor count]]];
			}
		}
		
		int numberOfBricksToUse = 16 * ((int)(([bricksToUse count] - 13)/16.0)) + 13;
		
		int (^sumOfNumbersInArray)(NSArray *) = ^int(NSArray *array) {
			int sum = 0;
			for (NSNumber *number in array) {
				sum += [number intValue];
			}
			return sum;
		};
		
		while (sumOfNumbersInArray(colorCounts) > numberOfBricksToUse) {
			// Find the greatest element
			int indexOfMaxInArray = 0;
			for (int index = 1; index < colorCount; index++) {
				if ([colorCounts[index] intValue] > [colorCounts[indexOfMaxInArray] intValue])
					indexOfMaxInArray = index;
			}
			
			// Subtract one from it
			colorCounts[indexOfMaxInArray] = [NSNumber numberWithInt:([colorCounts[indexOfMaxInArray] intValue] - 1)];
		}
		
		// remove bricks from bricksToUse until the actual count matches the color count
		for (int colorIndex = 0; colorIndex < colorCount; colorIndex++) {
			int desiredNumberOfBricksWithColor = [colorCounts[colorIndex] intValue];
			NSSet *bricksWithColor = [bricksToUse objectsPassingTest:^BOOL(id obj, BOOL *stop) {
				BKPBrick *brick = obj;
				return brick.color == colorIndex;
			}];
			NSMutableSet *bricksWithColorMutable = [NSMutableSet setWithSet:bricksWithColor];
			while ([bricksWithColorMutable count] > desiredNumberOfBricksWithColor) {
				BKPBrick *brickToRemove = [bricksWithColorMutable anyObject];
				[bricksToUse removeObject:brickToRemove];
				[bricksWithColorMutable removeObject:brickToRemove];
			}
		}
	}
		
	// Now sort the bricks in color order. We want to go from black/blue at the bottom to red at the top
	NSMutableArray *bricksToUseInOrder = [[NSMutableArray alloc] initWithCapacity:[bricksToUse count]];
	{
		// colorCount will give us the number of available colors. We'll use this to run backwards
		int colorCount = [BKPBrickColorOptions colorCount];
		
		for (int currentColor = colorCount - 1; currentColor >= 0; currentColor--) {
			for (BKPBrick *brick in bricksToUse) {
				if (brick.color == currentColor)
					[bricksToUseInOrder addObject:brick];
			}
		}
		assert([bricksToUseInOrder count] == [bricksToUse count]);
	}
	
	
	// Now bricksToUseInOrder has the bricks in order (left to right) with a good ratio of colors

	// We'll build the base first, then the middle layers in sets of four, then the capstone.
	BKPRealizedModel *model = [[BKPRealizedModel alloc] initWithSourceDesignName:self.designName];

	float zCoord = 0;

	// Base two layers
	[self addLayer:1 toModel:model usingBricksFrom:bricksToUseInOrder atZ:zCoord];
	zCoord += 3;
	[self addLayer:2 toModel:model usingBricksFrom:bricksToUseInOrder atZ:zCoord];
	zCoord += 3;
	
	// Middle layers, in groups of four
	while ([bricksToUseInOrder count] > 5) {
		[self addLayer:3 toModel:model usingBricksFrom:bricksToUseInOrder atZ:zCoord];
		zCoord += 3;
		[self addLayer:4 toModel:model usingBricksFrom:bricksToUseInOrder atZ:zCoord];
		zCoord += 3;
		[self addLayer:1 toModel:model usingBricksFrom:bricksToUseInOrder atZ:zCoord];
		zCoord += 3;
		[self addLayer:2 toModel:model usingBricksFrom:bricksToUseInOrder atZ:zCoord];
		zCoord += 3;
	}
	
	// Capstone layers
	BKPPlacedBrick *capBrick1 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *capBrick2 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *capBrick3 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *capBrick4 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *capBrick5 = [[BKPPlacedBrick alloc] init];
	capBrick1.brick = [self popFirstItemInArray:bricksToUseInOrder];
	capBrick2.brick = [self popFirstItemInArray:bricksToUseInOrder];
	capBrick3.brick = [self popFirstItemInArray:bricksToUseInOrder];
	capBrick4.brick = [self popFirstItemInArray:bricksToUseInOrder];
	capBrick5.brick = [self popFirstItemInArray:bricksToUseInOrder];
	capBrick1.isRotated = YES;
	capBrick2.isRotated = YES;
	capBrick3.isRotated = NO;
	capBrick4.isRotated = NO;
	capBrick5.isRotated = YES;
	[capBrick1 setX:-1 Y:-1 andZ:zCoord];
	[capBrick2 setX:2 Y:0 andZ:zCoord];
	zCoord += 3;
	[capBrick3 setX:0 Y:-2 andZ:zCoord];
	[capBrick4 setX:1 Y:1 andZ:zCoord];
	zCoord += 3;
	[capBrick5 setX:0 Y:0 andZ:zCoord];
	[model addPlacedBrick:capBrick1];
	[model addPlacedBrick:capBrick2];
	[model addPlacedBrick:capBrick3];
	[model addPlacedBrick:capBrick4];
	[model addPlacedBrick:capBrick5];
	
	assert([bricksToUseInOrder count] == 0);
	
	return model;
}

+ (float)percentUtilizedIfBuiltWithSet:(NSSet *)inputBricks {
	assert([self canBeBuiltFromBricks:inputBricks]);
	
	int totalCount = (int)[inputBricks count];
	int availableCount = (int)[[self bricksToBeUsedInModelFromSet:inputBricks] count];
	
	return 100.0 * availableCount / totalCount;
}

+ (NSSet *)bricksToBeUsedInModelFromSet:(NSSet *)inputBricks {
	NSMutableSet *bricksToBeUsed = [NSMutableSet set];
	
	for (BKPBrick *brick in inputBricks) {
		if (brick.height == 3 && brick.shortSideLength == 2 && brick.longSideLength == 4) {
			[bricksToBeUsed addObject:brick];
		}
	}
	
	return [NSSet setWithSet:bricksToBeUsed];
}

#pragma mark - Layer helpers, specific to Spiral Tower

+ (BKPBrick *)popFirstItemInArray:(NSMutableArray *)array {
	BKPBrick *firstBrick = [array firstObject];
	[array removeObject:firstBrick];
	return firstBrick;
}

+ (void)addLayer:(int)layer toModel:(BKPRealizedModel *)model usingBricksFrom:(NSMutableArray *)bricks atZ:(float)z {
	BKPPlacedBrick *brick1 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *brick2 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *brick3 = [[BKPPlacedBrick alloc] init];
	BKPPlacedBrick *brick4 = [[BKPPlacedBrick alloc] init];
	brick1.brick = [self popFirstItemInArray:bricks];
	brick2.brick = [self popFirstItemInArray:bricks];
	brick3.brick = [self popFirstItemInArray:bricks];
	brick4.brick = [self popFirstItemInArray:bricks];
	
	switch (layer) {
		case 1:
		default:
		{
			brick1.isRotated = NO;
			brick2.isRotated = YES;
			brick3.isRotated = NO;
			brick4.isRotated = YES;
			[brick1 setX:-1 Y:-3 andZ:z];
			[brick2 setX:3 Y:-2 andZ:z];
			[brick3 setX:2 Y:2 andZ:z];
			[brick4 setX:-2 Y:1 andZ:z];
			break;
		}
		case 2:
		{
			brick1.isRotated = NO;
			brick2.isRotated = YES;
			brick3.isRotated = NO;
			brick4.isRotated = YES;
			[brick1 setX:0 Y:-3 andZ:z];
			[brick2 setX:3 Y:-1 andZ:z];
			[brick3 setX:1 Y:2 andZ:z];
			[brick4 setX:-2 Y:0 andZ:z];
			break;
		}
		case 3:
		{
			brick1.isRotated = NO;
			brick2.isRotated = YES;
			brick3.isRotated = NO;
			brick4.isRotated = YES;
			[brick1 setX:1 Y:-3 andZ:z];
			[brick2 setX:3 Y:0 andZ:z];
			[brick3 setX:0 Y:2 andZ:z];
			[brick4 setX:-2 Y:-1 andZ:z];
			break;
		}
		case 4:
		{
			brick1.isRotated = NO;
			brick2.isRotated = YES;
			brick3.isRotated = NO;
			brick4.isRotated = YES;
			[brick1 setX:2 Y:-3 andZ:z];
			[brick2 setX:3 Y:1 andZ:z];
			[brick3 setX:-1 Y:2 andZ:z];
			[brick4 setX:-2 Y:-2 andZ:z];
			break;
		}
	}
	
	[model addPlacedBrick:brick1];
	[model addPlacedBrick:brick2];
	[model addPlacedBrick:brick3];
	[model addPlacedBrick:brick4];

}

@end
