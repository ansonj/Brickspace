//
//  BKPInstructionGenerator.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPRealizedModel.h"

@class BKPInstructionSet;

@interface BKPInstructionGenerator : NSObject

typedef NS_ENUM(NSUInteger, BKPInstructionGeneratorStyle) {
	BKPInstructionGeneratorStyleBottomUp
};

+ (BKPInstructionSet *)instructionsForRealizedModel:(BKPRealizedModel *)model
										  withStyle:(BKPInstructionGeneratorStyle)style;

@end
