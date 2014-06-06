//
//  BKPBrickSet.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickSet.h"

@implementation BKPBrickSet

+ (BKPBrickSet *)set {
	return [[BKPBrickSet alloc] init];
}

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

- (NSString *)description {
	NSString *result = [NSString stringWithFormat:@"A BKPBrick Set with %lu bricks:\n", (unsigned long)[self.setOfBricks count]];
	
	for (BKPBrick *brick in self.setOfBricks) {
		result = [result stringByAppendingFormat:@"%@\n",brick];
	}
	
	return result;
}

@end
