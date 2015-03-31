//
//  iCarousel+FastGui.h
//  train-helper
//
//  Created by 易元 白 on 15/3/13.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGStyle.h"
#import <iCarousel/iCarousel.h>

@interface FastGui(iCarousel)

+ (void) beginCarousel;

+ (void) beginCarouselWithStyleClass: (NSString *) styleClass;

+ (NSInteger) carouselSelectedIndex;

+ (void) endCarousel;

@end


@interface FGStyle(iCarousel)

+ (void) carouselWrap: (BOOL) isWarpEnabled;

+ (void) carouselPagingEnabled: (BOOL) isPaging;

+ (void) carouselScrollEnabled: (BOOL) scrollEnabled;

+ (void) carouselType: (iCarouselType) type;

+ (void) carouselBounces: (BOOL) bounces;

+ (void) carouselBounceDistance: (CGFloat) bounceDistance;

+ (void) carouselViewpointOffset: (CGSize) viewpointOffset;

+ (void) carouselContentOffset: (CGSize) contentOffset;

@end
