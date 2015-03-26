//
//  FGDecorationViewContext.m
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGDecorationViewContext.h"

@interface FGDecorationViewContext : NSObject<FGContext>

@property (copy) FGViewBlock decorationBlock;

@end

static void * EndDecorationContextMethodKey = &EndDecorationContextMethodKey;

@implementation FastGui(FGDecorationViewContext)

+ (void)beginDecorationContextWithBlock:(FGViewBlock)block
{
    FGDecorationViewContext *ctx = [[FGDecorationViewContext alloc] init];
    ctx.decorationBlock = block;
    [FastGui pushContext: ctx];
}

+ (void)endDecorationContext
{
    [FastGui customData:EndDecorationContextMethodKey data:nil];
}

@end

@implementation FGDecorationViewContext

@synthesize  parentContext;

- (void) reloadGui
{
    [parentContext reloadGui];
}

- (void) styleSheet
{
    [parentContext styleSheet];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (void)dismissViewController
{
    [parentContext dismissViewController];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    UIView *view = [parentContext customViewWithReuseId:reuseId initBlock:initBlock resultBlock:^id(UIView *view) {
        return view;
    } applyStyleBlock:applyStyleBlock];
    if (self.decorationBlock != nil) {
        self.decorationBlock(view);
    }
    if (resultBlock == nil) {
        return nil;
    }else{
        return resultBlock(view);
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndDecorationContextMethodKey) {
        [self endDecorationContext];
    }else{
        return [parentContext customData:key data:data];
    }
    return nil;
}

- (void) endDecorationContext
{
    [FastGui popContext];
}

@end
