//
//  FastGui+MapKit.h
//  exibitour
//
//  Created by 易元 白 on 15/6/8.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui.h"
#import <MapKit/MapKit.h>

#define MKCoordinateRegionEquals(a,b) ((a).center.latitude == (b).center.latitude && a.center.longitude == (b).center.longitude && (a).span.latitudeDelta == (b).span.latitudeDelta && a.span.longitudeDelta == (b).span.longitudeDelta)

extern const MKCoordinateRegion MKCoordinateRegionZero;

@interface FastGui (MapKit)

+ (MKCoordinateRegion)beginMapView;

+ (MKCoordinateRegion)beginMapViewWithStyleClass: (NSString *) styleClass;

+ (MKCoordinateRegion)beginMapViewWithRegion: (MKCoordinateRegion) region;

+ (MKCoordinateRegion)beginMapViewWithRegion:(MKCoordinateRegion)region styleClass: (NSString *) styleClass;

+ (void)mapViewSetRegion: (MKCoordinateRegion) region;

+ (void)mapViewPolyline: (MKPolyline *) polyline;

+ (void)mapViewPolyline:(MKPolyline *)polyline styleClass: (NSString *) styleClass;

+ (BOOL) mapViewClickableCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image buttonImage: (UIImage *) buttonImage;

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image;

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle;

+ (void)mapViewTileOverlayWithUrlTemplate: (NSString *) template;

+ (id) mapViewCustomOverlayWithBlock:(id<MKOverlay>(^)(id<MKOverlay> reuseOverlay)) initOverlay withReuseId:(NSString *)reuseId withRenderer: (MKOverlayRenderer *(^)(id<MKOverlay> overlay, MKOverlayRenderer *reuseRenderer)) initRender resultBlock: (id(^)(id<MKOverlay> overlay, MKOverlayRenderer* renderer)) resultBlock;

+ (id) mapViewCustomAnnotationWithBlock: (id<MKAnnotation>(^)(id<MKAnnotation> reuseAnnotation))initAnnotation withReuseId:(NSString *)reuseId withView: (MKAnnotationView *(^)(id<MKAnnotation> annotation, MKAnnotationView *reuseView)) initView resultBlock: (id(^)(id<MKAnnotation> annotation, MKAnnotationView * view)) resultBlock;

+ (void)endMapView;

@end

@interface FGStyle (MapKit)

+ (void) mapViewLimitRegion: (MKCoordinateRegion) region minZoom: (double) minZoom maxZoom: (double) maxZoom;

@end

