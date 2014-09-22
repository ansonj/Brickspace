//
//  BKPInstructionSet.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPInstructionGenerator.h"

@interface BKPInstructionSet : NSObject

@property (nonatomic, readonly) NSString *sourceDesignName;
@property (nonatomic, readonly) BKPInstructionGeneratorStyle style;

#pragma mark - Setting up the instructions

- (id)initWithDesignName:(NSString *)newName
				andStyle:(BKPInstructionGeneratorStyle)newStyle;

- (void)addBricksToNextStep:(NSSet *)bricks;

// addBricksToNextStep is preferred.
// Use addBricks:toStep: with caution!
- (void)addBricks:(NSSet *)bricks
		   toStep:(int)step;

#pragma mark - Getting instruction information

// All methods in this class take 1-indexed step numbers as arguments,
//	including the above addBricks:toStep:.

- (int)stepCount;

- (NSSet *)bricksForStep:(int)step;
- (NSSet *)bricksForStepsOneThrough:(int)step;

@end
