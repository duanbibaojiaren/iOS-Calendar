//
//  MSSCalendarViewController.m
//  MSSCalendar
//
//  Created by 于威 on 16/4/3.
//  Copyright © 2016年 于威. All rights reserved.
//

#import "MSSCalendarViewController.h"
#import "MSSCalendarCollectionViewCell.h"
#import "MSSCalendarHeaderModel.h"
#import "MSSCalendarManager.h"
#import "MSSCalendarCollectionReusableView.h"
#import "MSSCalendarPopView.h"
#import "MSSCalendarDefine.h"
#import "NSDate+Help.h"
#import "CalendarListViewController.h"
#import "EventManger.h"


#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface MSSCalendarViewController () <EKEventEditViewDelegate>
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)MSSCalendarPopView *popView;

@property (nonatomic,assign)NSInteger showToday;//标记当前日期
@property (nonatomic, strong) NSIndexPath *todayPath; // 当前的path
@property (nonatomic, strong) NSDateComponents *todayComponents;
@property (nonatomic, strong) NSMutableArray *eventDateArray; //将事件日期记住日期，进行显示提示试图
@property (nonatomic, strong) NSMutableArray *eventArray; // 查询得到的事件
@property (nonatomic, strong) EKEventEditViewController *eventEditVC;

@end

@implementation MSSCalendarViewController

+ (instancetype)defaultCalendar
{
    static MSSCalendarViewController *_calendar = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _calendar = [[MSSCalendarViewController alloc] init];
    });
    
    return _calendar;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _afterTodayCanTouch = YES;
        _beforeTodayCanTouch = YES;
        _dataArray = [[NSMutableArray alloc]init];
        _showChineseCalendar = NO;
        _showChineseHoliday = NO;
        _showHolidayDifferentColor = NO;
        _showAlertView = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    _todayComponents = [[NSDate date] dateToComponents];
    
    // 获取一段时间内的所以日历事件
    [self getTimeCalendarEvents];
    
    [self initDataSource];
    [self createUI];
}

- (void)getTimeCalendarEvents {
    
    if (_type == MSSCalendarViewControllerMiddleType) {
        
        self.eventArray = [[EventManger shareInstance] getEvent];
        for (EKEvent *event in self.eventArray) {
            [self startToEndDateStr:event];
        }
    }
}

- (void)startToEndDateStr:(EKEvent *)event {
    NSDateComponents *componentStart = [event.startDate dateToComponents];
    NSDateComponents *componentEnd = [event.endDate dateToComponents];
    
    NSDate *startDate = [NSDate componentsToDate:componentStart];
    NSDate *endDate = [NSDate componentsToDate:componentEnd];
    
    NSInteger startInterval = [startDate timeIntervalSince1970];
    NSInteger endInterval = [endDate timeIntervalSince1970];
    
    [self.eventDateArray addObject:@(startInterval)];
    [self.eventDateArray addObject:@(endInterval)];
    // 时间戳
    NSInteger dateInterval = [endDate timeIntervalSinceDate:startDate];
    NSInteger dayInt = dateInterval/60/60/24;
    
    for (int i = 1; i <= dayInt; i++) {
        [self.eventDateArray addObject:@(startInterval+i*60*60*24)];
    }
}

- (void)removeStartToEndDateStr:(EKEvent *)event {
    NSDateComponents *componentStart = [event.startDate dateToComponents];
    NSDateComponents *componentEnd = [event.endDate dateToComponents];
    
    NSDate *startDate = [NSDate componentsToDate:componentStart];
    NSDate *endDate = [NSDate componentsToDate:componentEnd];
    
    NSInteger startInterval = [startDate timeIntervalSince1970];
    NSInteger endInterval = [endDate timeIntervalSince1970];
    
    [self.eventDateArray removeObject:@(startInterval)];
    [self.eventDateArray removeObject:@(endInterval)];
    // 时间戳
    NSInteger dateInterval = [endDate timeIntervalSinceDate:startDate];
    NSInteger dayInt = dateInterval/60/60/24;
    
    for (int i = 1; i <= dayInt; i++) {
        [self.eventDateArray removeObject:@(startInterval+i*60*60*24)];
    }
}

