//
//  FGNavigationItem.m
//  train-helper
//
//  Created by 易元 白 on 15/3/13.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <objc/runtime.h>
#import "FGNavigationBar.h"
#import "FGTypes.h"
#import "FGReuseItemPool.h"

typedef NS_ENUM(NSUInteger, FGNavigationBarMode)
{
    FGNavigationBarModeNone,
    FGNavigationBarModeLeft,
    FGNavigationBarModeRight,
    FGNavigationBarModeTitle
};

@interface FGNavigationBar : NSObject <FGContext>

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, assign) FGNavigationBarMode mode;

@property (nonatomic, readonly) UINavigationItem * navigationItem;

- (BOOL) beginNavigationBar;

@end

@interface FGNavigationBarStyleBlockHolder : NSObject

+ (FGNavigationBarStyleBlockHolder *) holderWithBlock: (void(^)(UIBarButtonItem *)) block;

@property (copy) void(^ block)(UIBarButtonItem *);

-(void)notify: (UIBarButtonItem *) view;

@end

@interface UIBarButtonItem (FGNavigationBar)<FGWithReuseId>

@property (nonatomic, strong) FGNotifyCustomViewResultHolder * notifyHolder;

@property (nonatomic, strong) FGNavigationBarStyleBlockHolder *applyStyleHolder;

@end

@interface UINavigationItem (FGNavigationBar)

@property (nonatomic, strong) FGReuseItemPool *leftPool;

@property (nonatomic, strong) FGReuseItemPool *rightPool;

@end

static void * SetTitleMethodKey = &SetTitleMethodKey;
static void * SetTitleViewMethodKey = &SetTitleViewMethodKey;
static void * LeftItemsMethodKey = &LeftItemsMethodKey;
static void * RightItemsMethodKey = &RightItemsMethodKey;
static void * EndMethodKey = &EndMethodKey;

static NSString * TitleDataKey = @"FGNavigationBarTitleDataKey";
static NSString * ShowBackButtonDataKey = @"FGNavigationBarShowBackButtonDataKey";

static NSObject *beacon = nil;

@implementation FastGui(FGNavigationBar)

+ (void) beginNavigationBar
{
    FGNavigationBar *bar = [[FGNavigationBar alloc] init];
    [self pushContext: bar];
    if (beacon == nil) {
        beacon = [[NSObject alloc] init];
    }
    if(![bar beginNavigationBar]){
        printf("navigation bar should used directly under some view controller, (not in other Begin-End pairs). Otherwise its contents will be ignored");
    }
}

+ (void) navigationBarLeftItems
{
    [self navigationBarLeftItemsWithBackButton: NO];
}

+ (void) navigationBarLeftItemsWithBackButton: (BOOL) showBackButton
{
    [self customData:LeftItemsMethodKey data: @{ShowBackButtonDataKey: [NSNumber numberWithBool: showBackButton]}];
}

/**
 * set navigation item's title of current page
 */
+ (void) navigationTitle: (NSString *) title
{
    if (beacon == nil) {
        beacon = [[NSObject alloc] init];
    }
    if ([self customData:SetTitleMethodKey data:@{TitleDataKey: title}] != beacon) {
        //no one handles this message
        [self beginNavigationBar];
        [self navigationTitle: title];
        [self endNavigationBar];
    }
}

+ (void) navigationTitleView
{
    [self customData:SetTitleViewMethodKey data:nil];
}

+ (void) navigationBarRightItems
{
    [self customData:RightItemsMethodKey data:nil];
}

+ (void) endNavigationBar
{
    [self customData:EndMethodKey data:nil];
}

@end



@implementation FGNavigationBar

@synthesize parentContext;

- (UINavigationItem *) navigationItem
{
    if(!self.enabled){
        return nil;
    }
    return ((UINavigationController *)self.parentContext).navigationItem;
}

- (void) reloadGui
{
    [parentContext reloadGui];
}

- (void) styleSheet
{
    [parentContext styleSheet];
}

