//
//  CalendarListViewController.m
//  CalendarRemindersDemo
//
//  Created by LXie on 17/3/1.
//  Copyright © 2017年 Pearl-Z. All rights reserved.
//

#import "CalendarListViewController.h"
#import "NSDate+Help.h"
#import "EventManger.h"

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface CalendarListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation CalendarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, ScreenWidth , ScreenHeight-80) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
    backBtn.font = [UIFont systemFontOfSize:13];
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    backBtn.tintColor = [UIColor blackColor];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- UITableViewDelegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    EKEvent *event = self.eventArray[indexPath.row];
    cell.textLabel.text = event.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"start:%@-end:%@",[event.startDate dateToString], [event.endDate dateToString]];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    EKEvent *event = self.eventArray[indexPath.row];
    BOOL isSuccess = [[EventManger shareInstance] removeEvent:event];
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eventArray removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
            self.updateCalendar(event);
        });
    }
}

#pragma mark -- Actions

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
