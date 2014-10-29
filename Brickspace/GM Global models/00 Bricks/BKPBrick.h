//
//  BKPBrick.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickColorOptions.h"
#import <Foundation/Foundation.h>

@interface BKPBrick : NSObject

@property (nonatomic) BKPBrickColor color;
@property (nonatomic) int shortSideLength;
@property (nonatomic) int longSideLength;
@property (nonatomic) int height;

+ (BKPBrick *)brickWithColor:(BKPBrickColor)newColor
                   shortSide:(int)newShortSideLength
                    longSide:(int)newLongSideLength
                   andHeight:(int)newHeight;

@end