- (void) customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (BOOL) beginNavigationBar
{
    self.enabled = [self.parentContext isKindOfClass:[UIViewController class]];
    if (!self.enabled) {
        return NO;
    }
    self.mode = FGNavigationBarModeNone;
    if (self.navigationItem.leftPool == nil) {
        self.navigationItem.leftPool = [[FGReuseItemPool alloc] init];
    }
    if(self.navigationItem.rightPool == nil){
        self.navigationItem.rightPool = [[FGReuseItemPool alloc] init];
    }
    [self.navigationItem.leftPool prepareUpdateItems];
    [self.navigationItem.rightPool prepareUpdateItems];
    return YES;
}

- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if (!self.enabled) {
        return nil;
    }
    if (self.mode == FGNavigationBarModeTitle) {
        self.mode = FGNavigationBarModeNone;
        UIView *titleView = self.navigationItem.titleView;
        if (titleView == nil || ![titleView.reuseId isEqualToString: reuseId]) {
            titleView = nil;
        }
        __weak FGNavigationBar *weakSelf = self;
        UIView * newTitleView = initBlock(titleView, ^(){
            [weakSelf reloadGui];
        });
        if (newTitleView != titleView) {
            self.navigationItem.titleView = newTitleView;
        }
        applyStyleBlock(newTitleView);
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(newTitleView);
        }
    }else{
        return [self customBarButtonItemWithReuseId:reuseId initBlock:^(UIBarButtonItem * item, FGVoidBlock notifyResult) {
            UIView *innerView;
            if (item == nil) {
                innerView = initBlock(nil, notifyResult);
                item = [[UIBarButtonItem alloc] initWithCustomView: innerView];
            }else{
                innerView = item.customView;
                UIView *newInnerView = initBlock(innerView, notifyResult);
                if (newInnerView != innerView) {
                    item = [[UIBarButtonItem alloc] initWithCustomView: newInnerView];
                }
            }
            return item;
        } resultBlock:^id(UIBarButtonItem * item) {
            if (resultBlock == nil) {
                return nil;
            }else{
                return resultBlock(item.customView);
            }
        } applyStyleBlock:^(UIBarButtonItem * item) {
            applyStyleBlock(item.customView);
        }];
    }
}

- (id) customBarButtonItemWithReuseId: (NSString *)reuseId initBlock: (UIBarButtonItem *(^)(UIBarButtonItem *, FGVoidBlock)) initBlock resultBlock: (id(^)(UIBarButtonItem *)) resultBlock applyStyleBlock:(void(^)(UIBarButtonItem *))applyStyleBlock
{
    if (!self.enabled) {
        return nil;
    }
    FGReuseItemPool *pool;
    if (self.mode == FGNavigationBarModeLeft) {
        pool = self.navigationItem.leftPool;
    }else if(self.mode == FGNavigationBarModeRight){
        pool = self.navigationItem.rightPool;
    }else{
        printf("You must put views in left/right/title of a navigation item. Otherwise this view will be ignored");
        return nil;
    }
    
    BOOL isNew;
    __weak FGNavigationBar *weakSelf = self;
    UIBarButtonItem *item = (UIBarButtonItem *)[pool updateItem:reuseId initBlock:initBlock notifyBlock:^(){
        [weakSelf reloadGui];
    } outputIsNewView:&isNew];
    
    item.applyStyleHolder = [FGNavigationBarStyleBlockHolder holderWithBlock:applyStyleBlock];
    if (resultBlock == nil) {
        return nil;
    }else{
        return resultBlock(item);
    }
}


- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (!self.enabled) {
        return nil;
    }
    if(key == SetTitleMethodKey){
        [self navigationTitle: data[TitleDataKey]];
        return beacon;
    }else if(key == SetTitleViewMethodKey){
        [self navigationTitleView];
    }else if(key == LeftItemsMethodKey){
        [self navigationBarLeftItemsWithBackButton:[(NSNumber *)data[ShowBackButtonDataKey] boolValue]];
    }else if(key == RightItemsMethodKey){
        [self navigationBarRightItems];
    }else if(key == EndMethodKey){
        [self endNavigationBar];
    }else{
        return nil;
    }
             
    return nil;
}

