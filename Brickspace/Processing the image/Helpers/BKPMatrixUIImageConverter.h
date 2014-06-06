//
//  BKPMatrixUIImageConverter.h
//  Brickspace Stage I
//
//  Created by Anson Jablinski on 6/3/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/core/core.hpp>
using namespace cv;

@interface BKPMatrixUIImageConverter : NSObject

+ (Mat)cvMatFromUIImage:(UIImage *)image;

+ (UIImage *)UIImageFromCVMat:(Mat)matrix;

@end
