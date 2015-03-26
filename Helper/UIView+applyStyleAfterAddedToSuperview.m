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
    __weak UIView* weakSelf = self;
    [self respondsToSelector:@selector(didMoveToSuperview) withKey:nil usingBlock:^(id receiver){
        void(*superblock)(id target, SEL selector) = (void(*)(id target, SEL selector))[receiver supermethodOfCurrentBlock];
        if (superblock) {
            superblock(self, @selector(didMoveToSuperview));
        }
        if (weakSelf != nil) {
            applyStyleBlock(weakSelf);
        }
    }];
    
}

@end
