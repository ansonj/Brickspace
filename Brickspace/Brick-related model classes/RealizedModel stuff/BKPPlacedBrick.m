//
//  BKPPlacedBrick.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPPlacedBrick.h"

@implementation BKPPlacedBrick

@synthesize brick;
@synthesize orientation;
@synthesize x, y, z;

- (id)init {
	self = [super init];
	
	if (self) {
		[self setBrick:[[BKPBrick alloc] init]];
	}
	
	return self;
}

- (void)setX:(float)newX Y:(float)newY andZ:(float)newZ {
	[self setX:newX];
	[self setY:newY];
	[self setZ:newZ];
}

@end
