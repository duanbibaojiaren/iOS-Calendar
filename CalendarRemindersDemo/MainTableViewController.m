//
//  MainTableViewController.m
//  CalendarRemindersDemo
//
//  Created by xcz on 16/7/28.
//  Copyright © 2016年 Pearl-Z. All rights reserved.
//
//
// 系统UI界面语音为英文？ 试试 info.plist里面添加Localized resources can be mixed YES

#import "MainTableViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "GeofenceViewController.h"
#import "CalendarViewController.h"

@interface MainTableViewController ()<EKEventEditViewDelegate, EKEventViewDelegate>

//@property(nonatomic,strong) EKEventStore *eventStore;

@end

@implementation MainTableViewController

//- (EKEventStore *)eventStore{
//    if (!_eventStore) {
//        _eventStore = [[EKEventStore alloc] init];
////        [[NSNotificationCenter defaultCenter] addObserver:self
////                                                 selector:@selector(storeChanged:)
////                                                     name:EKEventStoreChangedNotification
////                                                   object:_eventStore];
//    }
//    return _eventStore;
//}

#pragma mark - 监听通知
- (void)storeChanged:(id)notic{
    NSLog(@"storeChanged:----------%@",notic);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"日历事件和提醒事项";
    
}


#pragma mark - 功能演示

