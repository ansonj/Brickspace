//
//  BKPInstructionSet.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

// This class is just a holder for a mutable array, each item of which is a set of bricks that correspond to that step.
// Steps are zero-indexed, for parity with the array. It should be the UI's job to add one to the step number.

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
	if (step < [instructionArray count])
		return instructionArray[step];
	else
		return [NSSet set];
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
