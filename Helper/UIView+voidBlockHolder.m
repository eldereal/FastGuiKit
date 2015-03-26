//
//  UIView+voidBlockHolder.m
//  train-helper
//
//  Created by 易元 白 on 15/3/16.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UIView+voidBlockHolder.h"
#import <objc/runtime.h>

static void * VoidBlockHolderPropertyKey = &VoidBlockHolderPropertyKey;

@implementation UIView(voidBlockHolder)

- (FGVoidBlockHolder *)voidBlockHolder
{
    return objc_getAssociatedObject(self, VoidBlockHolderPropertyKey);
}

- (void)setVoidBlockHolder:(FGVoidBlockHolder *)voidBlockHolder
{
    objc_setAssociatedObject(self, VoidBlockHolderPropertyKey, voidBlockHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
