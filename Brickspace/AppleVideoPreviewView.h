//
//  AppleVideoPreviewView.h
//  Scanning with Structure
//
//  Created by Anson Jablinski on 6/23/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureSession;

@interface AppleVideoPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
