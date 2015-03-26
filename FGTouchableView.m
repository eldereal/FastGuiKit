//
//  FGTouchableView.m
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGTouchableView.h"
#import "FGDecorationViewContext.h"
#import <objc/runtime.h>

@interface UIView(FGTouchableView)

@property (nonatomic, strong) FGVoidBlockHolder *touchableCallback;
@property (nonatomic, strong) UIGestureRecognizer *touchGestureRecognizer;

@end

@implementation FastGui(FGTouchableView)

+ (void)beginTouchableViewsWithOnTouchBlock:(FGVoidBlock)onTouch
{
    [FastGui beginDecorationContextWithBlock:^(UIView *view) {
        if (view.touchableCallback == nil) {
            view.touchableCallback = [FGVoidBlockHolder holderWithBlock: onTouch];
        }else{
            view.touchableCallback.block = onTouch;
        }
        if (view.touchGestureRecognizer == nil) {
            view.touchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:view.touchableCallback action:@selector(notify)];
            [view addGestureRecognizer: view.touchGestureRecognizer];
        }
    }];
}

+ (void)endTouchableViews
{
    [FastGui endDecorationContext];
}

@end


static void * TouchableCallbackPropertyKey = &TouchableCallbackPropertyKey;

static void * TouchGestureRecognizerPropertyKey = &TouchGestureRecognizerPropertyKey;

@implementation UIView(FGTouchableView)

- (FGVoidBlockHolder *)touchableCallback
{
    return objc_getAssociatedObject(self, TouchableCallbackPropertyKey);
}

- (void)setTouchableCallback:(FGVoidBlockHolder *)touchableCallback
{
    objc_setAssociatedObject(self, TouchableCallbackPropertyKey, touchableCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizer *)touchGestureRecognizer
{
    return objc_getAssociatedObject(self, TouchGestureRecognizerPropertyKey);
}

- (void)setTouchGestureRecognizer:(UIGestureRecognizer *)touchGestureRecognizer
{
    objc_setAssociatedObject(self, TouchGestureRecognizerPropertyKey, touchGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
