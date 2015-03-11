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

+ (void) beginCustomGroup;

+ (void) beginGroupWithClass: (NSString *) styleClass;

+ (void) endGroup;

@end

@interface FGViewGroup : NSObject<FGContext>

@end
