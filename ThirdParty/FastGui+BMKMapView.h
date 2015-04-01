//
//  FastGui+BMKMapView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui.h"
#import <Baidu-Maps-iOS-SDK/BMapKit.h>

#define BMKCoordinateRegionZero {{0, 0}, {0, 0}}

@interface FastGui (BMKMapView)

+ (BMKCoordinateRegion) beginBaiduMapView;

+ (BMKCoordinateRegion) beginBaiduMapViewWithStyleClass: (NSString *) styleClass;

+ (BMKCoordinateRegion) beginBaiduMapViewWithRegion: (BMKCoordinateRegion) region;

+ (BMKCoordinateRegion) beginBaiduMapViewWithRegion: (BMKCoordinateRegion) region styleClass: (NSString *) styleClass;

+ (void) baiduMapViewSetRegion: (BMKCoordinateRegion) region;

+ (void) baiduMapViewPolyline: (BMKPolyline *) polyline;

+ (void) baiduMapViewPolyline: (BMKPolyline *) polyline styleClass: (NSString *) styleClass;

+ (void) baiduMapViewTextCalloutPinWithLocation: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle;

+ (void) baiduMapViewTextCalloutPinWithLocation: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImageName:(NSString *)imageName;

+ (void) baiduMapViewTextCalloutPinWithLocation: (CLLocationCoordinate2D) location calloutText: (NSString *)calloutText subtitle: (NSString *) subtitle withPinImage:(UIImage *)image;

+ (void) beginBaiduMapViewCalloutPinWithLocation: (CLLocationCoordinate2D) location;

+ (void) beginBaiduMapViewCalloutPinWithLocation: (CLLocationCoordinate2D) location withImageName:(NSString *)imageName;

+ (void) beginBaiduMapViewCalloutPinWithLocation: (CLLocationCoordinate2D) location styleClass: (NSString *) styleClass;

+ (void) beginBaiduMapViewCalloutPinWithLocation: (CLLocationCoordinate2D) location withImageName:(NSString *)imageName styleClass: (NSString *) styleClass;

+ (void) endBaiduMapViewCalloutPin;

+ (void) endBaiduMapView;

@end
