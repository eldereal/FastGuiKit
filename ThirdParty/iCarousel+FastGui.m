//
//  iCarousel+FastGui.m
//  train-helper
//
//  Created by 易元 白 on 15/3/13.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "iCarousel+FastGui.h"

#import <iCarousel/iCarousel.h>
#import "FGInternal.h"
#import "FGReuseItemPool.h"
#import "UIView+applyStyleAfterAddedToSuperview.h"
#import "UIView+FGStylable.h"

@interface FGCarousel : iCarousel<FGContext, iCarouselDataSource, iCarouselDelegate>

- (void) beginCarousel;

- (void) endCarousel;

@property (nonatomic, strong) FGReuseItemPool *pool;

@property (nonatomic, assign) BOOL isWrapEnabled;

@property (nonatomic, assign) CGFloat autopaging;

@property (nonatomic, assign) BOOL dispatchingNextPage;

@property (nonatomic, assign) BOOL updateWhenChangeCurrentPage;

@end

static void * CarouselSelectedIndexMethodKey = &CarouselSelectedIndexMethodKey;
static void * EndCarouselMethodKey = &EndCarouselMethodKey;

@implementation FastGui(iCarousel)

+ (void) beginCarousel
{
    [self beginCarouselWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void) beginCarouselWithStyleClass:(NSString *)styleClass
{
    [self beginCarouselWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void) beginCarouselWithReuseId: (NSString *) reuseId styleClass:(NSString *)styleClass
{
    FGCarousel *carousel = [self customViewWithClass: styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        FGCarousel *c = (FGCarousel *) reuseView;
        if (c == nil) {
            c = [[FGCarousel alloc] init];
            c.delegate = c;
            c.dataSource = c;
        }
        [c beginCarousel];
        return c;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    [self pushContext: carousel];
}

+ (NSInteger) carouselSelectedIndex
{
    NSNumber *num = [self customData: CarouselSelectedIndexMethodKey data:@{}];
    if (num == nil) {
        return -1;
    }else{
        return [num integerValue];
    }
}

+ (NSInteger)carouselSelectedIndexUpdate
{
    NSNumber *num = [self customData: CarouselSelectedIndexMethodKey data:@{@"update":[NSNumber numberWithBool:YES]}];
    if (num == nil) {
        return -1;
    }else{
        return [num integerValue];
    }
}

+ (void) endCarousel
{
    [self customData:EndCarouselMethodKey data:nil];
}

@end


@implementation FGCarousel

@synthesize parentContext;

- (void) reloadGui
{
    [self.parentContext reloadGui];
}

- (void) styleSheet
{
    [self.parentContext styleSheet];
}

- (void)setAutopaging:(CGFloat)autopaging
{
    _autopaging = autopaging;
    [self updateDispatching];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    [super setPagingEnabled:pagingEnabled];
    if (pagingEnabled) {
        self.autoscroll = 0;
    }
    [self updateDispatching];
}

- (void)setAutoscroll:(CGFloat)autoscroll
{
    if (self.pagingEnabled) {
        self.autopaging = autoscroll;
        [super setAutoscroll:0];
    }else{
        [super setAutoscroll:autoscroll];
    }
    [self updateDispatching];
}

- (void) updateDispatching
{
    if (self.autopaging > 0 && self.pagingEnabled && !self.dispatchingNextPage) {
        __weak FGCarousel * weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/self.autopaging * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf == nil) {
                return;
            }
            [weakSelf scrollToItemAtIndex:self.isWrapEnabled ? (weakSelf.currentItemIndex + 1) : (weakSelf.currentItemIndex + 1) % self.numberOfItems animated:YES];
            weakSelf.dispatchingNextPage = NO;
            [weakSelf updateDispatching];
        });
        self.dispatchingNextPage = YES;
    }
}

- (id) customData:(void *)key data:(NSDictionary *)data
{
    if (key == CarouselSelectedIndexMethodKey) {
        if ([(NSNumber *)data[@"update"] boolValue]) {
            self.updateWhenChangeCurrentPage = YES;
        }
        return [NSNumber numberWithInteger: [self currentItemIndex]];
    }else if(key == EndCarouselMethodKey){
        [self endCarousel];
    }else{
        return [parentContext customData:key data:data];
    }
    return nil;
}


- (void) beginCarousel
{
    self.updateWhenChangeCurrentPage = NO;
    if (self.pool == nil) {
        self.pool = [[FGReuseItemPool alloc] init];
    }
    [self.pool prepareUpdateItems];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    BOOL isNew;
    UIView *view = (UIView *)[self.pool updateItem:reuseId initBlock:initBlock outputIsNewView: &isNew];
    
    if (isNew) {
        [view sizeStyleSetFrame];
        [view positionStyleDisabledWithTip: @"carousel doesn't support position styles"];
        view.frame = self.frame;
    }
    
    applyStyleBlock(view);
    
    if (resultBlock == nil) {
        return nil;
    }else{
        return resultBlock(view);
    }
}

- (void) endCarousel
{
    [self.pool finishUpdateItems:nil needRemove:nil];
    [self reloadData];
    
    [FastGui popContext];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (void)dismissViewController
{
    [parentContext dismissViewController];
}

- (NSInteger) numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.pool.items.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    return self.pool.items[index];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return self.isWrapEnabled ? 1:0;
    }else{
        return value;
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    if (self.updateWhenChangeCurrentPage) {
        [FastGui reloadGui];
    }
}

@end

@implementation FGStyle(iCarousel)

+ (void) carouselWrap: (BOOL) isWarpEnabled
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).isWrapEnabled = isWarpEnabled;
        }
    }];
}

+ (void) carouselPagingEnabled: (BOOL) isPaging
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).pagingEnabled = isPaging;
        }
    }];
}

+ (void) carouselScrollEnabled: (BOOL) scrollEnabled
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).scrollEnabled = scrollEnabled;
        }
    }];
}

+ (void)carouselAutoScrollInterval:(NSTimeInterval)autoscrollInterval
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).autoscroll = 1/autoscrollInterval;
        }
    }];
}

+ (void) carouselType: (iCarouselType) type
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).type = type;
        }
    }];
}

+ (void) carouselBounces: (BOOL) bounces
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).bounces = bounces;
        }
    }];
}

+ (void) carouselBounceDistance: (CGFloat) bounceDistance
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).bounceDistance = bounceDistance;
        }
    }];
}

+ (void)carouselContentOffset:(CGSize)contentOffset
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).contentOffset = contentOffset;
        }
    }];
}

+ (void)carouselViewpointOffset:(CGSize)viewpointOffset
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGCarousel class]]) {
            ((FGCarousel *) view).viewpointOffset = viewpointOffset;
        }
    }];
}

@end


