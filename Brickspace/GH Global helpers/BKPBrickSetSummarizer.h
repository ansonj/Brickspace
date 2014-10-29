//
//  BKPBrickSetSummarizer.h
//  Brickspace
//
//  Created by Anson Jablinski on 9/12/2014.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPBrickSetSummarizer : NSObject

+ (NSString *)niceDescriptionOfBricksInSet:(NSSet *)bricks
                             withTotalLine:(BOOL)includeTotal;

@end
