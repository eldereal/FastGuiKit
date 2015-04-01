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
#import "FGStyle.h"
#import "UIView+FGStylable.h"
#import "FGViewGroup.h"

@interface NSObject(BMKMapView)

@property (nonatomic, strong) UIView * associateView;

@end

@interface OverlayWithView : NSObject<FGWithReuseId>

@property (nonatomic, strong) id<BMKOverlay> overlay;

@property (nonatomic, strong) BMKOverlayView * view;

@end

@interface AnnotationWithView : FGNullViewContext<FGWithReuseId>

@property (nonatomic, strong) id<BMKAnnotation> annotation;

@property (nonatomic, strong) BMKAnnotationView * view;

@property (nonatomic, strong) UIView *customView;

@end

@interface BMKMapViewContext : FGNullViewContext<BMKMapViewDelegate>

@property (nonatomic, weak) BMKMapView *mapView;

@property (nonatomic, strong) FGReuseItemPool *pool;

@property (nonatomic, assign) BOOL allowCustomView;

@property (nonatomic, strong) NSMutableArray *oldOverlays;

@property (nonatomic, strong) NSMutableArray *overlays;

@property (nonatomic, strong) NSMutableArray *oldAnnotations;

@property (nonatomic, strong) NSMutableArray *annotations;

- (void) beginMapView;

@end

@interface FGMapViewHolderView : UIView

@property (nonatomic, strong) BMKMapViewContext *guiContext;

@property (nonatomic, strong) BMKMapView *mapView;

@end

static void * EndBaiduMapViewMethodKey = &EndBaiduMapViewMethodKey;
static void * BaiduMapViewSetRegionMethodKey = &BaiduMapViewSetRegionMethodKey;
static NSString * BaiduMapViewSetRegionDataKey = @"BaiduMapViewSetRegionDataKey";
static void * BaiduMapViewPolylineMethodKey = &BaiduMapViewPolylineMethodKey;
static void * BeginBaiduMapViewCalloutPinWithReuseIdMethodKey = &BeginBaiduMapViewCalloutPinWithReuseIdMethodKey;
static void * EndBaiduMapViewCalloutPinMethodKey = &EndBaiduMapViewCalloutPinMethodKey;
static void * BaiduMapTextCalloutPinMethodKey = &BaiduMapTextCalloutPinMethodKey;
@implementation FastGui (BMKMapView)

+ (BMKCoordinateRegion)beginBaiduMapView
{
    BMKCoordinateRegion zero = BMKCoordinateRegionZero;
    return [self beginBaiduMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:zero styleClass:nil];
}

+ (BMKCoordinateRegion)beginBaiduMapViewWithStyleClass:(NSString *)styleClass
{
    BMKCoordinateRegion zero = BMKCoordinateRegionZero;
    return [self beginBaiduMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:zero styleClass:styleClass];
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

+ (void)baiduMapViewSetRegion:(BMKCoordinateRegion)region
{
    CGRect rect = CGRectMake(region.center.longitude, region.center.latitude, region.span.longitudeDelta, region.span.latitudeDelta);
    [self customData:BaiduMapViewSetRegionMethodKey data:@{
                                                           BaiduMapViewSetRegionDataKey:[NSValue valueWithCGRect:rect]
    }];
}

+ (void)baiduMapViewPolyline:(BMKPolyline *)polyline
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [self customData:BaiduMapViewPolylineMethodKey data:@{@"reuseId": reuseId, @"polyline": polyline}];
}

+ (void)baiduMapViewPolyline:(BMKPolyline *)polyline styleClass:(NSString *)styleClass
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [self customData:BaiduMapViewPolylineMethodKey data:@{@"reuseId": reuseId, @"polyline": polyline, @"styleClass": styleClass}];
}

+ (void) baiduMapViewTextCalloutPinWithLocation: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle
{
    [self customData:BaiduMapTextCalloutPinMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"calloutText": calloutText, @"subtitle": subtitle}];
}

+ (void) baiduMapViewTextCalloutPinWithLocation: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImageName:(NSString *)imageName
{
    [self customData:BaiduMapTextCalloutPinMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"calloutText": calloutText, @"subtitle": subtitle, @"image": [UIImage imageNamed:imageName]}];
}

