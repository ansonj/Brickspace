//
//  BKPPlacedBrick.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPBrick.h"

@interface BKPPlacedBrick : NSObject

typedef NS_ENUM(NSUInteger, BKPPlacedBrickOrientation) {
	BKPPlacedBrickOrientationAlongXAxis,
	BKPPlacedBrickOrientatoinAlongYAxis
};

@property (nonatomic) BKPBrick *brick;
@property (nonatomic) BKPPlacedBrickOrientation orientation;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;

- (void)setX:(float)newX
		   Y:(float)newY
		andZ:(float)newZ;

@end
