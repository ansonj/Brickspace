//
//  BKPRealizedModel.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPRealizedModel.h"

@implementation BKPRealizedModel {
	NSMutableSet *_setOfPlacedBricks;
}

@synthesize sourceDesignName;

- (id)init {
	return [self initWithSourceDesignName:nil];
}

- (id)initWithSourceDesignName:(NSString *)name {
	self = [super init];
	
	if (self) {
		self.sourceDesignName = name;
		_setOfPlacedBricks = [NSMutableSet set];
	}
	
	return self;
}

- (void)addPlacedBrick:(BKPPlacedBrick *)brick {
	[_setOfPlacedBricks addObject:brick];
}

- (NSSet *)brickPlacementData {
	return [NSSet setWithSet:_setOfPlacedBricks];
}

- (NSString *)description {
	NSString *result = [NSString stringWithFormat:@"A RealizedModel of a %@ with %lu bricks:\n", [self sourceDesignName], (unsigned long)[_setOfPlacedBricks count]];
	
	for (BKPBrick *brick in _setOfPlacedBricks) {
		result = [result stringByAppendingFormat:@"%@\n",brick];
	}
	
	return result;
}

@end
