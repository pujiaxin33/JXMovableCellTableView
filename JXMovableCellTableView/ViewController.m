//
//  ViewController.m
//  JXMovableCellTableView
//
//  Created by jiaxin on 16/2/15.
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "ViewController.h"
#import "JXMovableCellTableView.h"

@interface ViewController ()<JXMovableCellTableViewDataSource, JXMovableCellTableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [NSMutableArray new];
    NSArray *sectionTextArray = @[@"I am just a plain text 😳",
                                  @"I am just a lovely text 😊",
                                  @"I am just a naughty text 😜",
                                  @"I am just a boring text 🙈"];
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
    tableView.longPressGesture.minimumPressDuration = 1.0;
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView
{
    return _dataSource;
}

#pragma mark - JXMovableCellTableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2) {
        return NO;
    }

    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)tableView:(JXMovableCellTableView *)tableView customizeMovalbeCell:(UIImageView *)movableCellsnapshot {
    movableCellsnapshot.layer.shadowColor = [UIColor redColor].CGColor;
    movableCellsnapshot.layer.masksToBounds = NO;
    movableCellsnapshot.layer.cornerRadius = 0;
    movableCellsnapshot.layer.shadowOffset = CGSizeMake(0, 0);
    movableCellsnapshot.layer.shadowOpacity = 0.4;
    movableCellsnapshot.layer.shadowRadius = 10;
}

- (void)tableView:(JXMovableCellTableView *)tableView customizeStartMovingAnimation:(UIImageView *)movableCellsnapshot fingerPoint:(CGPoint)fingerPoint {
    //move to finger
    [UIView animateWithDuration:0.25 animations:^{
        movableCellsnapshot.center = CGPointMake(movableCellsnapshot.center.x, fingerPoint.y);
    }];

    //scale big
//    [UIView animateWithDuration:0.25 animations:^{
//        movableCellsnapshot.center = CGPointMake(movableCellsnapshot.center.x, fingerPoint.y);
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


}


@end
