//
//  FastGui+MapKit.m
//  exibitour
//
//  Created by 易元 白 on 15/6/8.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import <objc/runtime.h>
#import <BlocksKit.h>
#import <BlocksKit+UIKit.h>
#import "FastGui+MapKit.h"
#import "FGInternal.h"
#import "FGReuseItemPool.h"
#import "FGNullViewContext.h"
#import "FGStyle.h"
#import "UIView+FGStylable.h"
#import "FGViewGroup.h"
#import "UIView+changingResult.h"

const MKCoordinateRegion MKCoordinateRegionZero = {{0,0},{0,0}};

@interface FakeViewForStylable : UIView<FGStylable>

@property (nonatomic, strong, readonly) id<FGStylable> target;

- (instancetype) initWithTarget: (id<FGStylable>) target;

@end

@interface OverlayWithRenderer : NSObject<FGWithReuseId>

@property (nonatomic, strong) id<MKOverlay> overlay;

@property (nonatomic, strong) MKOverlayRenderer * renderer;

@end

@interface AnnotationWithView : NSObject<FGWithReuseId>

@property (nonatomic, strong) id<MKAnnotation> annotation;

@property (nonatomic, strong) MKAnnotationView * view;

@end

@interface FGMapView : MKMapView

@property (nonatomic) MKMapRect limitRegion;
@property (nonatomic) double limitRegionMaxZoom;
@property (nonatomic) double limitRegionMinZoom;
@property (nonatomic) BOOL manuallyChangingMapRect;
@property (nonatomic) MKMapRect lastGoodMapRect;

@end

@interface FGMapViewContext : FGNullViewContext

@property (nonatomic, strong, readonly) FGMapView *mapView;

- (instancetype) initWithMapView:(MKMapView *) mapView;

- (void) beginMapView;

@end

@interface FGMapView()<MKMapViewDelegate>

@property (nonatomic, strong) FGReuseItemPool *pool;

@end

@interface MKPolylineRenderer(FGStylable)<FGStylable>

@end

static void *EndMapViewMethodKey = &EndMapViewMethodKey;
static void *MapViewSetRegionMethodKey = &MapViewSetRegionMethodKey;
static NSString *MapViewSetRegionDataKey = @"MapViewSetRegionDataKey";
static void* MapViewCustomOverlay = &MapViewCustomOverlay;
static void* MapViewCustomAnnotation = &MapViewCustomAnnotation;

@implementation FastGui (MapKit)

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
    [self mapViewPolylineWithReuseId:[FGInternal callerPositionAsReuseId] polyline:polyline styleClass:styleClass];
}

