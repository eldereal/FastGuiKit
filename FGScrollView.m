//
//  FGVerticalScrollView.m
//  train-helper
//
//  Created by 易元 白 on 15/3/21.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGScrollView.h"
#import "FGViewGroup.h"
#import "FGStyle.h"
#import "FGInternal.h"
#import "UIView+FGStylable.h"
#import "UIView+applyStyleAfterAddedToSuperview.h"

@implementation FastGui(FGScrollView)

+ (void) beginVerticalScrollView
{
    [self beginVerticalScrollViewWithReuseId: [FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void)beginVerticalScrollViewWithStyleClass:(NSString *)styleClass
{
    [self beginVerticalScrollViewWithReuseId: [FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void)beginVerticalScrollViewWithReuseId:(NSString *)reuseId styleClass:(NSString *)styleClass
{
    [self beginGroupWithNextView];
    __block BOOL isNew = NO;
    UIScrollView *scrollView = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIScrollView alloc] init];
            isNew = YES;
        }
        return reuseView;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    [self beginVerticalGroupWithNextView];
    UIView *layoutView = [self customViewWithClass:nil reuseId:[NSString stringWithFormat:@"%@-contentView", reuseId] initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
            isNew = YES;
        }
        return reuseView;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    if (isNew) {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        
        layoutView.translatesAutoresizingMaskIntoConstraints = NO;
        [layoutView setContentHuggingPriority:0 forAxis:UILayoutConstraintAxisVertical];
        layoutView.topConstraint = [scrollView updateConstraint:layoutView.leftConstraint view1:layoutView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        layoutView.bottomConstraint = [scrollView updateConstraint:layoutView.bottomConstraint view1:layoutView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        layoutView.leftConstraint = [scrollView.superview updateConstraint:layoutView.leftConstraint view1:layoutView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        layoutView.widthConstraint = [scrollView.superview updateConstraint:layoutView.widthConstraint view1:layoutView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView.superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    }
    
}

+ (void)endVerticalScrollView
{
    [self endGroup];
    [self endGroup];
}

@end

@implementation FGStyle(FGScrollView)


+ (void) scrollViewInset:(UIEdgeInsets)inset
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *) view).contentInset = inset;
        }
    }];
}

+ (void) scrollViewInsetWithTop:(CGFloat) top right: (CGFloat) right bottom: (CGFloat) bottom left:(CGFloat)left
{
    [self scrollViewInset:UIEdgeInsetsMake(top, left, bottom, right)];
}

@end
