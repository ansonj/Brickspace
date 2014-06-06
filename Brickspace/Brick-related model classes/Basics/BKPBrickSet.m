//
//  BKPBrickSet.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickSet.h"

@implementation BKPBrickSet

@synthesize setOfBricks = _setOfBricks;

- (id)init {
	self = [super init];
	
	if (self) {
		_setOfBricks = [NSMutableSet set];
	}
	
	return self;
}

- (void)addBrick:(BKPBrick *)brick {
	[[self setOfBricks] addObject:brick];
}

- (void)removeBrick:(BKPBrick *)brick {
	[[self setOfBricks] removeObject:brick];
}

- (unsigned long)brickCount {
	return [[self setOfBricks] count];
}

@end
