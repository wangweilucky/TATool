//
//  TALoggerController.m
//  ThinkingSDKDEMO
//
//  Created by wwango on 2022/6/13.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TALoggerController.h"
#import "TALoggerManager.h"
#import "TALoggerDetialController.h"

@interface TALoggerController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSDictionary *> *datas;

@end

@implementation TALoggerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,
                                                                   UIScreen.mainScreen.bounds.size.height) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self refleshData];
    
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancleButton setTitle:@"刷新" forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(refleshData) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:cancleButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)refleshData {
    _datas = [[[TALoggerManager search] reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [self.tableView setContentOffset:CGPointMake(0, 0)];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header;
    header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 44)];
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(44, 0,UIScreen.mainScreen.bounds.size.width, 44)];
    lable1.text = @"时间";
    lable1.font = [UIFont boldSystemFontOfSize:12];
    UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width - 100, 0,UIScreen.mainScreen.bounds.size.width, 44)];
    lable2.text = @"日志";
    lable2.font = [UIFont boldSystemFontOfSize:12];
    [header addSubview:lable1];
    [header addSubview:lable2];
    header.backgroundColor = [UIColor whiteColor];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *message = [NSString stringWithFormat:@"%@    %@", self.datas[indexPath.row][@"time"],self.datas[indexPath.row][@"message"]];
    cell.textLabel.text = message;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TALoggerDetialController *vc = [TALoggerDetialController new];
    vc.dic = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
