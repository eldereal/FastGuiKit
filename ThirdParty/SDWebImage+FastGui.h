//
//  SDWebImage+FastGui.h
//  train-helper
//
//  Created by 易元 白 on 15/3/14.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"



@interface FastGui(SDWebImage)

+ (void) webImageWithUrl: (NSURL*) url;
+ (void) webImageWithUrl: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage;
+ (void) webImageWithUrl: (NSURL*) url styleClass: (NSString *) styleClass;
+ (void) webImageWithUrl: (NSURL*) url autoAspect: (BOOL) autoAspect styleClass: (NSString *) styleClass;
+ (void) webImageWithUrl: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage styleClass: (NSString *) styleClass;

@end
