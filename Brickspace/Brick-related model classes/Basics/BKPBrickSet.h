//
//  BKPBrickSet.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPBrick.h"

@interface BKPBrickSet : NSObject

@property (nonatomic, readonly) NSMutableSet *setOfBricks;

- (id)init;

- (void)addBrick:(BKPBrick *)brick;
- (void)removeBrick:(BKPBrick *)brick;

- (unsigned long)brickCount;

@end