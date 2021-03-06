//
//  UIView+FGStylable.m
//  train-helper
//
//  Created by 易元 白 on 15/3/16.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UIView+FGStylable.h"
#import <objc/runtime.h>
#import <REKit/REKit.h>
#import "FGInternal.h"


@interface NSLayoutConstraint(FGStylable)

//@property (nonatomic, copy) NSString * constraintType;

@property (nonatomic, weak) UIView * constraintHolder;

- (void) removeConstraint;

@end

@implementation NSLayoutConstraint(FGStylable)

//static void * ConstraintTypePropertyKey = &ConstraintTypePropertyKey;
static void * ConstraintHolderPropertyKey = &ConstraintHolderPropertyKey;

//- (NSString *)constraintType
//{
//    return objc_getAssociatedObject(self, ConstraintTypePropertyKey);
//}
//
//- (void)setConstraintType:(NSString *)constraintType
//{
//    objc_setAssociatedObject(self, ConstraintTypePropertyKey, constraintType, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}

- (UIView *)constraintHolder
{
    return objc_getAssociatedObject(self, ConstraintHolderPropertyKey);
}

- (void)setConstraintHolder:(UIView *)constraintHolder
{
    objc_setAssociatedObject(self, ConstraintHolderPropertyKey, constraintHolder, OBJC_ASSOCIATION_ASSIGN);
}

- (void)removeConstraint
{
    [self.constraintHolder removeConstraint: self];
}

@end

@interface UIView(FGStylablePrivate)

@property (nonatomic, strong) NSMutableArray *finishUpdateStyleCallbacks;

@end

@implementation UIView(FGStylablePrivate)

static void * FinishUpdateStyleCallbacksPropertyKey = &FinishUpdateStyleCallbacksPropertyKey;

- (NSMutableArray *)finishUpdateStyleCallbacks
{
    return objc_getAssociatedObject(self, FinishUpdateStyleCallbacksPropertyKey);
}

