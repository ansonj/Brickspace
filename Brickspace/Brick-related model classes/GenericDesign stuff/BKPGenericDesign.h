//
//  BKPGenericDesign.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPBrickSet.h"
#import "BKPRealizedModel.h"

@protocol BKPGenericDesign <NSObject>

+ (BOOL)shouldBeOfferedToUser;

+ (NSString *)designName;
+ (NSString *)designDescription;
+ (NSString *)description;

+ (BOOL)canBeBuiltFromBrickSet:(BKPBrickSet *)inputBricks;

+ (BKPRealizedModel *)createRealizedModelUsingBrickSet:(BKPBrickSet *)inputBricks;

@optional

+ (float)percentUtilizedIfBuiltWithSet:(BKPBrickSet *)inputBricks;

+ (BKPBrickSet *)bricksToBeUsedInModelFromSet:(BKPBrickSet *)inputBricks;

@end
