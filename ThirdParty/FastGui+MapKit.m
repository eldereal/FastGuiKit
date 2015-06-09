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

@end

@interface FGMapView : MKMapView

@end

@interface FGMapViewContext : FGNullViewContext

@property (nonatomic, strong, readonly) FGMapView *mapView;

- (instancetype) initWithMapView:(MKMapView *) mapView;

- (void) beginMapView;

@end

@interface FGMapView()<MKMapViewDelegate>

@property (nonatomic, strong) FGReuseItemPool *pool;

@end

static void *EndMapViewMethodKey = &EndMapViewMethodKey;
static void *MapViewSetRegionMethodKey = &MapViewSetRegionMethodKey;
static NSString *MapViewSetRegionDataKey = @"MapViewSetRegionDataKey";
static void* MapViewCustomOverlay = &MapViewCustomOverlay;
static void* MapViewCustomAnnotation = &MapViewCustomAnnotation;

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
    FGMapView *view = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        FGMapView *view = (FGMapView *) reuseView;
        if (view == nil) {
            view = [[FGMapView alloc] init];
            
            if (region.center.latitude == 0 && region.center.longitude == 0 && region.span.latitudeDelta == 0 && region.span.longitudeDelta == 0) {
                view.showsUserLocation = YES;
            }else{
                view.showsUserLocation = NO;
                view.region = region;
            }
        }
        return view;
    } resultBlock:^(id view){ return view; }];
    FGMapViewContext *ctx = [[FGMapViewContext alloc] initWithMapView:view];
    [ctx beginMapView];
    [FastGui pushContext:ctx];
    return view.region;
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
    [self mapViewPolylineWithReuseId:[FGInternal callerPositionAsReuseId] polyline:polyline styleClass:nil];
}

+ (void)mapViewPolyline:(MKPolyline *)polyline styleClass:(NSString *)styleClass
{
    [self mapViewPolylineWithReuseId:[FGInternal callerPositionAsReuseId] polyline:polyline styleClass:nil];
}

+ (void)mapViewPolylineWithReuseId:(NSString *) reuseId polyline:(MKPolyline *)polyline styleClass:(NSString *)styleClass
{
    [self mapViewCustomOverlayWithBlock:^id<MKOverlay>(id<MKOverlay> reuseOverlay) {
        return polyline;
    } withReuseId:reuseId withRenderer:^MKOverlayRenderer *(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer) {
        MKPolylineRenderer *renderer = (MKPolylineRenderer*)reuseRenderer;
        if (renderer == nil) {
            renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        }
        return renderer;
    } resultBlock:nil];
}

+ (void)mapViewTileOverlayWithUrlTemplate:(NSString *)template
{
    [self mapViewCustomOverlayWithBlock:^id<MKOverlay>(id<MKOverlay> reuseOverlay) {
        MKTileOverlay * to = (MKTileOverlay *)reuseOverlay;
        if (![to.URLTemplate isEqualToString:template]) {
            to = [[MKTileOverlay alloc] initWithURLTemplate:template];
        }
        return to;
    } withReuseId:[FGInternal callerPositionAsReuseId] withRenderer:^MKOverlayRenderer *(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer) {
        MKTileOverlayRenderer *render = (MKTileOverlayRenderer *) reuseRenderer;
        if (render.overlay != overlay) {
            render = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
        }
        return render;
    } resultBlock:nil];
}

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle
{
    [self mapViewTextCalloutPinWithReuseId:[FGInternal callerPositionAsReuseId] location:location calloutText:calloutText subtitle:subtitle withPinImage:nil];
}

