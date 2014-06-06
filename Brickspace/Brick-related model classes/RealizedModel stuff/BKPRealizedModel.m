//
//  BKPRealizedModel.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPRealizedModel.h"

@implementation BKPRealizedModel {
	NSMutableSet *setOfPlacedBricks;
}

@synthesize sourceDesignName;

- (id)init {
	return [self initWithSourceDesignName:nil];
}

- (id)initWithSourceDesignName:(NSString *)name {
	self = [super init];
	
	if (self) {
		self.sourceDesignName = name;
		setOfPlacedBricks = [NSMutableSet set];
	}
	
	return self;
}

- (void)addPlacedBrick:(BKPPlacedBrick *)brick {
	[setOfPlacedBricks addObject:brick];
}

- (NSSet *)brickPlacementData {
	return [NSSet setWithSet:setOfPlacedBricks];
}

@end
