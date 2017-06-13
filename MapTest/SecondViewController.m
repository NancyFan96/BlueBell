//
//  SecondViewController.m
//  MapTest
//
//  Created by Nancy Fan on 2017/5/30.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *addImageView;

@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UITextField *recordedTimeText;
@property (weak, nonatomic) IBOutlet UITextField *recordedLocationText;



@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *repickButton;
@property (weak, nonatomic) IBOutlet UILabel *aqiScoreLabel;

@property CLLocationCoordinate2D newCoordination;

@property NSString *address;
@property NSString *time;
@property NSString *aqi;
@property NSString *url;

@property BOOL isFirst;
@property BOOL haveAlert;
@property BOOL haveEdit;
@property BOOL success;
//@property BOOL haveAQI;
//@property NSString *imageNamehasAQI;


@property (strong, nonatomic) BMKGeoCodeSearch *getCodeSearch;
@property (strong, nonatomic) BMKLocationService *locationService;

@property NSOperationQueue *opsQueue;
@property NSBlockOperation *getAnalyseBlockOp;
@property NSBlockOperation *getNewCoorBlockOp;

@property dispatch_queue_t queue;
@property dispatch_semaphore_t sem;

@end

@implementation SecondViewController


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"get image");
    [_addImageView setImage:self.image];
    
    NSDictionary *metadataDictionary = (NSDictionary *)[info valueForKey:UIImagePickerControllerMediaMetadata];
    NSLog(@"meta : %@ \n\n",metadataDictionary);
    
//    NSURL *mediaUrl = info[UIImagePickerControllerReferenceURL];
//    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//    
//    [assetsLibrary assetForURL:mediaUrl resultBlock:^(ALAsset *asset) {
//        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
//        // ...
//    } failureBlock:nil];
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    [_cameraButton setHidden:YES];
    [_libraryButton setHidden:YES];
    [_cancelButton setHidden:YES];
    [_addImageButton setHidden:YES];
    if (_addImageView.image != nil) {
        [_repickButton setHidden:NO];
        [_uploadButton setEnabled:YES];
        [_uploadButton setUserInteractionEnabled:YES];
    }

}

-(IBAction)clickAddImageButton:(id)sender{
    [_cameraButton setHidden:NO];
    [_libraryButton setHidden:NO];
    [_cancelButton setHidden:NO];
    [_addImageButton setHidden:YES];
}

-(IBAction)clickCancelWhenUpload:(id)sender {
    [_cameraButton setHidden:YES];
    [_libraryButton setHidden:YES];
    [_cancelButton setHidden:YES];
    if (_addImageView.image == nil){
        [_addImageButton setHidden:NO];
    }
    // [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)clickRepickButton:(id)sender{
    [_cameraButton setHidden:NO];
    [_libraryButton setHidden:NO];
    [_cancelButton setHidden:NO];
    [_addImageButton setHidden:YES];
}

- (IBAction)clickCameraButton:(id)sender {
    [self takePhoto];
}

- (IBAction)clickLibraryButton:(id)sender {
    [self choseLib];
    
}

- (void) storeToCloud {
    dispatch_async(_queue, ^{
        while(_haveEdit == YES){
            [NSThread sleepForTimeInterval:0.5];
        }
        while(_success == NO){
            [NSThread sleepForTimeInterval:0.5];
        }
        
        NSString *cloudUpUrl = @"http://api.map.baidu.com/geodata/v3/poi/create?";
        NSDictionary *dict = @{@"ak": @"dz6vsNrfoBweWxoOHN6NMG2RdYdGxDI7", //server 端
                               @"geotable_id":@"169360",
                               @"mcode":@"project.Lab.BlueBell",
                               @"coord_type":@"3",
                               @"aqi":_aqi,
                               @"title":_address,
                               @"date":_time,
                               @"latitude":[NSString stringWithFormat:@"%lf", _newCoordination.latitude],
                               @"longitude":[NSString stringWithFormat:@"%lf", _newCoordination.longitude],
                               @"image_url":_url
                               //@"image":_url
                               };
        NSLog(@"store to cloud. Dict: %@", dict);
        AFHTTPSessionManager *storeManager = [AFHTTPSessionManager manager];
        
        
        [storeManager POST:cloudUpUrl parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            //        NSHTTPURLResponse *reponse = (NSHTTPURLResponse *)task.response;
            //        NSLog(@"POST cloud Header:%@", [reponse allHeaderFields]);
            //        NSLog(@"POST cloud 请求成功：JSON: %@", responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"POST cloud 请求失败：Error: %@", error);
        }];
    });
   }

