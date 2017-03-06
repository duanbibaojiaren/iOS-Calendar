//
//  EventManger.h
//  CalendarRemindersDemo
//
//  Created by LXie on 17/3/6.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface EventManger : NSObject
@property (nonatomic, copy) void(^changeEventBlock)();

+(instancetype)shareInstance;

- (NSMutableArray *)getEvent; // 查询
- (BOOL)removeEvent:(EKEvent *)event; // 移除
- (void)pushEditVCSelectDate:(NSDate *)selectDate completion:(void(^)(EKEventEditViewController *VC))block; // push到编辑界面

@end
