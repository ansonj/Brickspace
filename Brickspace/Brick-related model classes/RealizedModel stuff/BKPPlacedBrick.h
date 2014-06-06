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

@property (nonatomic, readonly) BKPBrick *brick;
@property (nonatomic, readonly) BKPPlacedBrickOrientation orientation;
@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) float z;

@end
