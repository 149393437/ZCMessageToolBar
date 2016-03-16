//  Created by zhangcheng on 16/3/14.
//  Copyright © 2016年 zhangcheng. All rights reserved.
//     _                            _
// ___| |__   __ _ _ __   __ _  ___| |__   ___ _ __   __ _
//|_  / '_ \ / _` | '_ \ / _` |/ __| '_ \ / _ \ '_ \ / _` |
// / /| | | | (_| | | | | (_| | (__| | | |  __/ | | | (_| |
///___|_| |_|\__,_|_| |_|\__, |\___|_| |_|\___|_| |_|\__, |
//                       |___/                       |___/

//小张诚技术博客http://blog.sina.com.cn/u/2914098025
//github代码地址https://github.com/149393437
//欢迎加入iOS研究院 QQ群号305044955    你的关注就是我开源的动力

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationViewController.h"
static LocationViewController *defaultLocation = nil;

@interface LocationViewController () <MKMapViewDelegate,CLLocationManagerDelegate>
{
    MKMapView *_mapView;
    MKPointAnnotation *_annotation;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocationCoordinate;
    BOOL _isSendLocation;
    UIButton *sendButton;
}

@property (strong, nonatomic) NSString *addressString;

@end

@implementation LocationViewController

@synthesize addressString = _addressString;
-(instancetype)initWithBlock:(void(^)(NSString*locationStr))a;
{
    if (self=[super init]) {
        self.myBlock=a;
        _isSendLocation=YES;
    }
    return self;
}
- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.showsUserLocation=YES;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    if (_isSendLocation) {
        _mapView.showsUserLocation = YES;//显示当前位置
        
        sendButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, 20, 60, 44)];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithRed:32 / 255.0 green:134 / 255.0 blue:158 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [sendButton addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sendButton];
    
        [self startLocation];
    }
    else{
        [self removeToLocation:_currentLocationCoordinate];
    }
}
-(void)backClick{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - MKMapViewDelegate




- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
        {
            
        }
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation*location=[locations lastObject];
    
    //定位后移动到指定位置
    [_mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1))];
    
    NSString*str=[NSString stringWithFormat:@"%lf,%lf",location.coordinate.latitude,location.coordinate.longitude];
   
    _locationStr=str;
    sendButton.enabled=YES;
    [manager stopUpdatingLocation];

    
}
#pragma mark - public

- (void)startLocation
{
    if([CLLocationManager locationServicesEnabled]){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        [_locationManager startUpdatingLocation];
    }
    
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
    if (_annotation == nil) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else{
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    [_mapView addAnnotation:_annotation];
}

- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    
    _currentLocationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        
        sendButton.enabled=YES;
        
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

- (void)sendLocation
{
    if (_locationStr) {
        self.myBlock(_locationStr);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
