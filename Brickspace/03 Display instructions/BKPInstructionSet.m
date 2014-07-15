//
//  BKPInstructionSet.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

// This class is just a holder for a mutable array, each item of which is a set of bricks that correspond to that step.
// Steps are zero-indexed here, because of the array, but stepCount and both bricksForStep(s) "undo" the zero-index, so the outside world can perceive the steps as starting at 1.

#import "BKPInstructionSet.h"

@implementation BKPInstructionSet {
	NSMutableArray *instructionArray;
}

@synthesize sourceDesignName = _sourceDesignName;
@synthesize style = _style;

- (id)init {
	NSLog(@"Please init %@ with arguments.",[self class]);
	return nil;
}

- (id)initWithDesignName:(NSString *)newName
				andStyle:(BKPInstructionGeneratorStyle)newStyle {
	self = [super init];
	
	if (self) {
		_sourceDesignName = newName;
		_style = newStyle;
		instructionArray = [NSMutableArray array];
	}
	
	return self;
}

- (void)addBricksToNextStep:(NSSet *)bricks {
	[instructionArray addObject:bricks];
}

- (void)addBricks:(NSSet *)bricks toStep:(int)step {
	while (step >= [instructionArray count]) {
		[instructionArray addObject:[NSSet set]];
	}
	
	NSMutableSet *newBricks = [NSMutableSet setWithSet:instructionArray[step]];
	for (id brick in bricks) {
		[newBricks addObject:brick];
	}
	
	[instructionArray replaceObjectAtIndex:step withObject:newBricks];
}

- (int)stepCount {
	return (int)[instructionArray count];
}

- (NSSet *)bricksForStep:(int)step {
	// THIS is the method that undoes the zero-indexing.
	// bricksForStepOneThrough uses THIS
	// BOTH take one-indexed step numbers as arguments
	if (step <= [instructionArray count] && step > 0)
		return instructionArray[step-1];
	else
		return [NSSet set];
}

- (NSSet *)bricksForStepsOneThrough:(int)step {
	NSMutableSet *bricks = [NSMutableSet set];
	for (int currentStep = 1; currentStep <= step; currentStep++) {
		NSSet *currentStepBricks = [self bricksForStep:currentStep];
		for (id brick in currentStepBricks) {
			[bricks addObject:brick];
		}
	}
	return bricks;
}

- (NSString *)description {
	int numberOfSteps = [self stepCount];
	NSString *result = [NSString stringWithFormat:@"Instructions for a %@ with %d steps:\n", _sourceDesignName, numberOfSteps];
	
	for (int step = 0; step < numberOfSteps; step++) {
		result = [result stringByAppendingFormat:@"Step %d:\n", step + 1];
		NSSet *currentStepBricks = [self bricksForStep:step];
		for (id brick in currentStepBricks) {
			result = [result stringByAppendingFormat:@"\t%@\n", brick];
		}
	}	
	
	return result;
}

@end
