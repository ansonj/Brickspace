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

@property (nonatomic, readonly) BKPInstructionGeneratorStyle style;

#pragma mark - Setting up the instructions

- (id)initWithStyle:(BKPInstructionGeneratorStyle)newStyle;

- (void)addBricks:(NSMutableSet *)setOfBricks
		   toStep:(NSUInteger)step;


#pragma mark - Getting instruction information

- (NSUInteger)stepCount;

- (NSSet *)bricksForStep:(NSUInteger)step;

@end
