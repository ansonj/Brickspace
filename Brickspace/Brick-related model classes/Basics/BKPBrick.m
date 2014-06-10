//
//  BKPBrick.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrick.h"

@implementation BKPBrick

@synthesize color;
@synthesize shortSideLength, longSideLength;
@synthesize height;

+ (BKPBrick *)brickWithColor:(BKPBrickColor)newColor shortSide:(int)newShortSideLength longSide:(int)newLongSideLength andHeight:(int)newHeight {
	BKPBrick *newBrick = [[BKPBrick alloc] init];
	
	if (newBrick) {
		[newBrick setColor:newColor];
		[newBrick setShortSideLength:newShortSideLength];
		[newBrick setLongSideLength:newLongSideLength];
		[newBrick setHeight:newHeight];
	}
	
	return newBrick;
}

- (NSString *)description {
	NSString *result = [NSString string];
	
	result = [result stringByAppendingFormat:@"%@ ",[BKPBrickColorOptions stringForColor:color]];
	
	result = [result stringByAppendingFormat:@"%dx%d ", shortSideLength, longSideLength];
	
	switch (height) {
		case 1:
			result = [result stringByAppendingString:@"flat "];
			break;
		case 3:
			result = [result stringByAppendingString:@"standard "];
			break;
			
		default:
			result = [result stringByAppendingFormat:@"%d-high ", height];
			break;
	}
		
	return [result stringByAppendingString:@"brick"];
}

@end
