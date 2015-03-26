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

- (NSInteger) carouselSelectedIndex;

- (void) endCarousel;

@property (nonatomic, strong) FGReuseItemPool *pool;

@property (nonatomic, assign) BOOL isWrapEnabled;

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
    NSNumber *num = [self customData: CarouselSelectedIndexMethodKey data:nil];
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



- (id) customData:(void *)key data:(NSDictionary *)data
{
    if (key == CarouselSelectedIndexMethodKey) {
        return [NSNumber numberWithInteger: [self carouselSelectedIndex]];
    }else if(key == EndCarouselMethodKey){
        [self endCarousel];
    }else{
        return [parentContext customData:key data:data];
    }
    return nil;
}


- (void) beginCarousel
{
    if (self.pool == nil) {
        self.pool = [[FGReuseItemPool alloc] init];
    }
    [self.pool prepareUpdateItems];
}

- (NSInteger) carouselSelectedIndex
{
    return -1;
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

@end


