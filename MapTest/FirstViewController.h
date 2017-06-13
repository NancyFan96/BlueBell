//
//  FirstViewController.h
//  MapTest
//
//  Created by Nancy Fan on 2017/5/30.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

#import <AFNetworkReachabilityManager.h>
#import <AFNetworking.h>

#import "MyAnnotationView.h"


@interface FirstViewController : UIViewController<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate>




@end

