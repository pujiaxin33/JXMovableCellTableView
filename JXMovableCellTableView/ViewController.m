//
//  ViewController.m
//  JXMovableCellTableView
//
//  Created by jiaxin on 16/2/15.
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "ViewController.h"
#import "JXMovableCellTableView.h"
#import "CustomMoveCellTableView.h"

@interface ViewController ()<JXMovableCellTableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, weak) UITableView *testTableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [NSMutableArray new];
    for (NSInteger section = 0; section < 6; section ++) {
        NSMutableArray *sectionArray = [NSMutableArray new];
        for (NSInteger row = 0; row < 5; row ++) {
            [sectionArray addObject:[NSString stringWithFormat:@"section -- %ld row -- %ld", section, row]];
        }
        [_dataSource addObject:sectionArray];
    }
    
    JXMovableCellTableView *tableView = [[JXMovableCellTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    tableView.gestureMinimumPressDuration = 1.0;
    tableView.drawMovalbeCellBlock = ^(UIView *movableCell){
        movableCell.layer.shadowColor = [UIColor grayColor].CGColor;
        movableCell.layer.masksToBounds = NO;
        movableCell.layer.cornerRadius = 0;
        movableCell.layer.shadowOffset = CGSizeMake(-5, 0);
        movableCell.layer.shadowOpacity = 0.4;
        movableCell.layer.shadowRadius = 5;
    };
    
//    CustomMoveCellTableView *customTableView = [[CustomMoveCellTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    customTableView.dataSource = self;
//    [self.view addSubview:customTableView];
//    [customTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
//    UITableView *originalTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    originalTableView.dataSource = self;
//    originalTableView.delegate = self;
//    [self.view addSubview:originalTableView];
//    [originalTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    self.testTableView = originalTableView;
}
//默认编辑模式下，每个cell左边有个红色的删除按钮，设置为None即可去掉
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
//是否允许indexPath的cell移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //更新数据源
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (NSArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView
{
    return _dataSource.copy;
}

- (void)tableView:(JXMovableCellTableView *)tableView newDataSourceArrayAfterMove:(NSArray *)newDataSourceArray
{
    _dataSource = newDataSourceArray.mutableCopy;
}

@end
