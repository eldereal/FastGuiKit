//
//  FastGui+BMKMapView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui.h"
#import <Baidu-Maps-iOS-SDK/BMapKit.h>

extern const BMKCoordinateRegion BMKCoordinateRegionZero;

@interface FastGui (BMKMapView)

+ (BMKCoordinateRegion) beginBaiduMapView;

+ (BMKCoordinateRegion) beginBaiduMapViewWithStyleClass: (NSString *) styleClass;

+ (BMKCoordinateRegion) beginBaiduMapViewWithRegion: (BMKCoordinateRegion) region;

+ (BMKCoordinateRegion) beginBaiduMapViewWithRegion: (BMKCoordinateRegion) region styleClass: (NSString *) styleClass;

+ (void) endBaiduMapView;

@end
