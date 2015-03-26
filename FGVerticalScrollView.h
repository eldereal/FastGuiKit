//
//  FGVerticalScrollView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/21.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui.h"

@interface FastGui(FGVerticalScrollView)

+ (void) beginVerticalScrollView;

+ (void) beginVerticalScrollViewWithStyleClass: (NSString *) styleClass;

+ (void) endVerticalScrollView;

@end
