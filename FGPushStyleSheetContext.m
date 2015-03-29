//
//  FGPushStyleSheetContext.m
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGPushStyleSheetContext.h"
#import <REKit/REKit.h>

@interface FGPushStyleSheetContext : NSObject<FGContext>

@property (nonatomic, strong) NSArray * styleSheets;

@end

static void * EndUseStyleSheetsMethodKey = &EndUseStyleSheetsMethodKey;

@implementation FastGui(FGPushStyleSheetContext)

+ (void)beginUseStyleSheet:(id<FGStyleSheet>)styleSheet
{
    [self beginUseStyleSheets:@[styleSheet]];
}

+ (void)beginUseStyleSheets:(NSArray *)styleSheets
{
    FGPushStyleSheetContext *ctx = [[FGPushStyleSheetContext alloc] init];
    ctx.styleSheets = styleSheets;
    [FastGui pushContext: ctx];
}

+ (void)beginUseStyleSheetWithBlock:(FGVoidBlock)styleSheetBlock
{
    id styleSheet = [[NSObject alloc] init];
    [styleSheet respondsToSelector:@selector(styleSheet) withKey:nil usingBlock:styleSheetBlock];
    [self beginUseStyleSheet:styleSheet];
}

+ (void)endUseStyleSheet
{
    [self endUseStyleSheets];
}

+ (void)endUseStyleSheets
{
    [self customData:EndUseStyleSheetsMethodKey data:nil];
}

//+ (void)useStyleSheet:(id<FGStyleSheet>)styleSheet withBlock:(FGVoidBlock)block
//{
//    [self beginUseStyleSheet:styleSheet];
//    block();
//    [self endUseStyleSheet];
//}
//
//+ (void)useStyleSheets:(NSArray *)styleSheets withBlock:(FGVoidBlock)block
//{
//    [self beginUseStyleSheets:styleSheets];
//    block();
//    [self endUseStyleSheets];
//}
//
//+ (void)useStyleSheetWithBlock:(FGVoidBlock)styleSheet withBlock:(FGVoidBlock)block
//{
//    [self beginUseStyleSheetWithBlock:styleSheet];
//    block();
//    [self endUseStyleSheet];
//}

@end

@implementation FGPushStyleSheetContext

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void)styleSheet
{
    [parentContext styleSheet];
    for (id<FGStyleSheet> stylesheet in self.styleSheets) {
        [stylesheet styleSheet];
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndUseStyleSheetsMethodKey) {
        [FastGui popContext];
        return nil;
    }else{
        return [parentContext customData:key data:data];
    }
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    return [parentContext customViewWithReuseId:reuseId initBlock:initBlock resultBlock:resultBlock applyStyleBlock:applyStyleBlock];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (void)dismissViewController
{
    [parentContext dismissViewController];
}

@end
