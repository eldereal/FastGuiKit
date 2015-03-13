//
//  FGNavigationItem.h
//  train-helper
//
//  Created by 易元 白 on 15/3/13.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"

@interface FastGui(FGNavigationBar)


+ (void) beginNavigationBar;

+ (void) navigationBarLeftItems;

+ (void) navigationBarLeftItemsWithBackButton: (BOOL) showBackButton;

+ (void) navigationTitle: (NSString *) title;

+ (void) navigationTitleView;

+ (void) navigationBarRightItems;

+ (void) endNavigationBar;

@end
