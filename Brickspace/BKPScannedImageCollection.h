//
//  BKPScannedImageCollection.h
//  Scanning with Structure
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPScannedImageCollection : NSObject

#pragma mark - Convenience constructor

+ (id)emptyCollection;

#pragma mark - The good stuff

@property (nonatomic) NSMutableArray *imageCollection;

- (NSSet *)allBricksFromAllImages;

@end
