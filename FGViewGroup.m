//
//  FGViewGroup.m
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGViewGroup.h"
#import "FGViewPool.h"
#import "FGInternal.h"
#import "FGBasicViews.h"

static void * BeginGroupMethodKey = &BeginGroupMethodKey;
static void * EndGroupMethodKey = &EndGroupMethodKey;
static NSString * BeginGroupStyleClassDataKey = @"FGViewGroupBeginGroupStyleClassDataKey";
static NSString * BeginGroupIsCustomDataKey = @"FGViewGroupBeginGroupIsCustomDataKey";

@implementation FastGui (FGViewGroup)

+ (void) beginGroup
{
    [self beginGroupWithClass: nil isCustom: NO];
}

+ (void)beginCustomGroup
{
    [self beginGroupWithClass: nil isCustom: YES];
}

+ (void)beginGroupWithClass:(NSString *)styleClass
{
    [self beginGroupWithClass: styleClass isCustom: NO];
}

+ (void)beginGroupWithClass:(NSString *)styleClass isCustom: (BOOL) isCustom;
{
    [self customData:BeginGroupMethodKey data:@{BeginGroupStyleClassDataKey: styleClass, BeginGroupIsCustomDataKey: [NSNumber numberWithBool: isCustom]}];
}

+ (void) endGroup
{
    [FastGui customData:EndGroupMethodKey data:nil];
}

@end

@interface FGViewGroup()

@property (nonatomic, strong) FGViewPool *pool;

@property (nonatomic, copy) NSString *groupViewReuseId;
@property (copy) FGInitCustomViewBlock initGroupViewBlock;
@property (copy) FGStyleBlock groupViewApplyStyleBlock;
@property (copy) FGGetCustomViewResultBlock groupViewGetResultBlock;

@property (nonatomic, assign) BOOL waitingForCustomView;

@end

@implementation FGViewGroup

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if(key == BeginGroupMethodKey){
        [self beginGroupWithClass: data[BeginGroupStyleClassDataKey] isCustom: data[BeginGroupIsCustomDataKey]];
    }else if (key == EndGroupMethodKey){
        [self endGroup];
    }
    return nil;
}

- (void) beginGroupWithClass:(NSString *)styleClass isCustom: (NSNumber *) isCustom
{
    if (self.pool == nil) {
        self.pool = [[FGViewPool alloc] init];
    }

    self.groupViewReuseId = nil;
    self.groupViewGetResultBlock = nil;
    self.groupViewApplyStyleBlock = nil;
    self.initGroupViewBlock = nil;
    self.waitingForCustomView = YES;
    
    [self.pool prepareUpdateViews];
    [FastGui pushContext: self];
    if(!isCustom.boolValue){
        [FastGui blockWithStyleClass: styleClass];
    }
    
}

- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if(self.waitingForCustomView){
        self.groupViewReuseId = reuseId;
        self.groupViewGetResultBlock = resultBlock;
        self.groupViewApplyStyleBlock = applyStyleBlock;
        self.initGroupViewBlock = initBlock;
        return nil;
    }else{
        __weak FGViewGroup *weakSelf = self;
        BOOL isNewView;
        
        
        UIView *view = [self.pool updateView:reuseId initBlock:initBlock notifyBlock:^(){
            [weakSelf reloadGui];
        } applyStyleBlock:applyStyleBlock outputIsNewView: &isNewView];
        
        if (resultBlock == nil){
            return nil;
        }else{
            return resultBlock(view);
        }
    }
}

- (void) endGroup
{
    [FastGui popContext];
    
}

- (void)styleSheet
{
    [self.parentContext styleSheet];
}

@end
