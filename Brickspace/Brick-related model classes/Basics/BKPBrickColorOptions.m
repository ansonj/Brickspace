//
//  BKPBrickColorOptions.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/10/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

/* Color info from
 http://www.peeron.com/inv/colors
 Data taken from LDrawRGB column and converted to base 10.
*/

#import "BKPBrickColorOptions.h"

@implementation BKPBrickColorOptions

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
			return [UIColor colorWithRed:35.0/255 green:120.0/255 blue:65.0/255 alpha:1];
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

@end