+ (void)mapViewPolylineWithReuseId:(NSString *) reuseId polyline:(MKPolyline *)polyline styleClass:(NSString *)styleClass
{
    MKPolylineRenderer * renderer = [self mapViewCustomOverlayWithBlock:^id<MKOverlay>(id<MKOverlay> reuseOverlay) {
        return polyline;
    } withReuseId:reuseId withRenderer:^MKOverlayRenderer *(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer) {
        MKPolylineRenderer *renderer = (MKPolylineRenderer*)reuseRenderer;
        if (renderer.polyline != overlay) {
            renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        }
        return renderer;
    } resultBlock:^id(id<MKOverlay> overlay, MKOverlayRenderer *renderer) {
        return renderer;
    }];
    FakeViewForStylable *fake = [[FakeViewForStylable alloc] initWithTarget:renderer];
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        return fake;
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

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image
{
    [self mapViewTextCalloutPinWithReuseId:[FGInternal callerPositionAsReuseId] location:location calloutText:calloutText subtitle:subtitle withPinImage:image];
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
    } withReuseId:reuseId withView:^MKAnnotationView *(id<MKAnnotation> annotation, MKAnnotationView *reuseView) {
        if (reuseView.annotation != annotation || (image != nil && [reuseView isKindOfClass:[MKPinAnnotationView class]]) || (image == nil && ![reuseView isKindOfClass:[MKPinAnnotationView class]])) {
            reuseView = [image == nil ? [MKPinAnnotationView alloc] : [MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        }
        if (image != nil) {
            reuseView.image = image;
        }
        reuseView.canShowCallout = calloutText != nil || subtitle != nil;
        return reuseView;
    } resultBlock:nil];
}

+ (BOOL)mapViewClickableCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle:(NSString *)subtitle withPinImage:(UIImage *)image buttonImage:(UIImage *)buttonImage
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    NSNumber * ret = [self mapViewCustomAnnotationWithBlock:^id<MKAnnotation>(id<MKAnnotation> reuseAnnotation) {
        MKPointAnnotation *anno = (MKPointAnnotation *) reuseAnnotation;
        if (anno == nil) {
            anno = [[MKPointAnnotation alloc] init];
        }
        anno.coordinate = location;
        anno.title = calloutText;
        anno.subtitle = subtitle;
        return anno;
    } withReuseId:reuseId withView:^MKAnnotationView *(id<MKAnnotation> annotation, MKAnnotationView *reuseView) {
        if (reuseView.annotation != annotation || (image != nil && [reuseView isKindOfClass:[MKPinAnnotationView class]]) || (image == nil && ![reuseView isKindOfClass:[MKPinAnnotationView class]])) {
            reuseView = [image == nil ? [MKPinAnnotationView alloc] : [MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        }
        if (image != nil) {
            reuseView.image = image;
        }
        reuseView.canShowCallout = calloutText != nil || subtitle != nil;
        UIButton *btn = (UIButton *) reuseView.rightCalloutAccessoryView;
        if (btn == nil) {
            btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            reuseView.rightCalloutAccessoryView = btn;
        }
        [btn setImage:buttonImage forState:UIControlStateNormal];
        return reuseView;
    } resultBlock:^id(id<MKAnnotation> annotation, MKAnnotationView *view) {
        return view.changingResult;
    }];
    return [ret boolValue];
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
    UIView *view = initBlock(nil);
    if ([view conformsToProtocol:@protocol(FGStylable)]) {
        applyStyleBlock(view);
    }
    return nil;
}

- (id) customOverlayWithBlock:(id<MKOverlay>(^)(id<MKOverlay> reuseOverlay)) initOverlay withReuseId:(NSString *)reuseId withRenderer: (MKOverlayRenderer *(^)(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer)) initRender resultBlock:(id (^)(id<MKOverlay>, MKOverlayRenderer *))resultBlock
{
    BOOL isNew;
    OverlayWithRenderer *ov = [self.mapView.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
        OverlayWithRenderer * ov = (OverlayWithRenderer *) reuseItem;
        if (ov == nil) {
            id<MKOverlay> overlay = initOverlay(nil);
            MKOverlayRenderer * renderer = initRender(overlay, nil);
            ov = [[OverlayWithRenderer alloc] init];
            ov.overlay = overlay;
            ov.renderer = renderer;
        }else{
            id<MKOverlay> overlay = initOverlay(ov.overlay);
            MKOverlayRenderer *r = initRender(overlay, ov.renderer);
            if (overlay != ov.overlay) {
                ov = [[OverlayWithRenderer alloc] init];
                ov.overlay = overlay;
            }
            ov.renderer = r;
        }
        return ov;
    } outputIsNewView: &isNew];
    if (isNew) {
        [self.mapView addOverlay:ov.overlay];
    }else{
        NSUInteger index = [self.mapView.overlays indexOfObject:ov.overlay];
        while (index != self.mapView.overlays.count - 1) {
            [self.mapView exchangeOverlayAtIndex:index withOverlayAtIndex:index+1];
            index ++;
        }
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
            if (annotation != av.annotation) {
                av = [[AnnotationWithView alloc] init];
                av.annotation = annotation;
            }
            av.view = view;
        }
        return av;
    } outputIsNewView: &isNew];
    if (isNew) {
        [self.mapView addAnnotation:av.annotation];
    }else{
        [self.mapView bringSubviewToFront:av.view];
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
        self.limitRegion = MKMapRectNull;
        self.limitRegionMaxZoom = 1;
        self.limitRegionMinZoom = 1;
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [view reloadGuiChangingResult:[NSNumber numberWithBool:YES]];
}

