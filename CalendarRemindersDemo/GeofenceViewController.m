//
//  GeofenceViewController.m
//  CalendarRemindersDemo
//
//  Created by xcz on 16/7/28.
//  Copyright © 2016年 Pearl-Z. All rights reserved.
//
//  无法定位？ 试试 info.plist里面添加 NSLocationAlwaysUsageDescription

#import "GeofenceViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>

// 地球坐标转火星坐标
//--------------------------坐标转换开始-----------------------
static const double pi = 3.14159265358979324;
static const double a = 6378245.0;
static const double ee = 0.00669342162296594323;

static bool outOfChina(double lat, double lon);
static double transformLat(double x, double y);
static double transformLon(double x, double y);

// World Geodetic System ==> Mars Geodetic System
static CLLocationCoordinate2D transformFromWGSCoord2MarsCoord(CLLocationCoordinate2D wgsCoordinate)
{
    double wgLat = wgsCoordinate.latitude;
    double wgLon = wgsCoordinate.longitude;
    
    if (outOfChina(wgLat, wgLon))
    {
        return wgsCoordinate;
    }
    
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    
    CLLocationCoordinate2D marsCoordinate = {wgLat + dLat, wgLon + dLon};
    return marsCoordinate;
}

bool outOfChina(double lat, double lon)
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}
//--------------------------坐标转换结束-----------------------




@interface GeofenceViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property(nonatomic,strong) MKMapView *mapView;

@property(nonatomic,strong) CLLocationManager *mgr;

@property(nonatomic,strong) EKEventStore *eventStore;

@property(nonatomic,strong) CLLocation *userLocation;

@end

@implementation GeofenceViewController

- (EKEventStore *)eventStore{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (CLLocationManager *)mgr{
    if (!_mgr) {
        _mgr = [[CLLocationManager alloc] init];
        _mgr.delegate = self;
    }
    return _mgr;
}

- (MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
        _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        _mapView.showsScale = YES;
        [self.view addSubview:_mapView];
    }
    return _mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"地理围栏测试";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 请求地理位置权限
    if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
        [self.mgr requestAlwaysAuthorization];
    }else{
        [self.mgr startUpdatingLocation];
    }
    self.mapView.delegate = self;
    
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame)+10, [UIScreen mainScreen].bounds.size.width, 50)];
    [addBtn setTitle:@"添加地理围栏提醒事项" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    
}


#pragma mark - 添加地理围栏提醒事项事件
// 对于提醒事项权限获取错误处理
- (BOOL)handleError:(NSError *)error granted:(BOOL)granted{
    if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求出错" message:error.description preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    if (!granted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

// 按钮点击，添加地理围栏提醒事项事件
- (void)addBtnClick {
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        if ([self handleError:error granted:granted]) {
            // 切回主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_userLocation) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"还未能获取地理位置" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return ;
                }
                
                // 视图定位到当前位置
                // 这里在高德地图上显示需要将获取的地球坐标转化为火星坐标(即中国专用坐标),否则会出现偏移
                CLLocationCoordinate2D center = transformFromWGSCoord2MarsCoord(self.userLocation.coordinate);
                MKCoordinateSpan span = MKCoordinateSpanMake(0.003,0.003);
                MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
                [self.mapView setRegion:region animated:YES];
                
                // 地图上画圆圈
                MKCircle * cirle = [MKCircle circleWithCenterCoordinate:transformFromWGSCoord2MarsCoord(self.userLocation.coordinate) radius:100];
                [self.mapView addOverlay:cirle];
                
                //创建一个提醒功能
                EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
                reminder.title = @"Pearl-Z : 离开地理围栏";
                [reminder setCalendar:[self.eventStore defaultCalendarForNewReminders]];
                EKAlarm *alarm = [EKAlarm new]; //添加一个闹钟
                EKStructuredLocation *geo = [EKStructuredLocation locationWithTitle:@"当前位置为中心，100米半径"];
                geo.geoLocation = [[CLLocation alloc] initWithLatitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude];
                geo.radius = 100;
                alarm.structuredLocation = geo;
                alarm.proximity = EKAlarmProximityLeave;
                [reminder addAlarm:alarm];
                
                // 显示创建结果
                NSError *err;
                BOOL result = [self.eventStore saveReminder:reminder commit:YES error:&err];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@创建结果",reminder.title] message:[NSString stringWithFormat:@"result:%@\nerror:%@",result?@"成功":@"失败",err] preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                
            });
            
        }
    }];
}




#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    // 当用户授权定位后，开始定位
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [_mgr startUpdatingLocation];
    }
}

// 获取当前点地球坐标
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.userLocation = locations.lastObject;
}


#pragma mark - MKMapView delegate
// 绘制路线时就会调用(添加遮盖时就会调用)
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circle = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    circle.lineWidth = 2;
    circle.fillColor = [UIColor colorWithRed:255/255.0 green:82/255.0 blue:85/255.0 alpha:0.3];
    circle.strokeColor = [UIColor colorWithRed:255/255.0 green:82/255.0 blue:85/255.0 alpha:1.0];
    return circle;
}


@end
