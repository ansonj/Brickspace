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
@synthesize isRotated;
@synthesize x, y, z;

- (id)init {
	self = [super init];
	
	if (self) {
		[self setBrick:[[BKPBrick alloc] init]];
		isRotated = NO;
	}
	
	return self;
}

- (void)setX:(float)newX Y:(float)newY andZ:(float)newZ {
	[self setX:newX];
	[self setY:newY];
	[self setZ:newZ];
}

- (NSString *)description {
	NSString *result = [brick description];
	
	result = [result stringByAppendingFormat:@" at (%.4f, %.4f, %.4f) pointed in the ", x, y, z];
	
	if (isRotated)
		result = [result stringByAppendingString:@"y direction"];
	else
		result = [result stringByAppendingString:@"x direction"];
	
	return result;
}

@end
