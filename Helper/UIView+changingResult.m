//
//  UIView+changingResult.m
//  train-helper
//
//  Created by 易元 白 on 15/3/19.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UIView+changingResult.h"
#import "FastGui.h"
#import <objc/runtime.h>

@implementation UIView (changingResult)

static void * ChangingResultPropertyKey = &ChangingResultPropertyKey;

- (id)changingResult
{
    return objc_getAssociatedObject(self, ChangingResultPropertyKey);
}

- (void)setChangingResult:(id)changingResult
{
    objc_setAssociatedObject(self, ChangingResultPropertyKey, changingResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)reloadGuiChangingResult:(id)newResult
{
    [FastGui reloadGuiWithBeforeBlock:^{
        self.changingResult = newResult;
    } withAfterBlock:^{
        self.changingResult = nil;
        [FastGui reloadGui];
    }];
}

@end
