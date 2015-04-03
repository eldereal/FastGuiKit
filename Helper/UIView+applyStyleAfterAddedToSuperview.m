//
//  UIView+applyStyleAfterAddedToSuperview.m
//  train-helper
//
//  Created by 易元 白 on 15/3/14.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UIView+applyStyleAfterAddedToSuperview.h"
#import <REKit/REKit.h>
#import <objc/runtime.h>


static void * ApplyStyleAfterAddedToSuperviewPropertyKey = &ApplyStyleAfterAddedToSuperviewPropertyKey;

@implementation UIView(applyStyleAfterAddedToSuperview)

- (void)applyStyleAfterAddedToSuperviewWithBlock:(FGStyleBlock)applyStyleBlock
{
    static NSString * overrideKey = @"applyStyleAfterAddedToSuperviewWithBlock";
    [self respondsToSelector:@selector(didMoveToSuperview) withKey:overrideKey usingBlock:^(UIView * self){
        void(*superblock)(id target, SEL selector) = (void(*)(id target, SEL selector))[self supermethodOfCurrentBlock];
        if (superblock) {
            superblock(self, @selector(didMoveToSuperview));
        }
        applyStyleBlock(self);
        [self removeCurrentBlock];
    }];
    
}

@end
