//
//  FGPushStyleSheetContext.m
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGPushStyleSheetContext.h"
#import "FGNullViewContext.h"
#import <REKit/REKit.h>

@interface FGPushStyleSheetContext : FGNullViewContext

@property (nonatomic, strong) id<FGStyleSheet> customStyleSheet;

@property (nonatomic) BOOL isolated;

@end

@implementation FastGui(FGPushStyleSheetContext)

+ (void)beginUseStyleSheet:(id<FGStyleSheet>)styleSheet
{
    [self beginUseStyleSheet:styleSheet isolated:NO];
}

+ (void)beginUseStyleSheet:(id<FGStyleSheet>)styleSheet isolated:(BOOL)isolated
{
    FGPushStyleSheetContext *ctx = [[FGPushStyleSheetContext alloc] init];
    ctx.customStyleSheet = styleSheet;
    ctx.isolated = isolated;
    [FastGui pushContext: ctx];
}

+ (void)beginUseStyleSheetWithBlock:(FGVoidBlock)styleSheetBlock
{
    [self beginUseStyleSheetWithBlock:styleSheetBlock isolated:NO];
}

+ (void)beginUseStyleSheetWithBlock:(FGVoidBlock)styleSheetBlock isolated:(BOOL)isolated
{
    id styleSheet = [[NSObject alloc] init];
    [styleSheet respondsToSelector:@selector(styleSheet) withKey:nil usingBlock:styleSheetBlock];
    [self beginUseStyleSheet:styleSheet isolated:isolated];
}

+ (void)endUseStyleSheet
{
    [self popContext];
}

@end

@implementation FGPushStyleSheetContext

@synthesize parentContext;

- (void)styleSheet
{
    if (!self.isolated) {
        [parentContext styleSheet];
    }
    [self.customStyleSheet styleSheet];
}

@end