+ (void) mapViewTextCalloutPinWithReuseId: (NSString *) reuseId location: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image
{
    
    [self mapViewCustomAnnotationWithBlock:^id<MKAnnotation>(id<MKAnnotation> reuseAnnotation) {
        MKPointAnnotation *anno = (MKPointAnnotation *) reuseAnnotation;
        if (anno == nil) {
            anno = [[MKPointAnnotation alloc] init];
        }
        anno.coordinate = location;
        anno.title = calloutText;
        anno.subtitle = subtitle;
        return anno;
    } withReuseId:[FGInternal callerPositionAsReuseId] withView:^MKAnnotationView *(id<MKAnnotation> annotation, MKAnnotationView *reuseView) {
        if (reuseView.annotation != annotation || (image != nil && [reuseView isKindOfClass:[MKPinAnnotationView class]]) || (image == nil && ![reuseView isKindOfClass:[MKPinAnnotationView class]])) {
            reuseView = [image == nil ? [MKPinAnnotationView alloc] : [MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        }
        if (image != nil) {
            reuseView.image = image;
        }
        reuseView.canShowCallout = calloutText != nil || subtitle != nil;
        return reuseView;
    } resultBlock:nil];
//    [self mapviewc]
//    AnnotationWithView *item = (AnnotationWithView *)[self.mapView.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
//        AnnotationWithView *item = (AnnotationWithView *)reuseItem;
//        if (item == nil) {
//            item = [[AnnotationWithView alloc] init];
//            item.annotation = [[MKPointAnnotation alloc] init];
//            if (image == nil) {
//                item.view = [[MKPinAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
//                ((MKPinAnnotationView *)item.view).animatesDrop = NO;
//            }else{
//                item.view = [[MKAnnotationView alloc] initWithAnnotation:item.annotation reuseIdentifier:reuseId];
//                
//            }
//            item.view.canShowCallout = YES;
//            
//        }
//        if (image != nil) {
//            item.view.image = image;
//        }
//        ((MKPointAnnotation *)item.annotation).title = calloutText;
//        ((MKPointAnnotation *)item.annotation).subtitle = subtitle;
//        ((MKPointAnnotation *)item.annotation).coordinate = location;
//        return item;
//    } outputIsNewView:&isNew];
//    if (isNew) {
//        [self.mapView addAnnotation:item.annotation];
//    }
}



+ (id)mapViewCustomOverlayWithBlock:(id<MKOverlay> (^)(id<MKOverlay>))initOverlay withReuseId:(NSString *)reuseId withRenderer:(MKOverlayRenderer *(^)(id<MKOverlay>, MKOverlayRenderer *))initRender resultBlock:(id (^)(id<MKOverlay>, MKOverlayRenderer *))resultBlock
{
    id resultBlockOrNull = resultBlock == nil ? [NSNull null] : (id) resultBlock;
    return [self customData:MapViewCustomOverlay data:@{@"reuseId": reuseId, @"initOverlay": initOverlay, @"initRender": initRender, @"resultBlock": resultBlockOrNull}];
}

+ (id) mapViewCustomAnnotationWithBlock: (id<MKAnnotation>(^)(id<MKAnnotation> reuseAnnotation))initAnnotation withReuseId:(NSString *)reuseId withView: (MKAnnotationView *(^)(id<MKAnnotation> annotation, MKAnnotationView *reuseView)) initView resultBlock: (id(^)(id<MKAnnotation> annotation, MKAnnotationView * view)) resultBlock
{
    id resultBlockOrNull = resultBlock == nil ? [NSNull null] : (id) resultBlock;
    return [self customData:MapViewCustomAnnotation data:@{@"reuseId": reuseId, @"initAnnotation": initAnnotation, @"initView": initView, @"resultBlock": resultBlockOrNull}];

}

+ (void)endMapView
{
    [self customData:EndMapViewMethodKey data:nil];
}

@end

@implementation FGMapViewContext

@synthesize mapView = _mapView;

- (instancetype)initWithMapView:(FGMapView *)mapView
{
    self = [super init];
    if (self) {
        _mapView = mapView;
    }
    return self;
}

- (void) beginMapView
{
    [self.mapView.pool prepareUpdateItems];
}

- (void) endMapView
{
    [self.mapView.pool finishUpdateItems:nil needRemove:^(id item) {
        if ([item isKindOfClass:[OverlayWithRenderer class]]) {
            [self.mapView removeOverlay: ((OverlayWithRenderer*)item).overlay];
        }
        else if([item isKindOfClass:[AnnotationWithView class]]){
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
    }else if(key == MapViewCustomAnnotation){
        id resultOrNull = data[@"resultBlock"];
        if (resultOrNull == [NSNull null]) {
            resultOrNull = nil;
        }
        return [self customAnnotationWithBlock:data[@"initAnnotation"] withReuseId:data[@"reuseId"] withView:data[@"initView"] resultBlock:resultOrNull];
    }else if(key == MapViewCustomOverlay){
        id resultOrNull = data[@"resultBlock"];
        if (resultOrNull == [NSNull null]) {
            resultOrNull = nil;
        }
        return [self customOverlayWithBlock:data[@"initOverlay"] withReuseId:data[@"reuseId"] withRenderer:data[@"initRender"] resultBlock:resultOrNull];
    }
        
    
    return [self.parentContext customData:key data:data];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    return nil;
}

- (id) customOverlayWithBlock:(id<MKOverlay>(^)(id<MKOverlay> reuseOverlay)) initOverlay withReuseId:(NSString *)reuseId withRenderer: (MKOverlayRenderer *(^)(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer)) initRender resultBlock:(id (^)(id<MKOverlay>, MKOverlayRenderer *))resultBlock
{
    BOOL isNew;
    OverlayWithRenderer *ov = [self.mapView.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        OverlayWithRenderer * ov = (OverlayWithRenderer *) reuseItem;
        if (ov == nil) {
            id<MKOverlay> overlay = initOverlay(nil);
            ov = [[OverlayWithRenderer alloc] initWithRenderer:initRender(overlay, nil)];
            ov.overlay = overlay;
        }else{
            id<MKOverlay> overlay = initOverlay(ov.overlay);
            MKOverlayRenderer *r = initRender(overlay, ov.renderer);
            if (r != ov.renderer || overlay != ov.overlay) {
                ov = [[OverlayWithRenderer alloc] initWithRenderer:r];
                ov.overlay = overlay;
            }
        }
        return ov;
    } outputIsNewView: &isNew];
    if (isNew) {
        [self.mapView addOverlay:ov.overlay];
    }
    if (resultBlock != nil) {
        return resultBlock(ov.overlay, ov.renderer);
    }else{
        return nil;
    }
}

- (id) customAnnotationWithBlock: (id<MKAnnotation>(^)(id<MKAnnotation> reuseAnnotation))initAnnotation withReuseId:(NSString *)reuseId withView: (MKAnnotationView *(^)(id<MKAnnotation> annotation, MKAnnotationView *reuseView)) initView resultBlock: (id(^)(id<MKAnnotation> annotation, MKAnnotationView * view)) resultBlock
{
    BOOL isNew;
    AnnotationWithView *av = [self.mapView.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        AnnotationWithView * av = (AnnotationWithView *) reuseItem;
        if (av == nil) {
            id<MKAnnotation> annotation = initAnnotation(nil);
            MKAnnotationView *view = initView(annotation, nil);
            av = [[AnnotationWithView alloc] init];
            av.annotation = annotation;
            av.view = view;
        }else{
            id<MKAnnotation> annotation = initAnnotation(av.annotation);
            MKAnnotationView *view = initView(annotation, av.view);
            if (view != av.view || annotation != av.annotation) {
                av = [[AnnotationWithView alloc] init];
                av.annotation = annotation;
                av.view = view;
            }
        }
        return av;
    } outputIsNewView: &isNew];
    if (isNew) {
        [self.mapView addAnnotation:av.annotation];
    }
    if (resultBlock != nil) {
        return resultBlock(av.annotation, av.view);
    }else{
        return nil;
    }
}


//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
//{
//    for (id item in self.mapView.pool.items) {
//        if ([item isKindOfClass:[OverlayWithRenderer class]]) {
//            if (((OverlayWithRenderer*)item).overlay == overlay) {
//                return ((OverlayWithRenderer*)item).renderer;
//            }
//        }
//    }
//    return nil;
//}
//
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    for (AnnotationWithView *item in self.pool.items) {
//        if ([item isKindOfClass:[AnnotationWithView class]] && item.annotation == annotation) {
//            return item.view;
//        }
//    }
//    return nil;
//}

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

@implementation FGMapView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pool = [[FGReuseItemPool alloc] init];
        self.delegate = self;
    }
    return self;
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

//@implementation MKPolylineView(FastGui)
//
//- (void) styleWithBorder:(UIColor *)color width:(CGFloat)borderWidth
//{
//    self.strokeColor = color;
//    self.lineWidth = borderWidth;
//}
//
//- (void) styleWithBorderColor:(UIColor *)borderColor
//{
//    self.strokeColor = borderColor;
//}
//
//- (void) styleWithBorderWidth:(CGFloat)borderWidth
//{
//    self.lineWidth = borderWidth;
//}
//
//- (void) styleWithColor:(UIColor *)color
//{
//    self.strokeColor = color;
//}
//
//@end