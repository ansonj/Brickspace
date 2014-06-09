//
//  BKPInstructionSet.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPInstructionSet.h"

@implementation BKPInstructionSet

@synthesize style;

- (id)initWithStyle:(BKPInstructionGeneratorStyle)newStyle {
	self = [super init];
	
	if (self) {
		style = newStyle;
	}
	
	return self;
}

@end
