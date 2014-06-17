//
//  BKPBrickColorOptions.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/10/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

/* Color info from
 http://www.peeron.com/inv/colors
 Data taken from LDrawRGB column and converted to base 10,
 except for Green, which was taken from RGB column.
*/

#import "BKPBrickColorOptions.h"

@implementation BKPBrickColorOptions

+ (BKPBrickColor)randomColor {
	return arc4random_uniform(6);
}

+ (UIColor *)colorForColor:(BKPBrickColor)color {
	switch (color) {
		case BKPBrickColorRed:
			return [UIColor colorWithRed:201.0/255 green:26.0/255 blue:9.0/255 alpha:1];
			break;
		case BKPBrickColorOrange:
			return [UIColor colorWithRed:254.0/255 green:138.0/255 blue:24.0/255 alpha:1];
			break;
		case BKPBrickColorYellow:
			return [UIColor colorWithRed:242.0/255 green:205.0/255 blue:55.0/255 alpha:1];
			break;
		case BKPBrickColorGreen:
			return [UIColor colorWithRed:40.0/255 green:127.0/255 blue:70.0/255 alpha:1];
			break;
		case BKPBrickColorBlue:
			return [UIColor colorWithRed:0.0/255 green:85.0/255 blue:191.0/255 alpha:1];
			break;
		case BKPBrickColorBlack:
			return [UIColor colorWithRed:5.0/255 green:19.0/255 blue:29.0/255 alpha:1];
			break;
			
		default:
			return [UIColor whiteColor];
			break;
	}
}

+ (NSString *)stringForColor:(BKPBrickColor)color {
	switch (color) {
		case BKPBrickColorRed:
			return @"red";
			break;
		case BKPBrickColorOrange:
			return @"orange";
			break;
		case BKPBrickColorYellow:
			return @"yellow";
			break;
		case BKPBrickColorGreen:
			return @"green";
			break;
		case BKPBrickColorBlue:
			return @"blue";
			break;
		case BKPBrickColorBlack:
			return @"black";
			break;
			
		default:
			return [NSString string];
			break;
	}
}

@end
