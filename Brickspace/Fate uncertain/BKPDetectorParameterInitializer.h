//
//  BKPDetectorParameterInitializer.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/5/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPDetectorParameterInitializer : NSObject

+ (NSArray *)getDefaultParameters;

+ (NSArray *)getParametersForLegoUpClose;

+ (NSArray *)getParametersForLegoAfarWithStructure;

@end
