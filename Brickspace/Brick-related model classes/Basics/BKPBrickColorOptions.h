//
//  BKPBrickColorOptions.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/10/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPBrickColorOptions : NSObject

typedef NS_ENUM(NSUInteger, BKPBrickColor) {
	BKPBrickColorRed,
	BKPBrickColorOrange,
	BKPBrickColorYellow,
	BKPBrickColorGreen,
	BKPBrickColorBlue,
	BKPBrickColorBlack
};

+ (UIColor *)colorForColor:(BKPBrickColor)color;

+ (NSString *)stringForColor:(BKPBrickColor)color;

@end