- (void) navigationBarLeftItemsWithBackButton: (BOOL) showBackButton
{
    if (!self.enabled) {
        return;
    }
    self.navigationItem.leftItemsSupplementBackButton = showBackButton;
    self.navigationItem.hidesBackButton = !showBackButton;
    self.mode = FGNavigationBarModeLeft;
}

- (void) navigationTitle: (NSString *) title
{
    if (!self.enabled) {
        return;
    }
    self.navigationItem.title = title;
}

- (void) navigationTitleView
{
    self.mode = FGNavigationBarModeTitle;
}

- (void) navigationBarRightItems
{
    self.mode = FGNavigationBarModeRight;
}

- (void) endNavigationBar
{
    if (!self.enabled) {
        return;
    }
    [self.navigationItem.leftPool finishUpdateItems:nil needRemove:nil];
    NSArray *leftItems = [NSArray arrayWithArray: self.navigationItem.leftPool.items];
    self.navigationItem.leftBarButtonItems = leftItems;
    for (UIBarButtonItem *item in leftItems) {
        [item.applyStyleHolder notify: item];
        item.applyStyleHolder = nil;
    }
    
    [self.navigationItem.rightPool finishUpdateItems:nil needRemove:nil];
    NSArray *rightItems = [NSArray arrayWithArray: self.navigationItem.rightPool.items];
    self.navigationItem.rightBarButtonItems = rightItems;
    for (UIBarButtonItem *item in rightItems) {
        [item.applyStyleHolder notify: item];
        item.applyStyleHolder = nil;
    }
    [FastGui popContext];
}


@end


static void * ReuseIdPropertyKey = &ReuseIdPropertyKey;
static void * NotifyHolderPropertyKey = &NotifyHolderPropertyKey;
static void * StyleBlockHolderPropertyKey = &StyleBlockHolderPropertyKey;

@implementation UIBarButtonItem(FGNavigationBar)

- (void)setReuseId:(NSString *)reuseId
{
    objc_setAssociatedObject(self, ReuseIdPropertyKey, reuseId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)reuseId
{
    return objc_getAssociatedObject(self, ReuseIdPropertyKey);
}

- (FGNotifyCustomViewResultHolder *)notifyHolder
{
    return objc_getAssociatedObject(self, NotifyHolderPropertyKey);
}

-(void)setNotifyHolder:(FGNotifyCustomViewResultHolder *)notifyHolder
{
    objc_setAssociatedObject(self, NotifyHolderPropertyKey, notifyHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setApplyStyleHolder:(FGNavigationBarStyleBlockHolder *)applyStyleHolder
{
    objc_setAssociatedObject(self, StyleBlockHolderPropertyKey, applyStyleHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FGNavigationBarStyleBlockHolder *)applyStyleHolder
{
    return objc_getAssociatedObject(self, StyleBlockHolderPropertyKey);
}

@end

static void * LeftPoolPropertyKey = &LeftPoolPropertyKey;
static void * RightPoolPropertyKey = &RightPoolPropertyKey;


@implementation UINavigationItem (FGNavigationBar)

- (void)setLeftPool:(FGReuseItemPool *)leftPool
{
    objc_setAssociatedObject(self, LeftPoolPropertyKey, leftPool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FGReuseItemPool *)leftPool
{
    return objc_getAssociatedObject(self, LeftPoolPropertyKey);
}

- (void)setRightPool:(FGReuseItemPool *)rightPool
{
    objc_setAssociatedObject(self, RightPoolPropertyKey, rightPool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FGReuseItemPool *)rightPool
{
    return objc_getAssociatedObject(self, RightPoolPropertyKey);
}

@end

@implementation FGNavigationBarStyleBlockHolder

+ (FGNavigationBarStyleBlockHolder *) holderWithBlock:(void (^)(UIBarButtonItem *))block
{
    FGNavigationBarStyleBlockHolder *holder = [[FGNavigationBarStyleBlockHolder alloc] init];
    holder.block = block;
    return holder;
}

-(void)notify:(UIBarButtonItem *)item
{
    if (self.block != nil) {
        self.block(item);
    }
}

@end
