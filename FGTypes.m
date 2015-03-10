//
//  FGTypes.m
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/5.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <objc/runtime.h>
#import "FGTypes.h"

static void * ReuseIdPropertyKey = &ReuseIdPropertyKey;
static void * NotifyHolderPropertyKey = &NotifyHolderPropertyKey;

@implementation FGNotifyCustomViewResultHolder

+ (FGNotifyCustomViewResultHolder *) holderWithBlock: (FGNotifyCustomViewResultBlock) block
{
    FGNotifyCustomViewResultHolder *holder = [[FGNotifyCustomViewResultHolder alloc] init];
    holder.block = block;
    return holder;
}

-(void)notify
{
    if (self.block != nil) {
        self.block();
    }
}

@end

@implementation FGVoidBlockHolder

+ (FGVoidBlockHolder *) holderWithBlock: (FGVoidBlock) block
{
    FGVoidBlockHolder *holder = [[FGVoidBlockHolder alloc] init];
    holder.block = block;
    return holder;
}

-(void)notify
{
    if (self.block != nil) {
        self.block();
    }
}

@end

@implementation UIView (FastGui)

- (void)setReuseId:(NSString *)reuseId
{
    objc_setAssociatedObject(self, ReuseIdPropertyKey, reuseId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)reuseId
{
    return objc_getAssociatedObject(self, ReuseIdPropertyKey);
}

- (FGNotifyCustomViewResultHolder *)notifyHolder
{
    return objc_getAssociatedObject(self, NotifyHolderPropertyKey);
}

-(void)setNotifyHolder:(FGNotifyCustomViewResultHolder *)notifyHolder
{
    objc_setAssociatedObject(self, NotifyHolderPropertyKey, notifyHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end


