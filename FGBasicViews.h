//
//  FGBasicViews.h
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui.h"
#import "FGStyle.h"

@interface FastGui(FGBasicViews)

+ (void) block;

+ (void) blockWithStyleClass: (NSString *)styleClass;

+ (void) blockWithColor:(UIColor *)color;

+ (void) blockWithColor:(UIColor *)color styleClass: (NSString *)styleClass;

+ (void) touchableBlockWithCallback: (FGVoidBlock) callback;

+ (void) touchableBlockWithCallback: (FGVoidBlock) callback styleClass: (NSString *)styleClass;

+ (void) scrollView;

+ (void) scrollViewWithStyleClass: (NSString *)styleClass;

+ (void) labelWithText: (NSString *) text;

+ (void) labelWithText: (NSString *) text styleClass: (NSString *)styleClass;

//+ (void) labelWithReuseId:(NSString *)reuseId text: (NSString *)text styleClass: (NSString *)styleClass;

+ (void) selectableLabelWithText: (NSString *) text;

+ (void) selectableLabelWithText: (NSString *) text styleClass: (NSString *)styleClass;

//+ (void) selectableLabelWithReuseId:(NSString *)reuseId text: (NSString *)text styleClass: (NSString *)styleClass;

+ (void) imageWithName: (NSString *) name;

+ (void) imageWithName: (NSString *) name styleClass: (NSString *)styleClass;

//+ (void)imageWithReuseId:(NSString *)reuseId imageNamed: (NSString *)name styleClass: (NSString *)styleClass;

+ (void) imageButtonWithName: (NSString *) imageName styleClass: (NSString *)styleClass onClick: (FGVoidBlock) onClick;

+ (void) imageButtonWithName: (NSString *) imageName onClick: (FGVoidBlock) onClick;

+ (NSString *) textField;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder;

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass;

+ (NSString *) passwordField;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder;

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass;

+ (NSUInteger) segmentControlWithItems: (NSArray *) items;

+ (NSUInteger) segmentControlWithItems: (NSArray *) items selectedSegmentIndex: (NSInteger) selectedSegmentIndex;

+ (NSUInteger) segmentControlWithItems: (NSArray *) items  styleClass: (NSString *)styleClass;

+ (NSUInteger) segmentControlWithItems: (NSArray *) items selectedSegmentIndex: (NSInteger) selectedSegmentIndex styleClass: (NSString *)styleClass;

+ (void) activityIndicator;

+ (void) activityIndicatorWithStyleClass: (NSString *)styleClass;

@end

@interface FGStyle(FGBasicViews)

+ (void) labelLines: (NSInteger) lines;

@end
