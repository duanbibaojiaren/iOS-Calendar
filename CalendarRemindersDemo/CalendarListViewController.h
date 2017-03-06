//
//  CalendarListViewController.h
//  CalendarRemindersDemo
//
//  Created by LXie on 17/3/1.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>


@interface CalendarListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *eventArray; // 查询得到的事件
@property (nonatomic, copy) void(^updateCalendar)(EKEvent *event);

@end
