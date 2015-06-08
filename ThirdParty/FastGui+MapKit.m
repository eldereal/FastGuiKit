//
//  FastGui+MapKit.m
//  exibitour
//
//  Created by 易元 白 on 15/6/8.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import <objc/runtime.h>
#import "FastGui+MapKit.h"
#import "FGInternal.h"
#import "FGReuseItemPool.h"
#import "FGNullViewContext.h"
#import "FGStyle.h"
#import "UIView+FGStylable.h"
#import "FGViewGroup.h"

@interface OverlayWithRenderer : NSObject<FGWithReuseId>

@property (nonatomic, strong) id<MKOverlay> overlay;

@property (nonatomic, strong, readonly) MKOverlayRenderer * renderer;

- (instancetype) initWithRenderer: (MKOverlayRenderer *)renderer;

@end

@interface AnnotationWithView : NSObject<FGWithReuseId>

@property (nonatomic, strong) id<MKAnnotation> annotation;

@property (nonatomic, strong) MKAnnotationView * view;

@property (nonatomic, strong) UIView *customView;

@end

@interface FGMapViewContext : FGNullViewContext<MKMapViewDelegate>

@property (nonatomic, weak) MKMapView *mapView;

@property (nonatomic, strong) FGReuseItemPool *pool;

- (void) beginMapView;

@end

@interface FGMapViewHolderView : UIView

@property (nonatomic, strong) FGMapViewContext *guiContext;

@property (nonatomic, strong) MKMapView *mapView;

@end

static void *EndMapViewMethodKey = &EndMapViewMethodKey;
static void *MapViewSetRegionMethodKey = &MapViewSetRegionMethodKey;
static NSString *MapViewSetRegionDataKey = @"MapViewSetRegionDataKey";
static void *MapViewPolylineMethodKey = &MapViewPolylineMethodKey;
static void *MapTextCalloutPinMethodKey = &MapTextCalloutPinMethodKey;
@implementation FastGui (BMKMapView)

+ (MKCoordinateRegion)beginMapView
{
    MKCoordinateRegion zero = MKCoordinateRegionZero;
    return [self beginMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:zero styleClass:nil];
}

+ (MKCoordinateRegion)beginMapViewWithStyleClass:(NSString *)styleClass
{
    MKCoordinateRegion zero = MKCoordinateRegionZero;
    return [self beginMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:zero styleClass:styleClass];
}

+ (MKCoordinateRegion)beginMapViewWithRegion:(MKCoordinateRegion)region
{
    return [self beginMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:region styleClass:nil];
}

+ (MKCoordinateRegion)beginMapViewWithRegion:(MKCoordinateRegion)region styleClass:(NSString *)styleClass
{
    return [self beginMapViewWithReuseId:[FGInternal callerPositionAsReuseId] region:region styleClass:styleClass];
}

+ (MKCoordinateRegion)beginMapViewWithReuseId:(NSString *)reuseId region:(MKCoordinateRegion)region styleClass:(NSString *)styleClass
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

+ (void)mapViewSetRegion:(MKCoordinateRegion)region
{
    CGRect rect = CGRectMake(region.center.longitude, region.center.latitude, region.span.longitudeDelta, region.span.latitudeDelta);
    [self customData:MapViewSetRegionMethodKey data:@{
            MapViewSetRegionDataKey : [NSValue valueWithCGRect:rect]
    }];
}

+ (void)mapViewPolyline:(MKPolyline *)polyline
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [self customData:MapViewPolylineMethodKey data:@{@"reuseId" : reuseId, @"polyline" : polyline}];
}