- (void)setFinishUpdateStyleCallbacks:(NSMutableArray *)finishUpdateStyleCallbacks
{
    objc_setAssociatedObject(self, FinishUpdateStyleCallbacksPropertyKey, finishUpdateStyleCallbacks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIView(FGStylable)

static void* LeftConstraintPropertyKey = &LeftConstraintPropertyKey;
static void* RightConstraintPropertyKey = &RightConstraintPropertyKey;
static void* TopConstraintPropertyKey = &TopConstraintPropertyKey;
static void* BottomConstraintPropertyKey = &BottomConstraintPropertyKey;
static void* WidthConstraintPropertyKey = &WidthConstraintPropertyKey;
static void* HeightConstraintPropertyKey = &HeightConstraintPropertyKey;
static void* HorizontalCenterConstraintPropertyKey = &HorizontalCenterConstraintPropertyKey;
static void* VerticalCenterConstraintPropertyKey = &VerticalCenterConstraintPropertyKey;


- (NSLayoutConstraint *) updateConstraint: (NSLayoutConstraint *)constraint view1: (id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c
{
    return [self updateConstraint:constraint view1:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *) updateConstraint: (NSLayoutConstraint *)constraint view1: (id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c priority: (UILayoutPriority) priority
{
    if (constraint != nil) {
        if (constraint.firstItem != view1 ||
            constraint.secondItem != view2 ||
            constraint.firstAttribute != attr1 ||
            constraint.secondAttribute != attr2 ||
            constraint.relation != relation ||
            constraint.multiplier != multiplier ||
            constraint.constraintHolder != self) {
            [constraint removeConstraint];
            constraint = nil;
        }
    }
    if (constraint == nil) {
        constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
        constraint.constraintHolder = self;
        [self addConstraint: constraint];
    }else if(constraint.constant != c){
        constraint.constant = c;
    }
    return constraint;
}

- (void)setLeftConstraint:(NSLayoutConstraint *)leftConstraint
{
    if(leftConstraint == nil){
        [self.leftConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, LeftConstraintPropertyKey, leftConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)leftConstraint
{
    return objc_getAssociatedObject(self, LeftConstraintPropertyKey);
}

- (void)setRightConstraint:(NSLayoutConstraint *)rightConstraint
{
    if(rightConstraint == nil){
        [self.rightConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, RightConstraintPropertyKey, rightConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)rightConstraint
{
    return objc_getAssociatedObject(self, RightConstraintPropertyKey);
}


- (void)setTopConstraint:(NSLayoutConstraint *)topConstraint
{
    if(topConstraint == nil){
        [self.topConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, TopConstraintPropertyKey, topConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)topConstraint
{
    return objc_getAssociatedObject(self, TopConstraintPropertyKey);
}

- (void)setBottomConstraint:(NSLayoutConstraint *)bottomConstraint
{
    if(bottomConstraint == nil){
        [self.bottomConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, BottomConstraintPropertyKey, bottomConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)bottomConstraint
{
    return objc_getAssociatedObject(self, BottomConstraintPropertyKey);
}

- (void)setWidthConstraint:(NSLayoutConstraint *)widthConstraint
{
    if(widthConstraint == nil){
        [self.widthConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, WidthConstraintPropertyKey, widthConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)widthConstraint
{
    return objc_getAssociatedObject(self, WidthConstraintPropertyKey);
}

- (void)setHeightConstraint:(NSLayoutConstraint *)heightConstraint
{
    if(heightConstraint == nil){
        [self.heightConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, HeightConstraintPropertyKey, heightConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)heightConstraint
{
    return objc_getAssociatedObject(self, HeightConstraintPropertyKey);
}

- (void)setHorizontalCenterConstraint:(NSLayoutConstraint *)horizontalCenterConstraint
{
    if(horizontalCenterConstraint == nil){
        [self.horizontalCenterConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, HorizontalCenterConstraintPropertyKey, horizontalCenterConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)horizontalCenterConstraint
{
    return objc_getAssociatedObject(self, HorizontalCenterConstraintPropertyKey);
}

- (void)setVerticalCenterConstraint:(NSLayoutConstraint *)verticalCenterConstraint
{
    if(verticalCenterConstraint == nil){
        [self.verticalCenterConstraint removeConstraint];
    }
    objc_setAssociatedObject(self, VerticalCenterConstraintPropertyKey, verticalCenterConstraint, OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutConstraint *)verticalCenterConstraint
{
    return objc_getAssociatedObject(self, VerticalCenterConstraintPropertyKey);
}

- (void)styleWithTop:(CGFloat)top
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(top)) {
            self.topConstraint = [self.superview updateConstraint:self.topConstraint view1:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1 constant:top];
        }else{
            self.topConstraint = nil;
        }
    }
}

- (void)styleWithRight:(CGFloat)right
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(right)) {
            self.rightConstraint = [self.superview  updateConstraint:self.rightConstraint view1:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1 constant: -right];
        }else{
            self.rightConstraint = nil;
        }
    }
}

- (void)styleWithBottom:(CGFloat)bottom
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(bottom)) {
            self.bottomConstraint = [self.superview updateConstraint:self.bottomConstraint view1:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1 constant: -bottom];
        }else{
            self.bottomConstraint = nil;
        }
    }
}

- (void)styleWithLeft:(CGFloat)left
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(left)) {
            self.leftConstraint = [self.superview updateConstraint:self.leftConstraint view1:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:left];
        }else{
            self.leftConstraint = nil;
        }
    }
}

- (void)styleWithWidth:(CGFloat)width
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (!isnan(width)) {
        self.widthConstraint = [self updateConstraint:self.widthConstraint view1:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width];
    }else{
        self.widthConstraint = nil;
    }
}

- (void)styleWithHeight:(CGFloat)height
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (!isnan(height)) {
        self.heightConstraint = [self updateConstraint:self.heightConstraint view1:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
    }else{
        self.heightConstraint = nil;
    }
}

- (void) styleWithWidthPercentage:(CGFloat)widthPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(widthPercentage)) {
            self.widthConstraint = [self.superview updateConstraint:self.widthConstraint view1:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeWidth multiplier:widthPercentage/100  constant:0];
        }else{
            self.widthConstraint = nil;
        }
    }
}

- (void)styleWithHeightPercentage:(CGFloat)heightPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(heightPercentage)) {
            self.heightConstraint = [self.superview updateConstraint:self.heightConstraint view1:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:heightPercentage/100 constant:0];
        }else{
            self.heightConstraint = nil;
        }
    }
}

- (void) styleWithLeftPercentage:(CGFloat)leftPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(leftPercentage)) {
            self.leftConstraint = [self.superview updateConstraint:self.leftConstraint view1:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:leftPercentage/100 constant:0];
        }else{
            self.leftConstraint = nil;
        }
    }
}

- (void)styleWithRightPercentage:(CGFloat)rightPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(rightPercentage)) {
            self.rightConstraint = [self.superview  updateConstraint:self.rightConstraint view1:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1-rightPercentage/100 constant: 0];
        }else{
            self.rightConstraint = nil;
        }
    }
}

- (void)styleWithTopPercentage:(CGFloat)topPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(topPercentage)) {
            self.topConstraint = [self.superview updateConstraint:self.topConstraint view1:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:topPercentage/100 constant:0];
        }else{
            self.topConstraint = nil;
        }
    }
}