+ (void) baiduMapViewTextCalloutPinWithLocation: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image;
{
    [self customData:BaiduMapTextCalloutPinMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"calloutText": calloutText, @"subtitle": subtitle, @"image": image}];
}

+ (void)beginBaiduMapViewCalloutPinWithLocation:(CLLocationCoordinate2D)location
{
    [self customData:BeginBaiduMapViewCalloutPinWithReuseIdMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)]}];
}

+ (void)beginBaiduMapViewCalloutPinWithLocation:(CLLocationCoordinate2D)location styleClass:(NSString *)styleClass
{
    [self customData:BeginBaiduMapViewCalloutPinWithReuseIdMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"styleClass": styleClass}];
}

+ (void)beginBaiduMapViewCalloutPinWithLocation:(CLLocationCoordinate2D)location withImageName:(NSString *)imageName
{
    [self customData:BeginBaiduMapViewCalloutPinWithReuseIdMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"imageName": imageName}];
}

+ (void)beginBaiduMapViewCalloutPinWithLocation:(CLLocationCoordinate2D)location withImageName:(NSString *)imageName styleClass:(NSString *)styleClass
{
    [self customData:BeginBaiduMapViewCalloutPinWithReuseIdMethodKey data:@{@"reuseId": [FGInternal callerPositionAsReuseId], @"location": [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"imageName": imageName, @"styleClass": styleClass}];
}

+ (void)endBaiduMapViewCalloutPin
{
    [self customData:EndBaiduMapViewCalloutPinMethodKey data:nil];
}

+ (void)endBaiduMapView
{
    [self customData:EndBaiduMapViewMethodKey data:nil];
}

@end

@implementation BMKMapViewContext

- (void)beginMapView
{
    self.allowCustomView = NO;
    if (self.oldOverlays == nil) {
        self.oldOverlays = [NSMutableArray arrayWithArray:self.mapView.overlays];
    }else{
        [self.oldOverlays addObjectsFromArray:self.mapView.overlays];
    }
    if (self.overlays == nil) {
        self.overlays = [NSMutableArray array];
    }
    if (self.oldAnnotations == nil) {
        self.oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    }else{
        [self.oldAnnotations addObjectsFromArray:self.mapView.annotations];
    }
    if (self.annotations == nil) {
        self.annotations = [NSMutableArray array];
    }
    [self.pool prepareUpdateItems];
}

- (void) endMapView
{
    [self.mapView removeOverlays:[self.oldOverlays bk_select:^BOOL(id obj) {
        return [self.overlays bk_all:^BOOL(id obj2) {
            return obj2 != obj;
        }];
    }]];
    [self.oldOverlays removeAllObjects];
    [self.overlays removeAllObjects];
    
    [self.pool finishUpdateItems:nil needRemove:^(id item) {
        if ([item isKindOfClass:[OverlayWithView class]]) {
            [self.mapView removeOverlay: ((OverlayWithView*)item).overlay];
        }else if([item isKindOfClass:[AnnotationWithView class]]){
            [self.mapView removeAnnotation:((AnnotationWithView*)item).annotation];
        }
    }];
    [FastGui popContext];
}

- (void) setRegion:(BMKCoordinateRegion) region
{
    if (region.center.latitude == 0 && region.center.longitude == 0 && region.span.latitudeDelta == 0 && region.span.longitudeDelta == 0) {
        
    }else{
        self.mapView.region = region;
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndBaiduMapViewMethodKey) {
        [self endMapView];
        return nil;
    }else if(key == BaiduMapViewSetRegionMethodKey){
        CGRect rect = [(NSValue *)(data[BaiduMapViewSetRegionDataKey]) CGRectValue];
        BMKCoordinateRegion r = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(rect.origin.y, rect.origin.x), BMKCoordinateSpanMake(rect.size.height, rect.size.width));
        [self setRegion:r];
        return nil;
    }else if(key == BaiduMapViewPolylineMethodKey){
        [self polylineWithReuseId:data[@"reuseId"] polyline:data[@"polyline"] styleClass:data[@"styleClass"]];
        return nil;
    }else if(key == BeginBaiduMapViewCalloutPinWithReuseIdMethodKey){
        [self beginBaiduMapViewCalloutPinWithReuseId:data[@"reuseId"] location:CLLocationCoordinate2DMake([(NSValue *)data[@"location"] CGPointValue].y, [(NSValue *)data[@"location"] CGPointValue].x) withImageName:data[@"imageName"] styleClass:data[@"styleClass"]];
        return nil;
    }else if(key == EndBaiduMapViewCalloutPinMethodKey){
        [self endBaiduMapViewCalloutPin];
        return nil;
    }else if(key == BaiduMapTextCalloutPinMethodKey){
        [self textPinWithReuseId:data[@"reuseId"] location:CLLocationCoordinate2DMake([(NSValue *)data[@"location"] CGPointValue].y, [(NSValue *)data[@"location"] CGPointValue].x) calloutText:data[@"calloutText"] subtitle:data[@"subtitle"] withPinImage:data[@"image"]];
    }
        
    return [self.parentContext customData:key data:data];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if (self.allowCustomView) {
        UIView *view = initBlock(nil);
        applyStyleBlock(view);
    }
    return nil;
}

