//
//  UIView+FGStylable.h
//  train-helper
//
//  Created by 易元 白 on 15/3/16.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGStyle.h"

@interface UIView(FGStylable)<FGStylable>

@property (nonatomic, weak) NSLayoutConstraint *leftConstraint;
@property (nonatomic, weak) NSLayoutConstraint *rightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint *widthConstraint;
@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *horizontalCenterConstraint;
@property (nonatomic, weak) NSLayoutConstraint *verticalCenterConstraint;

- (NSLayoutConstraint *) updateConstraint: (NSLayoutConstraint *)constraint view1: (id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;

- (void) percentageSizeStyleRelativeTo: (UIView*) relativeView;

- (void) percentageSizeStyleRelativeToSuperview;

- (void) percentageSizeStyleDisabledWithTip: (NSString *) tip;

- (void) sizeStyleUseAutoLayout;

- (void) sizeStyleSetFrame;

- (void) sizeStyleDisabledWithTip:(NSString *) tip;

- (void) positionStyleUseAutoLayout;

- (void) positionStyleDisabledWithTip: (NSString *)tip;

@end