- (void)getAnalysis{
        _success = NO;
        [_aqiScoreLabel setText:@"Analyzing..."];
    
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *analyzeUrl = @"http://162.105.175.115:8004/bluebell/comments/upload";
        NSData *data = UIImageJPEGRepresentation(self.addImageView.image, 0.5);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpeg", str];
    
   
            [manager POST:analyzeUrl parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
                [formData appendPartWithFileData:data name:@"addImage" fileName:fileName mimeType:@"image/jpeg"];
            } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSHTTPURLResponse *reponse = (NSHTTPURLResponse *)task.response;
                NSLog(@"分析成功：Header:%@", [reponse allHeaderFields]);
                NSLog(@"分析成功 Json: %@", responseObject);
                _success = YES;
                NSDictionary *jsonDict = (NSDictionary *) responseObject;
                _aqi = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:@"aqi"]];
                _url = [@"http://162.105.175.115:8004/bluebell/getimage" stringByAppendingFormat:@"%@", [jsonDict objectForKey:@"image_url"]];
                [_aqiScoreLabel setText:_aqi];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"分析失败 %@", error);
                [_aqiScoreLabel setText:@"Fail :( Pls Retry UPLOAD"];
            }];
   

}

- (IBAction)clickUploadOkButton:(id)sender {
    // upload onto server
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self getAnalysis];
    
   
    _haveAlert = YES;
    if(_haveEdit){
        _time = _recordedTimeText.text;
        _address = _recordedLocationText.text;
        [self getCoordinatrion:_address];
    }
   
    [self storeToCloud];
    

}

- (void)getCoordinatrion:(NSString *)address{
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.city = @"北京市";
    geoCodeSearchOption.address = address;
    BOOL flag = [_getCodeSearch geoCode:geoCodeSearchOption];
    if(flag){
        _haveAlert = NO;
        NSLog(@"geo检索发送成功 %@", address);
    } else{
        NSLog(@"geo检索发送失败 %@", address);
    }
    
}


-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    if(_isFirst == YES){ // init as user loaction
        BMKReverseGeoCodeOption *reverseOption=[[BMKReverseGeoCodeOption alloc]init];
        reverseOption.reverseGeoPoint=userLocation.location.coordinate;
        BOOL flag = [_getCodeSearch reverseGeoCode:reverseOption];
        if(!flag){
            NSLog(@"反geo检索发送失败");
        }
        _isFirst = NO;
    }
}

-(void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
        if(error == BMK_SEARCH_NO_ERROR){
            _haveEdit = NO;
            _newCoordination = result.location;
            NSLog(@"GEO new Coordination %lf, %lf", _newCoordination.longitude, _newCoordination.latitude);
        }else{
            NSLog(@"GEO 检索失败");
            [_aqiScoreLabel setText:@"Fail :( Pls Do Not Use A Nick Address"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法确定记录地址" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:true completion:nil];
            
        }
    
}

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if(error == BMK_SEARCH_NO_ERROR){
        if (result.poiList.count > 0){
            BMKPoiInfo *poiInfo = [result.poiList objectAtIndex:0];
            [_recordedLocationText setText:poiInfo.name];
        } else {
            [_recordedLocationText setText:[NSString stringWithFormat:@"%@%@",result.addressDetail.streetName,result.addressDetail.streetNumber]];
        }
        _address = _recordedLocationText.text; // init as user loaction
        _newCoordination = _locationService.userLocation.location.coordinate;
        NSLog(@"系统当前位置为：%@",_address);
    }else{
        NSLog(@"反向GEO 无结果");
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (_addImageView.image != nil) {
        [_repickButton setHidden:NO];
    }
    _getCodeSearch = [[BMKGeoCodeSearch alloc]init];
    _locationService = [[BMKLocationService alloc]init];
    _address = [[NSString alloc] init];
    _time = [[NSString alloc]init];
    _aqi = [[NSString alloc]init];
    _url = [[NSString alloc]init];
    _recordedTimeText.delegate = self;
    _recordedLocationText.delegate = self;
    _newCoordination = _locationService.userLocation.location.coordinate; // init as user loaction
    
    _isFirst = YES;
    
    _queue = dispatch_queue_create("cloudup.queue", DISPATCH_QUEUE_SERIAL);

  
    [_uploadButton setEnabled:NO];
    [_uploadButton setUserInteractionEnabled:NO];

    // 获取系统当前时间
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [_recordedTimeText setText:[df stringFromDate:currentDate]]; // init as user loaction
    _time = _recordedTimeText.text;
    NSLog(@"系统当前时间为：%@",_time);
    
    
    // 网络监控句柄
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // -1,  未知 | 0,   未连接 | 1,   3G | 2,   无线连接
        NSLog(@"当前网络状态： %ld", (long)status);
    }];
}


-(void)viewWillAppear:(BOOL)animated
{
    [_locationService startUserLocationService];
    _locationService.delegate=self;
    _getCodeSearch.delegate = self;
    _isFirst = YES;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [_locationService stopUserLocationService];
    _locationService.delegate=nil;
    _getCodeSearch.delegate = nil;
    
}


-(void) textFieldDidBeginEditing:(UITextField *)textField{
    _haveEdit = YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [_recordedLocationText resignFirstResponder];
    [_recordedTimeText resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
