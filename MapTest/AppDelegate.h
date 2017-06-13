//
//  AppDelegate.h
//  MapTest
//
//  Created by Nancy Fan on 2017/5/30.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) BMKMapManager *mapManager;


@end