- (NSMutableArray *)eventDateArray {
    if (!_eventDateArray) {
        _eventDateArray = [NSMutableArray array];
    }
    return _eventDateArray;
}
- (NSMutableArray *)eventArray {
    if (!_eventArray ) {
        _eventArray = [NSMutableArray array];
    }
    return _eventArray;
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_popView)
    {
        [_popView removeFromSuperview];
        _popView = nil;
    }
}

- (void)initDataSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MSSCalendarManager *manager = [[MSSCalendarManager alloc]initWithShowChineseHoliday:_showChineseHoliday showChineseCalendar:_showChineseCalendar startDate:_startDate];
        NSArray *tempDataArray = [manager getCalendarDataSoruceWithLimitMonth:_limitMonth type:_type];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_dataArray addObjectsFromArray:tempDataArray];
            [self showCollectionViewWithStartIndexPath:manager.startIndexPath];
        });
    });
}

- (void)addWeakView
{
    UIView *weekView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, MSS_SCREEN_WIDTH, MSS_WeekViewHeight)];
    weekView.backgroundColor = MSS_SelectBackgroundColor;
    [self.view addSubview:weekView];
    
    NSArray *weekArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    int i = 0;
    NSInteger width = MSS_Iphone6Scale(54);
    for(i = 0; i < 7;i++)
    {
        UILabel *weekLabel = [[UILabel alloc]initWithFrame:CGRectMake(i * width, 0, width, MSS_WeekViewHeight)];
        weekLabel.backgroundColor = [UIColor clearColor];
        weekLabel.text = weekArray[i];
        weekLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        if(i == 0 || i == 6)
        {
            weekLabel.textColor = MSS_WeekEndTextColor;
        }
        else
        {
            weekLabel.textColor = MSS_SelectTextColor;
        }
        [weekView addSubview:weekLabel];
    }
}

- (void)showCollectionViewWithStartIndexPath:(NSIndexPath *)startIndexPath
{
    [self addWeakView];
    [_collectionView reloadData];
    // 滚动到上次选中的位置
    if(startIndexPath)
    {
        [_collectionView scrollToItemAtIndexPath:startIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        _collectionView.contentOffset = CGPointMake(0, _collectionView.contentOffset.y - MSS_HeaderViewHeight);
    }
    else
    {
        if(_type == MSSCalendarViewControllerLastType)
        {
            if([_dataArray count] > 0)
            {
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_dataArray.count - 1] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }
        }
        else if(_type == MSSCalendarViewControllerMiddleType)
        {
            if([_dataArray count] > 0)
            {
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(_dataArray.count - 1) / 2] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                _collectionView.contentOffset = CGPointMake(0, _collectionView.contentOffset.y - MSS_HeaderViewHeight);
            }
        }
    }
}

- (void)createUI
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    headerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:headerView];
    
    UIButton *showTodayBut = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 100, 64)];
    showTodayBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    showTodayBut.font = [UIFont systemFontOfSize:15];
    [showTodayBut setTitle:@"当前日期" forState:UIControlStateNormal];
    [showTodayBut addTarget:self action:@selector(showTodayAction) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:showTodayBut];
    
    UIButton *calendarBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth- 100-20, 0, 100, 64)];
    calendarBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    calendarBtn.font = [UIFont systemFontOfSize:15];
    [calendarBtn setTitle:@"显示事件" forState:UIControlStateNormal];
    [calendarBtn addTarget:self action:@selector(showCalendarAction) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:calendarBtn];
    
    NSInteger width = MSS_Iphone6Scale(54);
    NSInteger height = MSS_Iphone6Scale(60);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(width, height);
    flowLayout.headerReferenceSize = CGSizeMake(MSS_SCREEN_WIDTH, MSS_HeaderViewHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64 + MSS_WeekViewHeight, width * 7, MSS_SCREEN_HEIGHT - 64 - MSS_WeekViewHeight) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.scrollsToTop = NO; // 设置点击状态栏不让scrollView置顶
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[MSSCalendarCollectionViewCell class] forCellWithReuseIdentifier:@"MSSCalendarCollectionViewCell"];
    [_collectionView registerClass:[MSSCalendarCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MSSCalendarCollectionReusableView"];
}


#pragma mark -- Actions

- (void)showTodayAction {
    //    NSLog(@"_todayPath ==%@", _todayPath);
    [self showCollectionViewWithStartIndexPath:_todayPath];
}

- (void)showCalendarAction {
    CalendarListViewController *VC = [[CalendarListViewController alloc] init];
    VC.eventArray = _eventArray;
    
    __weak __typeof(self)weakSelf = self;
    [VC setUpdateCalendar:^(EKEvent *event) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        [strongSelf.eventArray removeObject:event];
        [strongSelf removeStartToEndDateStr:event];
        [strongSelf.collectionView reloadData];
    }];
    [self presentViewController:VC animated:YES completion:nil];
}

