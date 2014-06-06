//
//  BKPBrick.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrick.h"

@interface BKPBrick ()
+ (NSString *)stringForBrickColor:(BKPBrickColor)color;
+ (NSString *)stringForBrickHeight:(BKPBrickHeight)height;
+ (NSString *)stringForBrickSize:(BKPBrickSize)size;
@end

@implementation BKPBrick

@synthesize color, height, size;

+ (BKPBrick *)brickWithColor:(BKPBrickColor)newColor height:(BKPBrickHeight)newHeight andSize:(BKPBrickSize)newSize {
	BKPBrick *newBrick = [[BKPBrick alloc] init];
	
	if (newBrick) {
		[newBrick setColor:newColor];
		[newBrick setHeight:newHeight];
		[newBrick setSize:newSize];
	}
	
	return newBrick;
}

- (NSString *)description {
	NSString *result = [NSString string];
	
	result = [result stringByAppendingString:[BKPBrick stringForBrickColor:color]];
	result = [result stringByAppendingString:[BKPBrick stringForBrickHeight:height]];
	result = [result stringByAppendingString:[BKPBrick stringForBrickSize:size]];
	
	return [result stringByAppendingString:@" brick"];
}

#pragma mark - NS_ENUM to string converters

+ (NSString *)stringForBrickColor:(BKPBrickColor)color {
	NSString *string;
	
	switch (color) {
		case BKPBrickColorRed:
			string = @"red, ";
			break;
			
		default:
			break;
	}
	
	return string;
}

+ (NSString *)stringForBrickHeight:(BKPBrickHeight)height {
	NSString *string;
	
	switch (height) {
		case BKPBrickHeightOneThird:
			string = @"one-third height, ";
			break;
		case BKPBrickHeightFull:
			string = @"full height, ";
			break;
			
		default:
			break;
	}
	
	return string;
}

+ (NSString *)stringForBrickSize:(BKPBrickSize)size {
	NSString *string;
	
	switch (size) {
		case BKPBrickSize2x2:
			string = @"2x2, ";
			break;
		case BKPBrickSize2x3:
			string = @"2x3, ";
			break;
		case BKPBrickSize2x4:
			string = @"2x4, ";
			break;
			
		default:
			break;
	}
	
	return string;
}

@end