- (BMKOverlayView *) customOverlay:(id<BMKOverlay>) overlay withView: (BMKOverlayView *(^)(BMKOverlayView *reuseView)) initBlock
{
    for (NSObject *oldOverlay in self.oldOverlays) {
        if (overlay == oldOverlay) {
            oldOverlay.associateView = initBlock((BMKOverlayView *)oldOverlay.associateView);
            [self.overlays addObject:oldOverlay];
            return (BMKOverlayView *) oldOverlay.associateView;
        }
    }
    NSObject *overlayObj = overlay;
    overlayObj.associateView = initBlock((BMKOverlayView *)overlayObj.associateView);
    [self.overlays addObject:overlayObj];
    [self.mapView addOverlay:overlay];
    return (BMKOverlayView *) overlayObj.associateView;
}

- (BMKAnnotationView *) customAnnotation: (id<BMKAnnotation>)annotation withView: (BMKAnnotationView *(^)(BMKAnnotationView *reuseView)) initBlock
{
    for (NSObject *oldAnnotation in self.oldAnnotations) {
        if (annotation == oldAnnotation) {
            oldAnnotation.associateView = initBlock((BMKAnnotationView *)oldAnnotation.associateView);
            [self.annotations addObject:oldAnnotation];
            return (BMKAnnotationView *) oldAnnotation.associateView;
        }
    }
    NSObject *annotationObj = annotation;
    annotationObj.associateView = initBlock((BMKAnnotationView *)annotationObj.associateView);
    [self.annotations addObject:annotationObj.associateView];
    [self.mapView addAnnotation:annotation];
    return (BMKAnnotationView *) annotationObj.associateView;
}

- (void) polylineWithReuseId: (NSString *)reuseId polyline: (BMKPolyline *) polyline styleClass: (NSString *) styleClass
{
    BMKOverlayView * view = [self customOverlay:polyline withView:^BMKOverlayView *(BMKOverlayView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[BMKPolylineView alloc] initWithOverlay:polyline];
        }
        return reuseView;
    }];
    self.allowCustomView = YES;
    [FastGui customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        return view;
    } resultBlock:nil];
    self.allowCustomView = NO;
}

