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

@interface ViewController ()<JXMovableCellTableViewDataSource, JXMovableCellTableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [NSMutableArray new];
    NSArray *sectionTextArray = @[@"我只是一段普通的文本😳",
                                  @"我只是一段可爱的文本😊",
                                  @"我只是一段调皮的文本😜",
                                  @"我只是一段无聊的文本🙈"];
    for (NSInteger section = 0; section < sectionTextArray.count; section ++) {
        NSMutableArray *sectionArray = [NSMutableArray new];
        for (NSInteger row = 0; row < 5; row ++) {
            [sectionArray addObject:[NSString stringWithFormat:@"%@-%ld", sectionTextArray[section], row]];
        }
        [_dataSource addObject:sectionArray];
    }
    
    JXMovableCellTableView *tableView = [[JXMovableCellTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2) {
        return NO;
    }

    return YES;
}

- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView
{
    return _dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
