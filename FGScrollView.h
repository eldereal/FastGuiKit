//
//  FGVerticalScrollView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/21.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGStyle.h"

@interface FastGui(FGScrollView)

+ (void) beginVerticalScrollView;

+ (void) beginVerticalScrollViewWithStyleClass: (NSString *) styleClass;

+ (void) endVerticalScrollView;

@end

@interface FGStyle(FGScrollView)

+ (void) scrollViewInset: (UIEdgeInsets) inset;

+ (void) scrollViewInsetWithTop:(CGFloat) top right: (CGFloat) right bottom: (CGFloat) bottom left:(CGFloat)left;

@end
