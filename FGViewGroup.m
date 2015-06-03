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
#import "UIView+FGStylable.h"
#import <objc/runtime.h>
#import <REKit/REKit.h>

static void * EndGroupMethodKey = &EndGroupMethodKey;

@interface UIView (FGViewGroup)

@property (nonatomic, strong) FGReuseItemPool *pool;

@property (nonatomic, assign) CGFloat styleBottomOrRight;

@end

@interface FGScrollGroupView : UIView

@property (nonatomic, strong) UIScrollView *layoutView;

@end

typedef NS_ENUM(NSUInteger, FGViewGroupLayoutMode)
{
    FGViewGroupLayoutModeFree,
    FGViewGroupLayoutModeVertical,
    FGViewGroupLayoutModeHorizontal
};

@interface FGViewGroup : NSObject<FGContext>

@property (nonatomic, strong) UIView *groupView;

@property (nonatomic, assign) FGViewGroupLayoutMode mode;

@property (nonatomic, strong) UIView *previousView;

@end

@implementation FastGui (FGViewGroup)

+ (void) beginGroup
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil isCustom:NO layoutMode:FGViewGroupLayoutModeFree];
}

+ (void)beginGroupWithStyleClass:(NSString *)styleClass
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass isCustom:NO layoutMode:FGViewGroupLayoutModeFree];
}

+ (void)beginGroupWithNextView
{
    [self beginGroupWithReuseId:nil styleClass:nil isCustom:YES layoutMode:FGViewGroupLayoutModeFree];
}

+ (void)beginVerticalGroup
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil isCustom:NO layoutMode:FGViewGroupLayoutModeVertical];
}

+ (void)beginVerticalGroupWithStyleClass:(NSString *)styleClass
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass isCustom:NO layoutMode:FGViewGroupLayoutModeVertical];
}

+ (void)beginVerticalGroupWithNextView
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil isCustom:YES layoutMode:FGViewGroupLayoutModeVertical];
}

+ (void)beginHorizontalGroup
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil isCustom:NO layoutMode:FGViewGroupLayoutModeHorizontal];
}

+ (void)beginHorizontalGroupWithStyleClass:(NSString *)styleClass
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass isCustom:NO layoutMode:FGViewGroupLayoutModeHorizontal];
}

+ (void)beginHorizontalGroupWithNextView
{
    [self beginGroupWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil isCustom:YES layoutMode:FGViewGroupLayoutModeHorizontal];
}

