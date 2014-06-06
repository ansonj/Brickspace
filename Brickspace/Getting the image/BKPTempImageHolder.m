//
//  BKPTempImageHolder.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPTempImageHolder.h"

@implementation BKPTempImageHolder

@synthesize image;

- (id)init {
	return [self initWithImage:nil];
}

- (id)initWithImage:(UIImage *)newImage {
	self = [super init];
	
	if (self) {
		[self setImage:newImage];
	}
	
	return self;
}

@end