- (void)styleWithHorizontalCenter:(CGFloat)horizontalCenter
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(horizontalCenter)) {
            self.horizontalCenterConstraint = [self.superview updateConstraint:self.horizontalCenterConstraint view1:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:horizontalCenter];
        }else{
            self.horizontalCenterConstraint = nil;
        }
    }
}

- (void)styleWithHorizontalCenterPercentage:(CGFloat)horizontalCenterPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (horizontalCenterPercentage == 0) {
            self.horizontalCenterConstraint = [self.superview updateConstraint:self.horizontalCenterConstraint view1:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        }else if (!isnan(horizontalCenterPercentage)) {
            CGFloat multiplier = 50 / horizontalCenterPercentage;
            self.horizontalCenterConstraint = [self.superview updateConstraint:self.horizontalCenterConstraint view1:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:multiplier constant:0];
        }else{
            self.horizontalCenterConstraint = nil;
        }
    }
}

- (void)styleWithVerticalCenter:(CGFloat)verticalCenter
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(verticalCenter)) {
            self.verticalCenterConstraint = [self.superview updateConstraint:self.verticalCenterConstraint view1:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:verticalCenter];
        }else{
            self.verticalCenterConstraint = nil;
        }
    }
}

- (void)styleWithVerticalCenterPercentage:(CGFloat)verticalCenterPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (verticalCenterPercentage == 0) {
            self.verticalCenterConstraint = [self.superview updateConstraint:self.verticalCenterConstraint view1:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        }else if (!isnan(verticalCenterPercentage)) {
            CGFloat multiplier = 50 / verticalCenterPercentage;
            self.verticalCenterConstraint = [self.superview updateConstraint:self.verticalCenterConstraint view1:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:multiplier constant:0];
        }else{
            self.verticalCenterConstraint = nil;
        }
    }
}

- (void)styleWithBottomPercentage:(CGFloat)bottomPercentage
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.superview != nil) {
        if (!isnan(bottomPercentage)) {
            self.bottomConstraint = [self.superview updateConstraint:self.bottomConstraint view1:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1-bottomPercentage/100 constant: 0];
        }else{
            self.bottomConstraint = nil;
        }
    }
}

- (void)styleWithOpacity:(CGFloat)opacity
{
    self.alpha = opacity;
}

- (void) styleWithHidden:(CGFloat)hidden
{
    if (hidden) {
        [self.finishUpdateStyleCallbacks addObject:[FGVoidBlockHolder holderWithBlock:^{
            self.hidden = hidden;
        }]];
    }else{
        self.hidden = hidden;
    }
    
}

- (void)styleWithBorder:(UIColor *)color width:(CGFloat)borderWidth
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)styleWithBorderColor:(UIColor *) borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (void)styleWithBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)styleWithBorderRadius:(CGFloat)borderRadius
{
    self.layer.cornerRadius = borderRadius;
}

- (void)styleWithColor:(UIColor *)color
{
    self.tintColor = color;
}

-(void)styleWithBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
}

- (void) beginUpdateStyle
{
    if (self.finishUpdateStyleCallbacks == nil) {
        self.finishUpdateStyleCallbacks = [NSMutableArray array];
    }
    [self.finishUpdateStyleCallbacks removeAllObjects];
}

- (void) endUpdateStyle
{
    for (FGVoidBlockHolder *holder in self.finishUpdateStyleCallbacks) {
        [holder notify];
    }
    [self layoutIfNeeded];
}

- (void)dispatchAfterUpdateStyle:(FGVoidBlock)block
{
    [self.finishUpdateStyleCallbacks addObject:[FGVoidBlockHolder holderWithBlock:block]];
}

- (void)styleWithTransition:(CGFloat)duration
{
    if (duration > 0) {
        [self respondsToSelector:@selector(beginUpdateStyle) withKey:nil usingBlock:^(UIView *self){
            void(*superblock)(id target, SEL selector) = (void(*)(id target, SEL selector))[self supermethodOfCurrentBlock];
            if (superblock) {
                superblock(self, @selector(beginUpdateStyle));
            }

            [UIView beginAnimations:[FGInternal memoryPositionAsReuseIdOfObject:self] context:nil];
            [UIView setAnimationDuration:duration];
        }];
        [self respondsToSelector:@selector(endUpdateStyle) withKey:nil usingBlock:^(UIView * self){
            [self layoutIfNeeded];
            [UIView commitAnimations];
            
            void(*superblock)(id target, SEL selector) = (void(*)(id target, SEL selector))[self supermethodOfCurrentBlock];
            if (superblock) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    superblock(self, @selector(endUpdateStyle));
                });
            }
        }];
    }else{
        [self removeBlockForSelector:@selector(beginUpdateStyle) withKey:nil];
        [self removeBlockForSelector:@selector(endUpdateStyle) withKey:nil];
    }
}

