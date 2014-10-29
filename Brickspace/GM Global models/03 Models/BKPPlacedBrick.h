//
//  BKPPlacedBrick.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrick.h"
#import <Foundation/Foundation.h>

@interface BKPPlacedBrick : NSObject

@property (nonatomic) BKPBrick *brick;
@property (nonatomic) BOOL isRotated;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;

- (void)setX:(float)newX
           Y:(float)newY
        andZ:(float)newZ;

@end
