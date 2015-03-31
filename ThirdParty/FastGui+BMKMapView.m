//
//  FastGui+BMKMapView.m
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <objc/runtime.h>
#import "FastGui+BMKMapView.h"
#import "FGInternal.h"
#import "FGReuseItemPool.h"
#import "FGNullViewContext.h"

const BMKCoordinateRegion BMKCoordinateRegionZero = {{0, 0}, {0, 0}};

@interface BMKMapViewContext : FGNullViewContext

@property (nonatomic, weak) BMKMapView *mapView;

- (void) beginMapView;

@end

@interface FGMapViewHolderView : UIView

@property (nonatomic, strong) BMKMapViewContext *guiContext;

@property (nonatomic, strong) BMKMapView *mapView;

@end



static void * EndBaiduMapViewMethodKey = &EndBaiduMapViewMethodKey;

@implementation FastGui (BMKMapView)

+ (BMKCoordinateRegion)beginBaiduMapView
{
    return [self beginBaiduMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:BMKCoordinateRegionZero styleClass:nil];
}

+ (BMKCoordinateRegion)beginBaiduMapViewWithStyleClass:(NSString *)styleClass
{
    return [self beginBaiduMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:BMKCoordinateRegionZero styleClass:styleClass];
}

+ (BMKCoordinateRegion)beginBaiduMapViewWithRegion:(BMKCoordinateRegion)region
{
    return [self beginBaiduMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:region styleClass:nil];
}

+ (BMKCoordinateRegion)beginBaiduMapViewWithRegion:(BMKCoordinateRegion)region styleClass:(NSString *)styleClass
{
    return [self beginBaiduMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:region styleClass:styleClass];
}

+ (BMKCoordinateRegion)beginBaiduMapViewWithReuseId:(NSString *)reuseId region:(BMKCoordinateRegion)region styleClass:(NSString *)styleClass
{
    FGMapViewHolderView *view = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        FGMapViewHolderView *view = (FGMapViewHolderView *) reuseView;
        if (view == nil) {
            view = [[FGMapViewHolderView alloc] init];
            
            if (region.center.latitude == 0 && region.center.longitude == 0 && region.span.latitudeDelta == 0 && region.span.longitudeDelta == 0) {
                view.mapView.showsUserLocation = YES;
            }else{
                view.mapView.showsUserLocation = NO;
                view.mapView.region = region;
            }
        }
        return view;
    } resultBlock:^(id view){ return view; }];
    [FastGui pushContext:view.guiContext];
    [view.guiContext beginMapView];
    return view.mapView.region;
}

+ (void)endBaiduMapView
{
    [self customData:EndBaiduMapViewMethodKey data:nil];
}

@end

@implementation BMKMapViewContext

- (void)beginMapView
{
    
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndBaiduMapViewMethodKey) {
        [FastGui popContext];
        return nil;
    }
    return [self.parentContext customData:key data:data];
}

@end

@implementation FGMapViewHolderView

- (instancetype)init
{
    if (self = [super init]) {
        self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.guiContext = [[BMKMapViewContext alloc] init];
        self.guiContext.mapView = self.mapView;
        [self addSubview:self.mapView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.mapView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end