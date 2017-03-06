//
//  EventManger.m
//  CalendarRemindersDemo
//
//  Created by LXie on 17/3/6.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import "EventManger.h"


@interface EventManger ()

@property (nonatomic , retain) EKEventStore *store;
@property (nonatomic, assign) BOOL isRemove;

@end

@implementation EventManger

static EventManger *manger = nil;

+(instancetype)shareInstance{
    EventManger *man = [EventManger defaltInstance];
    if (man.store == nil) {
        [man requestEKEventStore];
    }
    return man;
}

+(instancetype)defaltInstance
{
    if (manger == nil) {
        manger = [[EventManger alloc]init];
    }
    return manger;
}

-(void)requestEKEventStore
{
    self.store = [[EKEventStore alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.store];
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        if ([self handleError:error granted:granted])
            }];
    
}

#pragma mark - 添加地理围栏提醒事项事件
// 对于提醒事项权限获取错误处理
//- (BOOL)handleError:(NSError *)error granted:(BOOL)granted{
//    if (error) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求出错" message:error.description preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        }]];
//        [self presentViewController:alertController animated:YES completion:nil];
//        return NO;
//    }
//    
//    if (!granted) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        }]];
//        [self presentViewController:alertController animated:YES completion:nil];
//        return NO;
//    }
//    
//    return YES;
//}

- (NSMutableArray *)getEvent {
    NSMutableArray *eventArray = [NSMutableArray array];
    
    NSDate* ssdate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*30*7];//事件段，开始时间
    NSDate* ssend = [NSDate dateWithTimeIntervalSinceNow:3600*24*30*7];//结束时间，取中间
    NSPredicate* predicate = [self.store predicateForEventsWithStartDate:ssdate
                                                                 endDate:ssend
                                                               calendars:nil];
    NSArray* events = [self.store eventsMatchingPredicate:predicate];//数组里面就是时间段中的EKEvent事件数组
    
    for (EKEvent *event in events) {
        if (event.calendar.type == EKCalendarTypeCalDAV) {
            [eventArray addObject:event];
        }
    }
    return eventArray;
}

- (void)pushEditVCSelectDate:(NSDate *)selectDate completion:(void (^)(EKEventEditViewController *))block {
    
    EKEvent *event = [EKEvent eventWithEventStore:self.store];
    event.title = @"";
    event.notes = @"";
    event.location = @"";
    event.startDate = selectDate ;
    event.endDate = selectDate;
    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:event.startDate];
    
    event.alarms = @[alarm];
    event.calendar = [self.store defaultCalendarForNewEvents];
    
    EKEventEditViewController *vc = [[EKEventEditViewController alloc] init];
    vc.eventStore = self.store;
    vc.event = event;
    block(vc);
                // 跳转日历事件列表
                // [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"calshow://"]];
}

- (BOOL)removeEvent:(EKEvent *)event {
        NSError *err;
        [event setCalendar:[self.store defaultCalendarForNewEvents]];
       BOOL isSuccess = [self.store removeEvent:event span:EKSpanThisEvent commit:YES error:&err];
        if (err == nil) {
            isSuccess = YES;
            NSLog(@"成功");
            self.isRemove = YES;
        }
        return isSuccess;
}

//#pragma mark - 监听通知
- (void)storeChanged:(NSNotification *)notic{
    NSLog(@"storeChanged:----------%@",notic);
    if (_isRemove) {
        self.isRemove = NO;
        return;
    }
    
    if (self.changeEventBlock) {
        self.changeEventBlock();
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