- (void) textPinWithReuseId: (NSString *) reuseId location: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image
{
    BOOL isNew = NO;
    AnnotationWithView *item = (AnnotationWithView *)[self.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        AnnotationWithView *item = (AnnotationWithView *)reuseItem;
        if (item == nil) {
            item = [[AnnotationWithView alloc] init];
            item.annotation = [[BMKPointAnnotation alloc] init];
            if (image == nil) {
                item.view = [[BMKPinAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
                ((BMKPinAnnotationView *)item.view).animatesDrop = NO;
            }else{
                item.view = [[BMKAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
                
            }
            item.view.canShowCallout = YES;
            
        }
        if (image != nil) {
            item.view.image = image;
        }
        ((BMKPointAnnotation *)item.annotation).title = calloutText;
        ((BMKPointAnnotation *)item.annotation).subtitle = subtitle;
        ((BMKPointAnnotation *)item.annotation).coordinate = location;
        return item;
    } outputIsNewView:&isNew];
    if (isNew) {
        [self.mapView addAnnotation:item.annotation];
    }
}

- (void) beginBaiduMapViewCalloutPinWithReuseId: (NSString *) reuseId location:(CLLocationCoordinate2D)location withImageName:(NSString *)imageName styleClass:(NSString *)styleClass
{
    BOOL isNew = NO;
    AnnotationWithView *item = (AnnotationWithView *)[self.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        AnnotationWithView *item = (AnnotationWithView *)reuseItem;
        if (item == nil) {
            item = [[AnnotationWithView alloc] init];
            item.annotation = [[BMKPointAnnotation alloc] init];
            if (imageName == nil) {
                item.view = [[BMKPinAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
            }else{
                item.view = [[BMKAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
            }
            item.view.canShowCallout = YES;
            ((BMKPointAnnotation *)item.annotation).title = @"";
        }
        ((BMKPointAnnotation *)item.annotation).coordinate = location;
        return item;
    } outputIsNewView:&isNew];
    if (isNew) {
        [self.mapView addAnnotation:item.annotation];
    }
    [FastGui pushContext:item];
    [FastGui beginGroupWithNextView];
    [FastGui customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
            [reuseView positionStyleDisabledWithTip:@"Callout view of pins on map doesn't support position style"];
            [reuseView sizeStyleSetFrame];
        }
        return reuseView;
    } resultBlock:nil];
}

- (void) endBaiduMapViewCalloutPin
{
    [FastGui endGroup];
    [FastGui popContext];
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    NSObject *obj = overlay;
    return (BMKOverlayView *) obj.associateView;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    for (AnnotationWithView *item in self.pool.items) {
        if ([item isKindOfClass:[AnnotationWithView class]] && item.annotation == annotation) {
            return item.view;
        }
    }
    return nil;
}

@end

@implementation FGMapViewHolderView

- (instancetype)init
{
    if (self = [super init]) {
        self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.guiContext = [[BMKMapViewContext alloc] init];
        self.guiContext.mapView = self.mapView;
        self.guiContext.pool = [[FGReuseItemPool alloc] init];
        self.mapView.delegate = self.guiContext;
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

@implementation OverlayWithView

@synthesize reuseId;

@end

@implementation AnnotationWithView

@synthesize reuseId;

- (id)customViewWithReuseId:(NSString *)customReuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if(self.view.paopaoView == nil){
        self.customView = initBlock(nil);
        applyStyleBlock(self.customView);
        self.view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:self.customView];
    }else{
        UIView *oldView = self.customView;
        if (![oldView.reuseId isEqualToString:customReuseId]) {
            oldView = nil;
        }
        self.customView = initBlock(oldView);
        self.customView.reuseId = customReuseId;
        applyStyleBlock(self.customView);
        if (self.customView != oldView) {
            self.view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:self.customView];
        }
    }
    return nil;
}

@end

@interface BMKPolylineView(FastGui)<FGStylable>



@end

@implementation BMKPolylineView(FastGui)

- (void) styleWithBorder:(UIColor *)color width:(CGFloat)borderWidth
{
    self.strokeColor = color;
    self.lineWidth = borderWidth;
}


- (void) styleWithBorderColor:(UIColor *)borderColor
{
    self.strokeColor = borderColor;
}

- (void) styleWithBorderWidth:(CGFloat)borderWidth
{
    self.lineWidth = borderWidth;
}

- (void) styleWithColor:(UIColor *)color
{
    self.strokeColor = color;
}

@end


@implementation NSObject(BMKMapView)

static void * AssociateViewPropertyKey = &AssociateViewPropertyKey;

- (UIView *)associateView
{
    return objc_getAssociatedObject(self, AssociateViewPropertyKey);
}

- (void)setAssociateView:(UIView *)associateView
{
    objc_setAssociatedObject(self, AssociateViewPropertyKey, associateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

