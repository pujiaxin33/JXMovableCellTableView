//
//  ViewController.m
//  JXMovableCellTableView
//
//  Created by jiaxin on 16/2/15.
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "ViewController.h"
#import "JXMovableCellTableView.h" 
#import "JXTableViewCell.h"

@interface ViewController ()<JXMovableCellTableViewDataSource, JXMovableCellTableViewDelegate>
@property (nonatomic, strong) JXMovableCellTableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSMutableArray *> *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"JXMovableCellTableView";
    self.edgesForExtendedLayout = UIRectEdgeNone;

    _dataSource = [NSMutableArray new];
    NSArray *sectionTextArray = @[@"I am just a plain text 😳",
                                  @"I am just a lovely text 😊",
                                  @"I am just a naughty text 😜",
                                  @"I am just a boring text 🙈"];
    for (NSInteger section = 0; section < sectionTextArray.count; section ++) {
        NSMutableArray *sectionArray = [NSMutableArray new];
        for (NSInteger row = 0; row < 20; row ++) {
            [sectionArray addObject:[NSString stringWithFormat:@"%@-%ld", sectionTextArray[section], row]];
        }
        [_dataSource addObject:sectionArray];
    }
    
    _tableView = [[JXMovableCellTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.notCanMoveAnimation = NO;
    [self.view addSubview:_tableView];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JXTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([JXTableViewCell class])];

    _tableView.longPressGesture.minimumPressDuration = 1.0;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    _tableView.frame = self.view.bounds;
}

#pragma mark - JXMovableCellTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JXTableViewCell class]) forIndexPath:indexPath];
    cell.indexLabel.text = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (NSMutableArray <NSMutableArray *> *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView
{
    return _dataSource;
}

//自定义拖拽的view
- (UIView *)snapshotViewWithCell:(JXTableViewCell *)cell{
    return cell.bgView;
}

#pragma mark - JXMovableCellTableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //第二组禁止拖拽
    if (indexPath.section == 1) {
        return NO;
    }

    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)tableView:(JXMovableCellTableView *)tableView customizeMovalbeCell:(UIImageView *)movableCellsnapshot { 
    movableCellsnapshot.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    movableCellsnapshot.layer.masksToBounds = NO;
    movableCellsnapshot.layer.cornerRadius = 10;
    movableCellsnapshot.layer.shadowOffset = CGSizeMake(0, 0);
    movableCellsnapshot.layer.shadowOpacity = 1.0;
    movableCellsnapshot.layer.shadowRadius = 10;
    
}

//- (void)tableView:(JXMovableCellTableView *)tableView customizeStartMovingAnimation:(UIImageView *)movableCellsnapshot fingerPoint:(CGPoint)fingerPoint {
//    //move to finger
//    [UIView animateWithDuration:0.25 animations:^{
//        movableCellsnapshot.center = CGPointMake(movableCellsnapshot.center.x, fingerPoint.y);
//    }];

    //scale big
//    [UIView animateWithDuration:0.25 animations:^{
//        movableCellsnapshot.transform = CGAffineTransformMakeScale(1.1, 1.1);
//    }];

    //like a breath
//    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
//        movableCellsnapshot.transform = CGAffineTransformMakeScale(1.1, 1.1);
//    } completion:^(BOOL finished) {
//
//    }];

    //Neon light
//    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowColor"];
//    colorAnimation.duration = 5;
//    colorAnimation.values = @[
//                              (__bridge id)[UIColor redColor].CGColor,
//                              (__bridge id)[UIColor blueColor].CGColor,
//                              (__bridge id)[UIColor greenColor].CGColor,
//                              (__bridge id)[UIColor yellowColor].CGColor,
//                              (__bridge id)[UIColor purpleColor].CGColor,
//                              (__bridge id)[UIColor orangeColor].CGColor, ];
//    colorAnimation.repeatCount = INFINITY;
//    [movableCellsnapshot.layer addAnimation:colorAnimation forKey:@"color"];


//}


@end
