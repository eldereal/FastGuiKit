//
//  FGDecorationViewContext.h
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui.h"

@interface FastGui(FGDecorationViewContext)

+ (void) beginDecorationContextWithBlock: (FGViewBlock) block;

+ (void) endDecorationContext;

@end