+ (void)beginGroupWithReuseId: (NSString *) reuseId styleClass:(NSString *)styleClass isCustom: (BOOL) isCustom layoutMode: (FGViewGroupLayoutMode) mode
{
    FGViewGroup *group = [[FGViewGroup alloc] init];
    group.groupView = nil;
    group.mode = mode;
    [self pushContext: group];
    if(!isCustom){
        [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
            if (reuseView == nil) {
                reuseView = [[UIView alloc] init];
            }
            return reuseView;
        } resultBlock:nil];
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

- (void)dismissViewController
{
    [parentContext dismissViewController];
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

-(void) setAndOverrideVerticalLayouts:(UIView *)view
{
    view.bottomConstraint = nil;
    if (self.previousView == nil) {
        view.topConstraint = [self.groupView updateConstraint:view.topConstraint view1:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.groupView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    }else{
        view.topConstraint = [self.groupView updateConstraint:view.topConstraint view1:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.previousView attribute:NSLayoutAttributeBottom multiplier:1 constant:self.previousView.styleBottomOrRight];
        
        __weak UIView *weakView = view;
        [self.previousView respondsToSelector:@selector(styleWithBottom:) withKey:nil usingBlock:^(UIView *self, CGFloat bottom){
            weakView.topConstraint.constant = bottom;
        }];
    }
    [view respondsToSelector:@selector(styleWithTop:) withKey:nil usingBlock:^(UIView * self, CGFloat top){
        self.topConstraint.constant = top;
    }];
    [view respondsToSelector:@selector(styleWithBottom:) withKey:nil usingBlock:^(UIView * self, CGFloat bottom){
        self.styleBottomOrRight = bottom;
    }];
    [view respondsToSelector:@selector(styleWithTopPercentage:) withKey:nil usingBlock:^(id self){
        printf("'topPercentage' style of this view is disabled because it is in a vertical layout group.");
    }];
    [view respondsToSelector:@selector(styleWithBottomPercentage:) withKey:nil usingBlock:^(id self){
        printf("'bottomPercentage' style of this view is disabled because it is in a vertical layout group.");
    }];
}

- (void) setAndOverrideHorizontalLayouts:(UIView *)view
{
    if (self.previousView == nil) {
        view.leftConstraint = [self.groupView updateConstraint:view.leftConstraint view1:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.groupView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    }else{
        view.leftConstraint = [self.groupView updateConstraint:view.leftConstraint view1:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.previousView attribute:NSLayoutAttributeRight multiplier:1 constant:self.previousView.styleBottomOrRight];
        __weak UIView *weakView = view;
        [self.previousView respondsToSelector:@selector(styleWithRight:) withKey:nil usingBlock:^(UIView *self, CGFloat right){
            weakView.leftConstraint.constant = right;
        }];
    }
    [view respondsToSelector:@selector(styleWithLeft:) withKey:nil usingBlock:^(UIView * self, CGFloat left){
        self.leftConstraint.constant = left;
    }];
    [view respondsToSelector:@selector(styleWithRight:) withKey:nil usingBlock:^(UIView * self, CGFloat right){
        self.styleBottomOrRight = right;
    }];
    [view respondsToSelector:@selector(styleWithLeftPercentage:) withKey:nil usingBlock:^(id self){
        printf("'leftPercentage' style of this view is disabled because it is in a horizontal layout group.");
    }];
    [view respondsToSelector:@selector(styleWithRightPercentage:) withKey:nil usingBlock:^(id self){
        printf("'rightPercentage' style of this view is disabled because it is in a horizontal layout group.");
    }];
}


- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if(self.groupView == nil){
        UIView * view = [self.parentContext customViewWithReuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
            UIView *view = initBlock(reuseView);
            if(view.pool == nil){
                view.pool = [[FGReuseItemPool alloc] init];
            }
            [view.pool prepareUpdateItems];
            return view;
        } resultBlock: ^(UIView *view){
            return view;
        } applyStyleBlock:applyStyleBlock];
        self.groupView = view;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(view);
        }
    }else{
        BOOL isNew;
        UIView *view = (UIView *)[self.groupView.pool updateItem:reuseId initBlock:initBlock outputIsNewView: &isNew];
        if (isNew) {
            [self.groupView addSubview:view];            
        }else{
            [self.groupView bringSubviewToFront:view];
        }
        if (self.mode == FGViewGroupLayoutModeVertical) {
            [self setAndOverrideVerticalLayouts: view];
        }else if(self.mode == FGViewGroupLayoutModeHorizontal){
            [self setAndOverrideHorizontalLayouts: view];
        }
        applyStyleBlock(view);
        self.previousView = view;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(view);
        }
    }
}

- (void) endGroup
{
    if (self.mode == FGViewGroupLayoutModeVertical) {
        if (self.previousView != nil) {
            self.previousView.bottomConstraint = [self.groupView updateConstraint:self.previousView.bottomConstraint view1:self.groupView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.previousView attribute:NSLayoutAttributeBottom multiplier:1 constant:self.previousView.styleBottomOrRight];
            [self.previousView respondsToSelector:@selector(styleWithBottom:) withKey:nil usingBlock:^(UIView *self, CGFloat bottom){
                self.bottomConstraint.constant = bottom;
            }];
        }
    }
    if (self.mode == FGViewGroupLayoutModeHorizontal) {
        if (self.previousView != nil) {
            self.previousView.rightConstraint = [self.groupView updateConstraint:self.previousView.rightConstraint view1:self.groupView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.previousView attribute:NSLayoutAttributeRight multiplier:1 constant:self.previousView.styleBottomOrRight];
            [self.previousView respondsToSelector:@selector(styleWithRight:) withKey:nil usingBlock:^(UIView *self, CGFloat right){
                self.rightConstraint.constant = right;
            }];
        }
    }
    self.previousView = nil;
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


@implementation UIView (FGViewGroup)

static void * PoolKey = &PoolKey;
static void * StyleBottomOrRight = &StyleBottomOrRight;


- (FGReuseItemPool *)pool
{
    return objc_getAssociatedObject(self, PoolKey);
}

- (void)setPool:(FGReuseItemPool *)pool
{
    objc_setAssociatedObject(self, PoolKey, pool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)styleBottomOrRight
{
    return [(NSNumber *)objc_getAssociatedObject(self, StyleBottomOrRight) floatValue];
}

- (void)setStyleBottomOrRight:(CGFloat)styleBottomOrRight
{
    objc_setAssociatedObject(self, StyleBottomOrRight, [NSNumber numberWithFloat:styleBottomOrRight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FGScrollGroupView

- (UIView *)layoutView
{
    if (_layoutView == nil) {
        _layoutView = [[UIScrollView alloc] init];
        [super addSubview:_layoutView];
        [FGStyle updateStyleOfView:_layoutView withBlock:^(UIView *view) {
            [FGStyle topBottom:0 leftRight:0];
        }];
    }
    return _layoutView;
}

- (void)addSubview:(UIView *)view
{
    [self.layoutView addSubview:view];
}

@end
