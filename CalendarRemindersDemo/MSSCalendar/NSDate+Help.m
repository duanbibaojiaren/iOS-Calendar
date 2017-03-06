//
//  NSDate+Help.m
//  CalendarRemindersDemo
//
//  Created by LXie on 17/2/28.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import "NSDate+Help.h"

@implementation NSDate (Help)

- (NSDateComponents *)dateToComponents {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *components = [calendar components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self];
    return components;

}

+ (NSDate *)componentsToDate:(NSDateComponents *)components
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    // 不区分时分秒
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

- (NSString *)dateToString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
    NSString *dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

@end