#pragma mark ---UICollectionViewDelegate & DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_dataArray count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    MSSCalendarHeaderModel *headerItem = _dataArray[section];
    return headerItem.calendarItemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSSCalendarCollectionViewCell" forIndexPath:indexPath];
    if(cell)
    {
        MSSCalendarHeaderModel *headerItem = _dataArray[indexPath.section];
        MSSCalendarModel *calendarItem = headerItem.calendarItemArray[indexPath.row];
        cell.dateLabel.text = @"";
        cell.dateLabel.textColor = MSS_TextColor;
        cell.subLabel.text = @"";
        cell.subLabel.textColor = MSS_SelectSubLabelTextColor;
        cell.isSelected = NO;
        cell.userInteractionEnabled = NO;
        
        
        // fix 记住当前日期的indexpath
        if (calendarItem.year == _todayComponents.year && calendarItem.month == _todayComponents.month && calendarItem.day == _todayComponents.day) {
            //            NSLog(@"====%@", _todayComponents);
            
            self.todayPath = indexPath;
        }
        
        if(calendarItem.day > 0)
        {
            
            if(calendarItem.holiday.length > 0)
            {
                cell.dateLabel.text = calendarItem.holiday;
            }else {
                cell.dateLabel.text = [NSString stringWithFormat:@"%ld",(long)calendarItem.day];
            }
            cell.userInteractionEnabled = YES;
            
            if ([self.eventDateArray containsObject:@(calendarItem.dateInterval)]) {
                cell.hintLayer.hidden = NO;
            }else {
                cell.hintLayer.hidden = YES;
            }
        }else {
            cell.hintLayer.hidden = YES;
        }
        
        if(_showChineseCalendar)
        {
            cell.subLabel.text = calendarItem.chineseCalendar;
        }
        
        // 开始日期
        if(calendarItem.dateInterval == _startDate)
        {
            //            cell.isSelected = YES;
            //            cell.dateLabel.textColor = MSS_SelectTextColor;
            cell.subLabel.text = MSS_SelectBeginText;
            
        }
        // 结束日期
        else if (calendarItem.dateInterval == _endDate)
        {
            //            cell.isSelected = YES;
            //            cell.dateLabel.textColor = MSS_SelectTextColor;
            cell.subLabel.text = MSS_SelectEndText;
        }
        // 开始和结束之间的日期
        else if(calendarItem.dateInterval > _startDate && calendarItem.dateInterval < _endDate)
        {
            //            cell.isSelected = YES;
            //            cell.dateLabel.textColor = MSS_SelectTextColor;
        }
        else
        {
            if(calendarItem.week == 0 || calendarItem.week == 6)
            {
                //                cell.dateLabel.textColor = MSS_WeekEndTextColor;
                //                cell.subLabel.textColor = MSS_WeekEndTextColor;
            }
            if(calendarItem.holiday.length > 0)
            {
                cell.dateLabel.text = calendarItem.holiday;
                if(_showHolidayDifferentColor)
                {
                    //                    cell.dateLabel.textColor = MSS_HolidayTextColor;
                    //                    cell.subLabel.textColor = MSS_HolidayTextColor;
                }
            }
        }
        
        if(!_afterTodayCanTouch)
        {
            if(calendarItem.type == MSSCalendarNextType)
            {
                //                cell.dateLabel.textColor = MSS_TouchUnableTextColor;
                //                cell.subLabel.textColor = MSS_TouchUnableTextColor;
                cell.userInteractionEnabled = NO;
            }
        }
        if(!_beforeTodayCanTouch)
        {
            if(calendarItem.type == MSSCalendarLastType)
            {
                //                cell.dateLabel.textColor = MSS_TouchUnableTextColor;
                //                cell.subLabel.textColor = MSS_TouchUnableTextColor;
                cell.userInteractionEnabled = NO;
            }
        }
    }
    return cell;
}

