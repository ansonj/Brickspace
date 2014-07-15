//
//  BKPGenericDesign.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPRealizedModel.h"

@protocol BKPGenericDesign <NSObject>

+ (BOOL)shouldBeOfferedToUser;

+ (NSString *)designName;
+ (NSString *)designDescription;
+ (NSString *)description;

+ (BOOL)canBeBuiltFromBricks:(NSSet *)inputBricks;

+ (BKPRealizedModel *)createRealizedModelUsingBricks:(NSSet *)inputBricks;

@optional

+ (float)percentUtilizedIfBuiltWithSet:(NSSet *)inputBricks;

+ (NSSet *)bricksToBeUsedInModelFromSet:(NSSet *)inputBricks;

@end