//-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
//{
//    if (MKCoordinateRegionEquals(self.limitRegion, MKCoordinateRegionZero)) {
//        return;
//    }
//    MKCoordinateRegion region = self.region;
//    if (isnan(region.center.latitude) && isnan(region.center.longitude) && !region.span.latitudeDelta > 0 && !region.span.longitudeDelta > 0) {
//        return;
//    }
//    MKCoordinateRegion desireRegion = region;
//    double aspectRatio = region.span.longitudeDelta / region.span.latitudeDelta;
//    double zoomX = self.limitRegion.span.longitudeDelta / region.span.longitudeDelta;
//    double zoomY = self.limitRegion.span.latitudeDelta / region.span.latitudeDelta;
//    double zoom = MAX(zoomX, zoomY);
//    double desireZoom = zoom;
//    if (desireZoom < self.limitRegionMinZoom) {
//        desireZoom = self.limitRegionMinZoom;
//    }else if (desireZoom > self.limitRegionMaxZoom) {
//        desireZoom = self.limitRegionMaxZoom;
//    }
//    desireRegion.span.longitudeDelta *= zoom / desireZoom;
//    desireRegion.span.latitudeDelta *= zoom / desireZoom;
//    
//    DLog(@"%f, %f", zoom, desireZoom);
//    
//    if (!MKCoordinateRegionEquals(region, desireRegion)) {
//        [self setRegion:desireRegion animated:NO];
//    }
//}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (MKMapRectIsNull(self.limitRegion) || MKMapRectIsEmpty(self.limitRegion)) {
        return;
    }
    if (MKMapRectIsNull(self.visibleMapRect) || MKMapRectIsEmpty(self.visibleMapRect)) {
        return;
    }
    // prevents possible infinite recursion when we call setVisibleMapRect below
    if (self.manuallyChangingMapRect) {
        return;
    }
    
    MKMapRect desireRegion = mapView.visibleMapRect;
    
    double widthZoom = self.limitRegion.size.width / mapView.visibleMapRect.size.width;
    double heightZoom = self.limitRegion.size.height / mapView.visibleMapRect.size.height;
    // adjust ratios as needed
    double zoom = MAX(widthZoom, heightZoom);
    
    double desireZoom = zoom;
    BOOL anyChange = false;
    if (desireZoom < self.limitRegionMinZoom) {
        desireZoom = self.limitRegionMinZoom;
        anyChange = true;
    }else if (desireZoom > self.limitRegionMaxZoom) {
        desireZoom = self.limitRegionMaxZoom;
        anyChange = true;
    }
    double widthDelta = desireRegion.size.width * ((zoom / desireZoom) - 1);
    double heightDelta = desireRegion.size.height * ((zoom / desireZoom) - 1);
    desireRegion.size.width *= zoom / desireZoom;
    desireRegion.size.height *= zoom / desireZoom;
    desireRegion.origin.x -= widthDelta / 2;
    desireRegion.origin.y -= heightDelta / 2;
    
    if (widthZoom > 1) {
        if (desireRegion.origin.x < self.limitRegion.origin.x) {
            desireRegion.origin.x = self.limitRegion.origin.x;
            anyChange = true;
        }else if(desireRegion.origin.x + desireRegion.size.width > self.limitRegion.origin.x + self.limitRegion.size.width){
            desireRegion.origin.x = self.limitRegion.origin.x + self.limitRegion.size.width - desireRegion.size.width;
            anyChange = true;
        }
    }else{
        if (desireRegion.origin.x > self.limitRegion.origin.x) {
            desireRegion.origin.x = self.limitRegion.origin.x;
        }else if(desireRegion.origin.x + desireRegion.size.width < self.limitRegion.origin.x + self.limitRegion.size.width){
            desireRegion.origin.x = self.limitRegion.origin.x + self.limitRegion.size.width - desireRegion.size.width;
        }
    }
    
    if (heightZoom > 1) {
        if (desireRegion.origin.y < self.limitRegion.origin.y) {
            desireRegion.origin.y = self.limitRegion.origin.y;
            anyChange = true;
        }else if(desireRegion.origin.y + desireRegion.size.height > self.limitRegion.origin.y + self.limitRegion.size.height){
            desireRegion.origin.y = self.limitRegion.origin.y + self.limitRegion.size.height - desireRegion.size.height;
            anyChange = true;
        }
    }else{
        if (desireRegion.origin.y > self.limitRegion.origin.y) {
            desireRegion.origin.y = self.limitRegion.origin.y;
            anyChange = true;
        }else if(desireRegion.origin.y + desireRegion.size.height < self.limitRegion.origin.y + self.limitRegion.size.height){
            desireRegion.origin.y = self.limitRegion.origin.y + self.limitRegion.size.height - desireRegion.size.height;
            anyChange = true;
        }
    }
    
    
    if (anyChange) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.manuallyChangingMapRect = YES;
            [mapView setVisibleMapRect:desireRegion animated:YES];
                    self.manuallyChangingMapRect = NO;
        } completion:nil];

    }
    
    