// 添加header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MSSCalendarCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MSSCalendarCollectionReusableView" forIndexPath:indexPath];
        MSSCalendarHeaderModel *headerItem = _dataArray[indexPath.section];
        headerView.headerLabel.text = headerItem.headerText;
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSCalendarHeaderModel *headerItem = _dataArray[indexPath.section];
    MSSCalendarModel *calendaItem = headerItem.calendarItemArray[indexPath.row];
    _startDate = 0; // fix
    // 当开始日期为空时
    if(_startDate == 0)
    {
        _startDate = calendaItem.dateInterval;
        [self showPopViewWithIndexPath:indexPath];
    }
    // 当开始日期和结束日期同时存在时(点击为重新选时间段)
    else if(_startDate > 0 && _endDate > 0)
    {
        _startDate = calendaItem.dateInterval;
        _endDate = 0;
        [self showPopViewWithIndexPath:indexPath];
    }
    else
    {
        // 判断第二个选择日期是否比现在开始日期大
        if(_startDate < calendaItem.dateInterval)
        {
            _endDate = calendaItem.dateInterval;
            if([_delegate respondsToSelector:@selector(calendarViewConfirmClickWithStartDate:endDate:)])
            {
                [_delegate calendarViewConfirmClickWithStartDate:_startDate endDate:_endDate];
            }
            //            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            _startDate = calendaItem.dateInterval;
            [self showPopViewWithIndexPath:indexPath];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(didSelectDateItem:)]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
//        NSString *startDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:calendaItem.dateInterval]];
        
        [_delegate didSelectDateItem:[NSDate dateWithTimeIntervalSince1970:calendaItem.dateInterval]];
        
        // 跳转到日历编辑器
        [self pushEventEditViewController:[NSDate dateWithTimeIntervalSince1970:calendaItem.dateInterval]];
    }
    
    [_collectionView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(_popView)
    {
        [_popView removeFromSuperview];
        _popView = nil;
    }
}

- (void)showPopViewWithIndexPath:(NSIndexPath *)indexPath;
{
    if(_showAlertView)
    {
        [_popView removeFromSuperview];
        _popView = nil;
        
        MSSCalendarPopViewArrowPosition arrowPostion = MSSCalendarPopViewArrowPositionMiddle;
        NSInteger position = indexPath.row % 7;
        if(position == 0)
        {
            arrowPostion = MSSCalendarPopViewArrowPositionLeft;
        }
        else if(position == 6)
        {
            arrowPostion = MSSCalendarPopViewArrowPositionRight;
        }
        
        MSSCalendarCollectionViewCell *cell = (MSSCalendarCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        _popView = [[MSSCalendarPopView alloc]initWithSideView:cell.dateLabel arrowPosition:arrowPostion];
        _popView.topLabelText = [NSString stringWithFormat:@"请选择%@日期",MSS_SelectEndText];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM月dd日"MSS_SelectBeginText];
        NSString *startDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_startDate]];
        _popView.bottomLabelText = startDateString;
        [_popView showWithAnimation];
    }
}



// 日历事件编辑页面
- (void)pushEventEditViewController:(NSDate *)selectDate {
    
    NSLog(@"pushEventEditViewController");
    
    __weak __typeof(self)weakSelf = self;
    EventManger *evnetManger = [EventManger shareInstance];
    [evnetManger pushEditVCSelectDate:selectDate completion:^(EKEventEditViewController *VC) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        VC.editViewDelegate = strongSelf;
        strongSelf.eventEditVC = VC;
        [strongSelf presentViewController:VC animated:YES completion:nil];
    }];
    
    // 监听保存添加事件后的处理
    [evnetManger setChangeEventBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf updateCalendar:_eventEditVC.event];
    }];
}

- (void)updateCalendar:(EKEvent *)event {
    if (![self.eventArray containsObject:event]) {
        [self startToEndDateStr:event];
        [self.eventArray addObject:event];
        [self.collectionView reloadData];
    }
}


#pragma mark - 处理错误信息

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

#pragma mark -- Delegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
