//
//  FastGui+MapKit.h
//  exibitour
//
//  Created by 易元 白 on 15/6/8.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui.h"
#import <MapKit/MapKit.h>

#define MKCoordinateRegionZero {{0, 0}, {0, 0}}

@interface FastGui (BMKMapView)

+ (MKCoordinateRegion)beginMapView;

+ (MKCoordinateRegion)beginMapViewWithStyleClass: (NSString *) styleClass;

+ (MKCoordinateRegion)beginMapViewWithRegion: (MKCoordinateRegion) region;

+ (MKCoordinateRegion)beginMapViewWithRegion:(MKCoordinateRegion)region styleClass: (NSString *) styleClass;

+ (void)mapViewSetRegion: (MKCoordinateRegion) region;

+ (void)mapViewPolyline: (MKPolyline *) polyline;

+ (void)mapViewPolyline:(MKPolyline *)polyline styleClass: (NSString *) styleClass;

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle: (NSString *) subtitle;

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle:(NSString *)subtitle withPinImageName:(NSString *)imageName;

+ (void)mapViewTextCalloutPinWithLocation:(CLLocationCoordinate2D)location calloutText:(NSString *)calloutText subtitle:(NSString *)subtitle withPinImage:(UIImage *)image;

+ (void)endMapView;

@end

