//
//  NSDate+Help.h
//  CalendarRemindersDemo
//
//  Created by LXie on 17/2/28.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Help)

+ (NSDate *)componentsToDate:(NSDateComponents *)components;

- (NSDateComponents *)dateToComponents;
- (NSString *)dateToString;

@end
