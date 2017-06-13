//
//  FirstViewController.m
//  MapTest
//
//  Created by Nancy Fan on 2017/5/30.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()


@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKGeoCodeSearch *searcher;
@property (strong, nonatomic) BMKLocationService *locService;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property BOOL isFirstInit;

@property (weak, nonatomic) IBOutlet UIButton *searchNearbyButton;
@property (weak, nonatomic) IBOutlet UILabel *centerLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalResultsLabel;

@property (weak, nonatomic) IBOutlet UIButton *locateButton;

@end

@implementation FirstViewController


-(IBAction)clickSearchButton:(id)sender{
    [self searchNearbyAQI:_mapView.centerCoordinate];
}

-(IBAction)clickLocateButton:(id)sender{
    [_mapView setCenterCoordinate:_locService.userLocation.location.coordinate];
}

- (void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locService.delegate = self;
    _searcher.delegate = self;
    [_locService startUserLocationService];
    
    _isFirstInit = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    [_locService stopUserLocationService];
    _mapView.delegate = nil;
    _locService.delegate = nil;
    _searcher.delegate = nil;
    
    _isFirstInit = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    [_mapView setZoomLevel:16];
    [_mapView setShowsUserLocation:YES];
    [_mapView setShowMapScaleBar:YES];
    [_mapView setZoomEnabled:YES];
    [self.view insertSubview:_mapView atIndex:0];
    
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    
    _isFirstInit = YES;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    MyAnnotationView *newAnnotationView = (MyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotation"];
    if (newAnnotationView == nil) {
        newAnnotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
    }
    return newAnnotationView;
}

-(void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocationCoordinate2D pt = self.mapView.centerCoordinate;
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(!flag){
        NSLog(@"反geo检索发送失败");
    }
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        if (result.poiList.count > 0){
            BMKPoiInfo *poiInfo = [result.poiList objectAtIndex:0];
            [_centerLocationLabel setText:poiInfo.name];
        } else {
            [_centerLocationLabel setText:[NSString stringWithFormat:@"%@%@",result.addressDetail.streetName,result.addressDetail.streetNumber]];
        }
    } else {
        NSLog(@"抱歉，未找到结果"); 
    }
}

- (void) searchNearbyAQI:(CLLocationCoordinate2D) coor {
    NSLog(@"do search %lf,%lf", coor.longitude, coor.latitude);
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeOverlays:_mapView.overlays];

    /*
     * ak: 秘钥
     * geotable_id: table id
     * location: lo,la
     * radius: **(m)
     * ...
     */
//    CLLocationCoordinate2D coorLL = CLLocationCoordinate2DMake(_mapView.centerCoordinate.latitude - 0.5*_mapView.region.span.latitudeDelta,
//                                                               _mapView.centerCoordinate.longitude - 0.5 * _mapView.region.span.longitudeDelta);
//    CLLocationCoordinate2D coorRT = CLLocationCoordinate2DMake(_mapView.centerCoordinate.latitude + 0.5*_mapView.region.span.latitudeDelta,
//                                                              _mapView.centerCoordinate.longitude + 0.5 * _mapView.region.span.longitudeDelta);

    NSString *cloudUrl = @"http://api.map.baidu.com/geosearch/v3/nearby";//bound
    NSDictionary *dict = @{@"ak": @"cVUa65NTCXGRxTyIAIW9nk13V7ORBwzh",
                           @"geotable_id":@"169360",
                           @"mcode":@"project.Lab.BlueBell",
                           //@"bounds":@"116.400924,39.891727;116.424343,39.923749",
                           //@"bounds":[NSString stringWithFormat:@"%lf,%lf;%lf,%lf", coorLL.longitude, coorLL.latitude, coorRT.longitude, coorRT.latitude],
                           @"radius":@"5000",
                           @"location": [NSString stringWithFormat:@"%lf,%lf", coor.longitude, coor.latitude],
                           //@"sortby":@"date:-1",
                           };
    NSLog(@"%@", dict);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:cloudUrl parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSHTTPURLResponse *reponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Get请求成功：Header:%@", [reponse allHeaderFields]);
        NSLog(@"Get请求成功：JSON: %@", responseObject);
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        NSString *totalCnt = [[NSString alloc]initWithFormat:@"%@", [jsonDict objectForKey:@"total"]];
        NSLog(@"%@", totalCnt);
        [_totalResultsLabel setText:[totalCnt stringByAppendingFormat:@" %@", @"results found nearby"]];
        
        NSArray *contents = [jsonDict objectForKey:@"contents"];
        [contents enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
            NSString *title = [obj objectForKey:@"title"];
            NSArray *location = [obj objectForKey:@"location"];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location[1] floatValue],[location[0] floatValue] );
            NSString *date = [obj objectForKey:@"date"];
            NSString *aqiLevel = [obj objectForKey:@"aqi"];
            NSString *image_url = [obj objectForKey:@"image_url"];
            NSString *info = [title stringByAppendingFormat:@", %@, %@, %@", date, aqiLevel, image_url];
            NSLog(@"Annotation info: %@", info);
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc] init];
            item.coordinate = coordinate;
            item.title = info;
            [_mapView addAnnotation:item];
        }];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Get请求失败：Error: %@", error);
    }];
}


- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [_mapView setShowsUserLocation:YES];
    [_mapView updateLocationData:userLocation];
    
    if(_isFirstInit == YES){
        [_mapView setCenterCoordinate:userLocation.location.coordinate];
        [self searchNearbyAQI:userLocation.location.coordinate];
        _isFirstInit = NO;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
