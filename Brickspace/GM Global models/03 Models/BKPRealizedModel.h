//
//  BKPRealizedModel.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPPlacedBrick.h"
#import <Foundation/Foundation.h>

@interface BKPRealizedModel : NSObject

@property (nonatomic) NSString *sourceDesignName;

- (id)initWithSourceDesignName:(NSString *)name;

- (void)addPlacedBrick:(BKPPlacedBrick *)brick;

// Returns a set of BKPPlacedBricks.
- (NSSet *)brickPlacementData;

@end
