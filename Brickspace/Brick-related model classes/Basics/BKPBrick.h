//
//  BKPBrick.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPBrick : NSObject

typedef NS_ENUM(NSInteger, BKPBrickColor) {
	BKPBrickColorRed
};

typedef NS_ENUM(NSInteger, BKPBrickHeight) {
	BKPBrickHeightOneThird,
	BKPBrickHeightFull
};

typedef NS_ENUM(NSInteger, BKPBrickSize) {
	BKPBrickSize2x2,
	BKPBrickSize2x3,
	BKPBrickSize2x4
};

@property (nonatomic) BKPBrickColor color;
@property (nonatomic) BKPBrickHeight height;
@property (nonatomic) BKPBrickSize size;

+ (BKPBrick *)brickWithColor:(BKPBrickColor)newColor
			 height:(BKPBrickHeight)newHeight
			andSize:(BKPBrickSize)newSize;

@end