// 处理错误信息
- (BOOL)handleError:(NSError *)error granted:(BOOL)granted{
    if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求权限出错" message:error.description preferredStyle:UIAlertControllerStyleAlert];
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

// 获取一年内的事件
//- (void)getEvents {
//    // 请求日历操作的权限
//    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//        // 授权成功
//        if ([self handleError:error granted:granted]) {
//            // 获取适当的日期（Get the appropriate calendar）x
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            
//            // 创建起始日期组件（Create the start date components）
//            NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
//            oneDayAgoComponents.day = -1;
//            NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
//                                                          toDate:[NSDate date]
//                                                         options:0];
//            
//            // 创建结束日期组件（Create the end date components）
//            NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
//            oneYearFromNowComponents.year = 1;
//            NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
//                                                               toDate:[NSDate date]
//                                                              options:0];
//            
//            // 用事件库的实例方法创建谓词 (Create the predicate from the event store's instance method)
//            NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:oneDayAgo
//                                                                              endDate:oneYearFromNow
//                                                                            calendars:nil];
//            
//            // 获取所有匹配该谓词的事件(Fetch all events that match the predicate)
//            NSString *message = @"";
//            NSArray *events = [self.eventStore  eventsMatchingPredicate:predicate];
//            for (EKEvent *event in events) {
//                NSLog(@"方法1:获取事件%@",event.description);
//                message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n",event.title]];
//            }
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"日历事件" message:message preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
//            [self presentViewController:alertController animated:YES completion:nil];
//            
//            
//            
//            //            [self.eventStore enumerateEventsMatchingPredicate:predicate usingBlock:^(EKEvent * _Nonnull event, BOOL * _Nonnull stop) {
//            //                NSLog(@"方法2:获取事件%@--%@",event.description,event.eventIdentifier);
//            //            }];
//        }
//    }];
//}
//
//
//// 创建一个日历事件
//- (void)createEvent{
//    
//    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//        
//        if ([self handleError:error granted:granted]) {
//            EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
//            event.title = @"Pearl-Z : Event";
//            event.startDate = [NSDate dateWithTimeIntervalSinceNow:20];
//            event.endDate = [NSDate dateWithTimeInterval:60 sinceDate:event.startDate];
//            //提示闹钟 闹钟可设置地理围栏
//            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:event.startDate];
//            event.alarms = @[alarm];
//            // 必须添加日历，否则不会存入
//            event.calendar = [self.eventStore defaultCalendarForNewEvents];
//            
//            // 如果是循环事件，则span参数设为EKSpanFutureEvents，保存未来的事件
//            NSError *err = [NSError new];
//            BOOL result = [self.eventStore saveEvent:event span:EKSpanThisEvent error:&err];
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@创建结果",event.title] message:[NSString stringWithFormat:@"result:%@\nerror:%@",result?@"成功":@"失败",err] preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//        
//    }];
//}
//
//// 获取全部提醒事项
//- (void)getRemind{
//    
//    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
//        if ([self handleError:error granted:granted]) {
//            NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:nil];
//            
//            [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
//                
//                NSString *message = @"";
//                for (EKReminder *reminder in reminders) {
//                    NSLog(@"方法1:获取事件%@",reminder.description);
//                    message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n",reminder.title]];
//                }
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒事件" message:message preferredStyle:UIAlertControllerStyleAlert];
//                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
//                [self presentViewController:alertController animated:YES completion:nil];
//                
//            }];
//        }
//    }];
//    
//}
//
//
//// 创建一个提醒事项
//- (void)createRemind{
//    
//    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
//        if ([self handleError:error granted:granted]) {
//            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:20];
//            
//            //创建一个提醒功能
//            EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
//            //标题
//            reminder.title = @"Pearl-Z : Reminder";
//            reminder.URL = [NSURL URLWithString:@"baidu.com"];
//            //添加日历
//            NSLog(@"%@",[self.eventStore calendarsForEntityType:EKEntityTypeReminder]);
//            
//            [reminder setCalendar:[self.eventStore defaultCalendarForNewReminders]];
//            NSCalendar *cal = [NSCalendar currentCalendar];
//            [cal setTimeZone:[NSTimeZone systemTimeZone]];
//            NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth |
//            NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute |
//            NSCalendarUnitSecond;
//            NSDateComponents* dateComp = [cal components:flags fromDate:date];
//            dateComp.timeZone = [NSTimeZone systemTimeZone];
//            reminder.startDateComponents = dateComp; //开始时间
//            reminder.dueDateComponents = dateComp; //到期时间
//            reminder.priority = 1; //优先级
//            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date]; //添加一个闹钟
//            [reminder addAlarm:alarm];
//            NSError *err;
//            BOOL result = [self.eventStore saveReminder:reminder commit:YES error:&err];
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@创建结果",reminder.title] message:[NSString stringWithFormat:@"result:%@\nerror:%@",result?@"成功":@"失败",err] preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//    }];
//    
//}
//
//// 日历事件系统事件页面
//- (void)pushEventViewController{
//    
//    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//        
//        if ([self handleError:error granted:granted]) {
//            EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
//            event.title = @"Pearl-Z:日历事件系统事件页面";
//            event.startDate = [NSDate dateWithTimeIntervalSinceNow:20];
//            event.endDate = [NSDate dateWithTimeInterval:60 sinceDate:event.startDate];
//
//            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:event.startDate];
//            event.alarms = @[alarm];
//            event.calendar = [self.eventStore defaultCalendarForNewEvents];
//            event.URL = [NSURL URLWithString:@"baidu.com"];
//            
//            // 如果是循环事件，则span参数设为EKSpanFutureEvents，保存未来的事件
////            NSError *err = [NSError new];
////            BOOL result = [self.eventStore saveEvent:event span:EKSpanThisEvent error:&err];
////            NSLog(@"result:%d--%@",result,err);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
//                eventViewController.event = event;
//                eventViewController.allowsEditing = YES;
//                eventViewController.allowsCalendarPreview = YES;
//                [self.navigationController pushViewController:eventViewController animated:YES];
//            });
//        }
//        
//    }];
//    
//}
//
//// 日历事件编辑页面
//- (void)pushEventEditViewController{
//    
//    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//        
//        if ([self handleError:error granted:granted]) {
//            EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
//            event.title = @"";
//            event.notes = @"";
//            event.location = @"";
////            event.startDate = [NSDate dateWithTimeIntervalSinceNow:20];
////            event.endDate = [NSDate dateWithTimeInterval:60 sinceDate:event.startDate];
//            event.startDate = [NSDate new];
//            event.endDate = [NSDate new];
//            
////            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:event.startDate];
//            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:event.startDate];
//
//            event.alarms = @[alarm];
//            event.calendar = [self.eventStore defaultCalendarForNewEvents];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                EKEventEditViewController *vc = [[EKEventEditViewController alloc] init];
//                vc.eventStore = self.eventStore;
//                vc.event = event;
//                vc.editViewDelegate = self;
//                [self presentViewController:vc animated:YES completion:nil];
//                
////                EKEventViewController *VC = [[EKEventViewController alloc] init];
////                VC.event = event;
////                VC.delegate = self;
//// [self presentViewController:VC animated:YES completion:nil];
//
//            });
//            
//            
//        }
//        
//    }];
//}


- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - tabelview delegate & datasorce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"日历事件编辑页面";
    return cell;
    
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"获取一年内日历事件";
            break;
            
        case 1:
            cell.textLabel.text = @"添加日历事件(20秒后提醒)";
            break;
            
        case 2:
            cell.textLabel.text = @"获取全部提醒事项";
            break;
            
        case 3:
            cell.textLabel.text = @"添加提醒事项(20秒后提醒)";
            break;
            
        case 4:
            cell.textLabel.text = @"日历事件系统事件页面";
            break;
            
        case 5:
            cell.textLabel.text = @"日历事件编辑页面";
            break;
            
        case 6:
            cell.textLabel.text = @"地理围栏";
            break;
            
        default:
            break;
    }
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CalendarViewController *view = [[CalendarViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
    
    
    switch (indexPath.row) {
        case 0:{
//            [self getEvents];
            break;
        }
            
        case 1:{
//            [self createEvent];
            break;
        }
            
        case 2:{
//            [self getRemind];
            break;
        }
            
        case 3:{
//            [self createRemind];
            break;
        }
            
        case 4:{
//            [self pushEventViewController];
            break;
        }
            
        case 5:{
//            [self pushEventEditViewController];
            
            CalendarViewController *view = [[CalendarViewController alloc] init];
            [self.navigationController pushViewController:view animated:YES];
            
            break;
        }
            
        case 6:{
            GeofenceViewController *geoVC = [[GeofenceViewController alloc] init];
            [self.navigationController pushViewController:geoVC animated:YES];
            break;
        }
            
        default:
            break;
    }
}




@end
