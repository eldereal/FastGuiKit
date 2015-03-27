//
//  FGTextFieldDismissFirstResponderTouchOutside.m
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGTextFieldDismissFirstResponderTouchOutside.h"

@interface FGTextFieldDismissFirstResponderTouchOutside()

@property (nonatomic, weak) UITapGestureRecognizer *dismissRecognizer;
@property (nonatomic, weak) UIView *dismissRecognizerHolder;

@end

@implementation FGTextFieldDismissFirstResponderTouchOutside

- (BOOL)becomeFirstResponder
{
    if (self.dismissRecognizer == nil) {
        UITapGestureRecognizer * r = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
        self.dismissRecognizer = r;
        UIView *rootView = self;
        while (rootView.superview != nil) {
            rootView = rootView.superview;
        }
        [rootView addGestureRecognizer:r];
        self.dismissRecognizerHolder = rootView;
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    if (self.dismissRecognizer != nil) {
        [self.dismissRecognizerHolder removeGestureRecognizer:self.dismissRecognizer];
        self.dismissRecognizer = nil;
        self.dismissRecognizerHolder = nil;
    }
    return [super resignFirstResponder];
}

@end