+ (void)mapViewPolyline:(MKPolyline *)polyline styleClass:(NSString *)styleClass
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [self customData:MapViewPolylineMethodKey data:@{@"reuseId" : reuseId, @"polyline" : polyline, @"styleClass" : styleClass}];
}

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle
{
    [self customData:MapTextCalloutPinMethodKey data:@{@"reuseId" : [FGInternal callerPositionAsReuseId], @"location" : [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"calloutText" : calloutText, @"subtitle" : subtitle == nil ? [NSNull null] : subtitle}];
}

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle:(NSString *)subtitle withPinImageName:(NSString *)imageName
{
    [self customData:MapTextCalloutPinMethodKey data:@{@"reuseId" : [FGInternal callerPositionAsReuseId], @"location" : [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"calloutText" : calloutText, @"subtitle" : subtitle == nil ? [NSNull null] : subtitle, @"image" : [UIImage imageNamed:imageName]}];
}

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle:(NSString *)subtitle withPinImage:(UIImage *)image;
{
    [self customData:MapTextCalloutPinMethodKey data:@{@"reuseId" : [FGInternal callerPositionAsReuseId], @"location" : [NSValue valueWithCGPoint:CGPointMake(location.longitude, location.latitude)], @"calloutText" : calloutText, @"subtitle" : subtitle == nil ? [NSNull null] : subtitle, @"image" : image}];
}

+ (void)endMapView
{
    [self customData:EndMapViewMethodKey data:nil];
}

@end

@implementation FGMapViewContext

- (void)beginMapView
{
    [self.pool prepareUpdateItems];
}

- (void) endMapView
{
    [self.pool finishUpdateItems:nil needRemove:^(id item) {
        if ([item isKindOfClass:[OverlayWithRenderer class]]) {
            [self.mapView removeOverlay: ((OverlayWithRenderer*)item).overlay];
        }else if([item isKindOfClass:[AnnotationWithView class]]){
            [self.mapView removeAnnotation:((AnnotationWithView*)item).annotation];
        }
    }];
    [FastGui popContext];
}

- (void) setRegion:(MKCoordinateRegion) region
{
    if (region.center.latitude == 0 && region.center.longitude == 0 && region.span.latitudeDelta == 0 && region.span.longitudeDelta == 0) {
        
    }else{
        self.mapView.region = region;
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndMapViewMethodKey) {
        [self endMapView];
        return nil;
    }else if(key == MapViewSetRegionMethodKey){
        CGRect rect = [(NSValue *)(data[MapViewSetRegionDataKey]) CGRectValue];
        MKCoordinateRegion r = MKCoordinateRegionMake(CLLocationCoordinate2DMake(rect.origin.y, rect.origin.x), MKCoordinateSpanMake(rect.size.height, rect.size.width));
        [self setRegion:r];
        return nil;
    }else if(key == MapViewPolylineMethodKey){
        [self polylineWithReuseId:data[@"reuseId"] polyline:data[@"polyline"] styleClass:data[@"styleClass"]];
        return nil;
    }else if(key == MapTextCalloutPinMethodKey){
        id subtitle = data[@"subtitle"];
        if (subtitle == [NSNull null]) {
            subtitle = nil;
        }
        [self textPinWithReuseId:data[@"reuseId"] location:CLLocationCoordinate2DMake([(NSValue *)data[@"location"] CGPointValue].y, [(NSValue *)data[@"location"] CGPointValue].x) calloutText:data[@"calloutText"] subtitle:subtitle withPinImage:data[@"image"]];
    }
    
    return [self.parentContext customData:key data:data];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    [[NSError customError:CustomErrorUnknown] println];
    return nil;
}

- (MKOverlayRenderer *) customOverlay:(id<MKOverlay>) overlay withReuseId:(NSString *)reuseId withRenderer: (MKOverlayRenderer *(^)(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer)) initBlock
{
    BOOL isNew;
    OverlayWithRenderer *ov = [self.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        OverlayWithRenderer * ov = (OverlayWithRenderer *) reuseItem;
        if (ov == nil) {
            ov = [[OverlayWithRenderer alloc] initWithRenderer:initBlock(overlay, nil)];
            ov.overlay = overlay;
        }else{
            MKOverlayRenderer *r = initBlock(ov.overlay, ov.renderer);
            if (r != ov.renderer) {
                ov = [[OverlayWithRenderer alloc] initWithRenderer:r];
                ov.overlay = overlay;
            }
        }
        return ov;
    } outputIsNewView: &isNew];
    if (isNew) {
        [self.mapView addOverlay:overlay];
    }
    return ov.renderer;
}

- (MKAnnotationView *) customAnnotation: (id<MKAnnotation>)annotation withReuseId:(NSString *)reuseId withView: (MKAnnotationView *(^)(MKAnnotationView *reuseView)) initBlock
{
    return nil;
}

- (void) polylineWithReuseId: (NSString *)reuseId polyline: (MKPolyline *) polyline styleClass: (NSString *) styleClass
{
    [self customOverlay:polyline withReuseId:reuseId withRenderer:^MKOverlayRenderer *(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer) {
        MKPolylineRenderer *renderer = (MKPolylineRenderer*)reuseRenderer;
        if (renderer == nil) {
            renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        }
        return renderer;
    }];
}

- (void) textPinWithReuseId: (NSString *) reuseId location: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image
{
    BOOL isNew = NO;
    AnnotationWithView *item = (AnnotationWithView *)[self.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        AnnotationWithView *item = (AnnotationWithView *)reuseItem;
        if (item == nil) {
            item = [[AnnotationWithView alloc] init];
            item.annotation = [[MKPointAnnotation alloc] init];
            if (image == nil) {
                item.view = [[MKPinAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
                ((MKPinAnnotationView *)item.view).animatesDrop = NO;
            }else{
                item.view = [[MKAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
                
            }
            item.view.canShowCallout = YES;
            
        }
        if (image != nil) {
            item.view.image = image;
        }
        ((MKPointAnnotation *)item.annotation).title = calloutText;
        ((MKPointAnnotation *)item.annotation).subtitle = subtitle;
        ((MKPointAnnotation *)item.annotation).coordinate = location;
        return item;
    } outputIsNewView:&isNew];
    if (isNew) {
        [self.mapView addAnnotation:item.annotation];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    for (id item in self.pool.items) {
        if ([item isKindOfClass:[OverlayWithRenderer class]]) {
            if (((OverlayWithRenderer*)item).overlay == overlay) {
                return ((OverlayWithRenderer*)item).renderer;
            }
        }
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
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
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.guiContext = [[FGMapViewContext alloc] init];
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

@implementation OverlayWithRenderer

@synthesize reuseId;

@synthesize renderer = _renderer;

- (instancetype)initWithRenderer:(MKOverlayRenderer *)renderer
{
    self = [self init];
    if (self) {
        _renderer = renderer;
    }
    return self;
}

@end

@implementation AnnotationWithView

@synthesize reuseId;

@end

@interface MKPolylineView(FastGui)<FGStylable>

@end

@implementation MKPolylineView(FastGui)

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