- (void)sizeStyleUseAutoLayout
{
    if ([self hasBlockForSelector:@selector(styleWithWidth:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithWidth:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithHeight:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithHeight:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithWidthPercentage:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithWidthPercentage:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithHeightPercentage:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithHeightPercentage:) withKey: nil];
    }
}

- (void)sizeStyleSetFrame
{
    [self respondsToSelector:@selector(styleWithWidth:) withKey:nil usingBlock:^(UIView *selfView, CGFloat width){
        if (!isnan(width)) {
            selfView.frame = CGRectMake(selfView.frame.origin.x, selfView.frame.origin.y, width, selfView.frame.size.height);
        }
    }];
    [self respondsToSelector:@selector(styleWithHeight:) withKey:nil usingBlock:^(UIView *selfView, CGFloat height){
        if (!isnan(height)) {
            selfView.frame = CGRectMake(selfView.frame.origin.x, selfView.frame.origin.y, selfView.frame.size.width, height);
        }
    }];
    [self respondsToSelector:@selector(styleWithWidthPercentage:) withKey:nil usingBlock:^(UIView *self, CGFloat widthPercentage){
        if (self.superview != nil && !isnan(widthPercentage)) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.superview.frame.size.width * widthPercentage, self.frame.size.height);
        }
    }];
    [self respondsToSelector:@selector(styleWithHeightPercentage:) withKey:nil usingBlock:^(UIView *self, CGFloat heightPercentage){
        if (self.superview != nil && !isnan(heightPercentage)) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.superview.frame.size.height * heightPercentage);
        }
    }];
}

- (void)sizeStyleDisabledWithTip:(NSString *) tip
{
    NSString *str = [tip copy];
    [self respondsToSelector:@selector(styleWithWidth:) withKey:nil usingBlock:^(UIView *selfView, CGFloat left){
        printf("'width' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithHeight:) withKey:nil usingBlock:^(UIView *selfView, CGFloat right){
        printf("'height' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithWidthPercentage:) withKey:nil usingBlock:^(UIView *selfView, CGFloat left){
        printf("'widthPercentage' style of this view is disabled because %s", [tip UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithHeightPercentage:) withKey:nil usingBlock:^(UIView *selfView, CGFloat right){
        printf("'heightPercentage' style of this view is disabled because %s", [tip UTF8String]);
    }];
}


- (void)positionStyleUseAutoLayout
{
    if ([self hasBlockForSelector:@selector(styleWithLeft:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithLeft:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithRight:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithRight:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithTop:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithTop:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithBottom:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithBottom:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithLeftPercentage:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithLeftPercentage:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithRightPercentage:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithRightPercentage:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithTopPercentage:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithTopPercentage:) withKey: nil];
    }
    if ([self hasBlockForSelector:@selector(styleWithBottomPercentage:) withKey:nil]) {
        [self removeBlockForSelector: @selector(styleWithBottomPercentage:) withKey: nil];
    }
}

- (void)positionStyleDisabledWithTip:(NSString *) tip
{
    NSString *str = [tip copy];
    [self respondsToSelector:@selector(styleWithLeft:) withKey:nil usingBlock:^(UIView *selfView, CGFloat left){
        printf("'left' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithRight:) withKey:nil usingBlock:^(UIView *selfView, CGFloat right){
        printf("'right' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithTop:) withKey:nil usingBlock:^(UIView *selfView, CGFloat top){
        printf("'top' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithBottom:) withKey:nil usingBlock:^(UIView *selfView, CGFloat bottom){
        printf("'bottom' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithLeftPercentage:) withKey:nil usingBlock:^(UIView *selfView, CGFloat left){
        printf("'leftPercentage' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithRightPercentage:) withKey:nil usingBlock:^(UIView *selfView, CGFloat right){
        printf("'rightPercentage' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithTopPercentage:) withKey:nil usingBlock:^(UIView *selfView, CGFloat top){
        printf("'topPercentage' style of this view is disabled because %s", [str UTF8String]);
    }];
    [self respondsToSelector:@selector(styleWithBottomPercentage:) withKey:nil usingBlock:^(UIView *selfView, CGFloat bottom){
        printf("'bottomPercentage' style of this view is disabled because %s", [str UTF8String]);
    }];
}

@end
