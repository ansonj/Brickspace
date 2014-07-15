//
//  BKPInstructionGenerator.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPInstructionGenerator.h"
#import "BKPInstructionSet.h"

@implementation BKPInstructionGenerator

- (id)init {
	return nil;
}

+ (BKPInstructionSet *)instructionsForRealizedModel:(BKPRealizedModel *)model withStyle:(BKPInstructionGeneratorStyle)style {
	switch (style) {
		case BKPInstructionGeneratorStyleBottomUp:
			return [self bottomUpInstructionsForModel:model];
			break;
			
		default:
			return nil;
			break;
	}
}


// More styles to (hopefully) be added later.
+ (BKPInstructionSet *)bottomUpInstructionsForModel:(BKPRealizedModel *)model {
	BKPInstructionSet *instructions = [[BKPInstructionSet alloc] initWithDesignName:[model sourceDesignName] andStyle:BKPInstructionGeneratorStyleBottomUp];
	
	NSMutableSet *bricks = [NSMutableSet setWithSet:[model brickPlacementData]];
	
	unsigned long currentZCoordinate = 0;
	while ([bricks count] > 0) {
		NSMutableSet *bricksInNextStep = [NSMutableSet set];
		
		while ([bricksInNextStep count] == 0) {
			for (BKPPlacedBrick *brick in bricks) {
				// Divide by 3.0 as the int increases by 1.
				// This should minimize float roundoff error,
				// especially since we're dealing with third-height bricks.
				float targetHeight = currentZCoordinate / 3.0;
				if ([brick z] <= targetHeight) {
					[bricksInNextStep addObject:brick];
				}
			}
			currentZCoordinate++;
		}
		
		for (BKPPlacedBrick *brick in bricksInNextStep) {
			[bricks removeObject:brick];
		}
		
		[instructions addBricksToNextStep:bricksInNextStep];
		
	}
	
	return instructions;
}

@end
