//
//  FGViewGroup.h
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"

@interface FastGui (FGViewGroup)

+ (void) beginGroup;

+ (void) beginGroupWithNextView;

+ (void) beginGroupWithStyleClass: (NSString *) styleClass;

+ (void) beginVerticalGroup;

+ (void) beginVerticalGroupWithNextView;

+ (void) beginVerticalGroupWithStyleClass: (NSString *) styleClass;

+ (void) beginHorizontalGroup;

+ (void) beginHorizontalGroupWithNextView;

+ (void) beginHorizontalGroupWithStyleClass: (NSString *) styleClass;

//+ (void) beginVerticalScrollGroup;
//
//+ (void) beginVerticalScrollGroupWithStyleClass: (NSString *) styleClass;

+ (void) endGroup;

@end
