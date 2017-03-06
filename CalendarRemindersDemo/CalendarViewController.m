//
//  CalendarViewController.m
//  CalendarRemindersDemo
//
//  Created by LXie on 17/2/28.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import "CalendarViewController.h"
#import "MSSCalendarViewController.h"
#import "MSSCalendarDefine.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface CalendarViewController () <MSSCalendarViewControllerDelegate, EKEventEditViewDelegate>

@property (nonatomic,assign)NSInteger startDate;
@property (nonatomic,assign)NSInteger endDate;
@property (nonatomic,strong) NSDate *selecteDate;

//@property(nonatomic,strong) EKEventStore *eventStore;
//@property (nonatomic, strong) EKEventEditViewController *eventEditVC;
@property (nonatomic, strong) MSSCalendarViewController *calendarVC;

@end

@implementation CalendarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)createUI
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((MSS_SCREEN_WIDTH - 110) / 2, 80, 110, 50);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    btn.layer.cornerRadius = 5.0f;
    btn.layer.borderWidth = 1.0f;
    btn.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    [btn setTitle:@"打开日历" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(calendarClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)calendarClick:(UIButton *)btn
{
    MSSCalendarViewController *cvc = [MSSCalendarViewController defaultCalendar];
    cvc.limitMonth = 12 * 1;// 显示几个月的日历
    /*
     MSSCalendarViewControllerLastType 只显示当前月之前
     MSSCalendarViewControllerMiddleType 前后各显示一半
     MSSCalendarViewControllerNextType 只显示当前月之后
     */
    cvc.type = MSSCalendarViewControllerMiddleType;
    cvc.beforeTodayCanTouch = YES;// 今天之前的日期是否可以点击
    cvc.afterTodayCanTouch = YES;// 今天之后的日期是否可以点击
    cvc.startDate = _startDate;// 选中开始时间
    cvc.endDate = _endDate;// 选中结束时间
    /*以下两个属性设为YES,计算中国农历非常耗性能（在5s加载15年以内的数据没有影响）*/
    cvc.showChineseHoliday = YES;// 是否展示农历节日
    cvc.showChineseCalendar = YES;// 是否展示农历
    cvc.showHolidayDifferentColor = YES;// 节假日是否显示不同的颜色
    cvc.showAlertView = YES;// 是否显示提示弹窗
    cvc.delegate = self;
    
    self.calendarVC = cvc;
    [self presentViewController:cvc animated:YES completion:nil];
}

- (void)calendarViewConfirmClickWithStartDate:(NSInteger)startDate endDate:(NSInteger)endDate
{
    _startDate = startDate;
    _endDate = endDate;
}

- (void)didSelectDateItem:(NSDate *)selectDate {
    NSLog(@"selectDate==%@", selectDate);
    
//    self.selecteDate = selectDate;
//    [self pushEventEditViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
