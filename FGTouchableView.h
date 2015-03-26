//
//  FGTouchableView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui.h"

@interface FastGui(FGTouchableView)

+ (void) beginTouchableViewsWithOnTouchBlock: (FGVoidBlock) onTouch;

+ (void) endTouchableViews;

@end
