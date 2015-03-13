//
//  FGViewGroup.m
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGViewGroup.h"
#import "FGReuseItemPool.h"
#import "FGTypes.h"
#import "FGInternal.h"
#import "FGBasicViews.h"
#import <objc/runtime.h>

static void * EndGroupMethodKey = &EndGroupMethodKey;

@interface UIView (FGViewGroup)

@property (nonatomic, strong) FGReuseItemPool *pool;

@end

@interface FGViewGroup : NSObject<FGContext>

@property (nonatomic, strong) UIView *groupView;

@end

@implementation FastGui (FGViewGroup)

+ (void) beginGroup
{
    [self beginGroupWithClass: nil isCustom: NO];
}

+ (void)beginCustomGroup
{
    [self beginGroupWithClass: nil isCustom: YES];
}

+ (void)beginGroupWithClass:(NSString *)styleClass
{
    [self beginGroupWithClass: styleClass isCustom: NO];
}

+ (void)beginGroupWithClass:(NSString *)styleClass isCustom: (BOOL) isCustom;
{
    FGViewGroup *group = [[FGViewGroup alloc] init];
    group.groupView = nil;
    [self pushContext: group];
    if(!isCustom){
        [self blockWithStyleClass: styleClass];
    }
}

+ (void) endGroup
{
    [FastGui customData:EndGroupMethodKey data:nil];
}

@end



@implementation FGViewGroup

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void) customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (id) customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndGroupMethodKey){
        [self endGroup];
    }else{
        return [self.parentContext customData:key data:data];
    }
    return nil;
}

- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    __weak FGViewGroup *weakSelf = self;
    if(self.groupView == nil){
        id ret = [self.parentContext customViewWithReuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGVoidBlock notifyResult) {
            UIView *view = initBlock(reuseView, ^{
                [weakSelf reloadGui];
            });
            weakSelf.groupView = view;
            if(view.pool == nil){
                view.pool = [[FGReuseItemPool alloc] init];
            }
            [view.pool prepareUpdateItems];
            return view;
        } resultBlock: resultBlock applyStyleBlock:applyStyleBlock];
        return ret;
    }else{
        BOOL isNew;
        UIView *view = (UIView *)[self.groupView.pool updateItem:reuseId initBlock:initBlock notifyBlock:^{
            [weakSelf reloadGui];
        } outputIsNewView: &isNew];
        if (isNew) {
            [self.groupView addSubview:view];
        }
        applyStyleBlock(view);
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(view);
        }
    }
}

- (void) endGroup
{
    if (self.groupView != nil){
        [self.groupView.pool finishUpdateItems:nil needRemove:^(UIView *view) {
            [view removeFromSuperview];
        }];
    }
    [FastGui popContext];
}

- (void)styleSheet
{
    [self.parentContext styleSheet];
}

@end

static void * PoolKey = &PoolKey;

@implementation UIView (FGViewGroup)

- (FGReuseItemPool *)pool
{
    return objc_getAssociatedObject(self, PoolKey);
}

- (void)setPool:(FGReuseItemPool *)pool
{
    objc_setAssociatedObject(self, PoolKey, pool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
