//
//  FGTextFieldDismissFirstResponderTouchOutside.m
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UITextField+dismissFirstResponderTouchOutside.h"
#import <objc/runtime.h>
#import <REKit/REKit.h>

@interface UITextField(dismissFirstResponderTouchOutsideHelper)

@property (nonatomic, weak) UITapGestureRecognizer *fg_dismissRecognizer;
@property (nonatomic, weak) UIView *fg_dismissRecognizerHolder;

@end

@implementation UITextField(dismissFirstResponderTouchOutsideHelper)

static void * DismissRecognizerPropertyKey = &DismissRecognizerPropertyKey;
static void * DismissRecognizerHolderPropertyKey = &DismissRecognizerHolderPropertyKey;

- (UITapGestureRecognizer *)fg_dismissRecognizer
{
    return objc_getAssociatedObject(self, DismissRecognizerPropertyKey);
}

- (void)setFg_dismissRecognizer:(UITapGestureRecognizer *)dismissRecognizer
{
    objc_setAssociatedObject(self, DismissRecognizerPropertyKey, dismissRecognizer, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)fg_dismissRecognizerHolder
{
    return objc_getAssociatedObject(self, DismissRecognizerHolderPropertyKey);
}

- (void)setFg_dismissRecognizerHolder:(UIView *)dismissRecognizerHolder
{
    objc_setAssociatedObject(self, DismissRecognizerHolderPropertyKey, dismissRecognizerHolder, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UITextField(dismissFirstResponderTouchOutside)

- (void) setDismissFirstResponderTouchOutsideEnabled:(BOOL)enabled
{
    if (!enabled) {
        if ([self hasBlockForSelector:@selector(becomeFirstResponder) withKey:nil]) {
            [self removeBlockForSelector:@selector(becomeFirstResponder) withKey:nil];
        }
        if ([self hasBlockForSelector:@selector(resignFirstResponder) withKey:nil]) {
            [self removeBlockForSelector:@selector(resignFirstResponder) withKey:nil];
        }
    }else{
        [self respondsToSelector:@selector(becomeFirstResponder) withKey:nil usingBlock:^BOOL(UITextField* self){
            if (self.fg_dismissRecognizer == nil) {
                UITapGestureRecognizer * r = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
                self.fg_dismissRecognizer = r;
                UIView *rootView = self;
                while (rootView.superview != nil) {
                    rootView = rootView.superview;
                }
                [rootView addGestureRecognizer:r];
                self.fg_dismissRecognizerHolder = rootView;
            }
            BOOL (*super)(id, SEL) = (BOOL (*)(id, SEL))([self supermethodOfCurrentBlock]);
            return super(self, @selector(becomeFirstResponder));
        }];
        [self respondsToSelector:@selector(resignFirstResponder) withKey:nil usingBlock:^BOOL(UITextField* self){
            if (self.fg_dismissRecognizer != nil) {
                [self.fg_dismissRecognizerHolder removeGestureRecognizer:self.fg_dismissRecognizer];
                self.fg_dismissRecognizer = nil;
                self.fg_dismissRecognizerHolder = nil;
            }
            BOOL (*super)(id, SEL) = (BOOL (*)(id, SEL))([self supermethodOfCurrentBlock]);
            return super(self, @selector(becomeFirstResponder));
        }];
    }
}

@end
