//
//  UIView+styleBlockHolder.m
//  train-helper
//
//  Created by 易元 白 on 15/3/13.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UIView+styleBlockHolder.h"
#import <objc/runtime.h>

static void * StyleBlockHolderPropertyKey = &StyleBlockHolderPropertyKey;

@implementation UIView(styleBlockHolder)

- (FGStyleBlockHolder *)styleBlockHolder
{
    return objc_getAssociatedObject(self, StyleBlockHolderPropertyKey);
}

- (void)setStyleBlockHolder:(FGStyleBlockHolder *)styleBlockHolder
{
    objc_setAssociatedObject(self, StyleBlockHolderPropertyKey, styleBlockHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