//    BOOL mapContainsOverlay = MKMapRectContainsRect(mapView.visibleMapRect, self.limitRegion);
//    
//    
//    if (mapContainsOverlay) {
//        // The overlay is entirely inside the map view but adjust if user is zoomed out too much...
//        double widthZoom = self.limitRegion.size.width / mapView.visibleMapRect.size.width;
//        double heightZoom = self.limitRegion.size.height / mapView.visibleMapRect.size.height;
//        // adjust ratios as needed
//        double zoom = MAX(widthZoom, heightZoom);
//        if (zoom < self.limitRegionMinZoom) {
//            self.manuallyChangingMapRect = YES;
//            [mapView setVisibleMapRect:self.limitRegion animated:YES];
//            self.manuallyChangingMapRect = NO;
//        }
//    } else if (!MKMapRectIntersectsRect(mapView.visibleMapRect, self.limitRegion)) {
//        // Overlay is no longer visible in the map view.
//        // Reset to last "good" map rect...
//        self.manuallyChangingMapRect = YES;
//        [mapView setVisibleMapRect:self.lastGoodMapRect animated:YES];
//        self.manuallyChangingMapRect = NO;
//    } else {
//        self.lastGoodMapRect = mapView.visibleMapRect;
//    }
}

- (void)endUpdateStyle
{
    self.manuallyChangingMapRect = YES;
    [super endUpdateStyle];
    self.manuallyChangingMapRect = NO;
}

@end

@implementation FakeViewForStylable

@synthesize target = _target;

- (instancetype)initWithTarget:(id<FGStylable>)target
{
    self = [super init];
    if (self) {
        _target = target;
    }
    return self;
}

- (void) styleWithBorder:(UIColor *)color width:(CGFloat)borderWidth
{
    [self.target styleWithBorder:color width:borderWidth];
}

- (void) styleWithBorderColor:(UIColor *)borderColor
{
    [self.target styleWithBorderColor:borderColor];
}

- (void) styleWithBorderWidth:(CGFloat)borderWidth
{
    [self.target styleWithBorderWidth:borderWidth];
}

- (void) styleWithColor:(UIColor *)color
{
    [self.target styleWithColor:color];
}

@end

@implementation MKPolylineRenderer (FGStylable)

- (void)styleWithBorder:(UIColor *)color width:(CGFloat)borderWidth
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

@implementation FGStyle (MapKit)

+ (void)mapViewLimitRegion:(MKCoordinateRegion)region minZoom:(double)minZoom maxZoom:(double)maxZoom
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[FGMapView class]]) {
            FGMapView * map = (FGMapView *) view;
            MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                              region.center.latitude + region.span.latitudeDelta / 2,
                                                                              region.center.longitude - region.span.longitudeDelta / 2));
            MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                              region.center.latitude - region.span.latitudeDelta / 2,
                                                                              region.center.longitude + region.span.longitudeDelta / 2));
            map.limitRegion =  MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
            map.limitRegionMaxZoom = maxZoom;
            map.limitRegionMinZoom = minZoom;
        }
    }];
}

@end