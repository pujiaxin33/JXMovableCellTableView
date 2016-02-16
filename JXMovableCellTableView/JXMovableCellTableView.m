//
//  JXMovableCellTableView.m
//  JXMovableCellTableView
//
//  Created by jiaxin on 16/2/15.
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "JXMovableCellTableView.h"

static NSTimeInterval kJXMovableCellAnimationTime = 0.25;

@interface JXMovableCellTableView ()
@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIView *tempView;
@property (nonatomic, strong) NSMutableArray *tempDataSource;
@property (nonatomic, strong) CADisplayLink *edgeScrollTimer;
@end

@implementation JXMovableCellTableView

@dynamic dataSource, delegate;

- (void)dealloc
{
    _drawMovalbeCellBlock = nil;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self jx_initData];
        [self jx_addGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self jx_initData];
        [self jx_addGesture];
    }
    return self;
}

- (void)jx_initData
{
    _gestureMinimumPressDuration = 1.f;
    _canEdgeScroll = YES;
    _edgeScrollRange = 150.f;
}

#pragma mark Setter

- (void)setGestureMinimumPressDuration:(CGFloat)gestureMinimumPressDuration
{
    _gestureMinimumPressDuration = gestureMinimumPressDuration;
    _gesture.minimumPressDuration = MAX(0.2, gestureMinimumPressDuration);
}

#pragma mark Gesture

- (void)jx_addGesture
{
    _gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(jx_processGesture:)];
    _gesture.minimumPressDuration = _gestureMinimumPressDuration;
    [self addGestureRecognizer:_gesture];
}

- (void)jx_processGesture:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self jx_gestureBegan:gesture];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (!_canEdgeScroll) {
                [self jx_gestureChanged:gesture];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self jx_gestureEndedOrCancelled:gesture];
        }
            break;
        default:
            break;
    }
}

- (void)jx_gestureBegan:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    NSIndexPath *selectedIndexPath = [self indexPathForRowAtPoint:point];
    if (!selectedIndexPath) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self willMoveCellAtIndexPath:selectedIndexPath];
    }
    if (_canEdgeScroll) {
        //开启边缘滚动
        [self jx_startEdgeScroll];
    }
    //每次移动开始获取一次数据源
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceArrayInTableView:)]) {
        _tempDataSource = [self.dataSource dataSourceArrayInTableView:self].mutableCopy;
    }
    _selectedIndexPath = selectedIndexPath;
    UITableViewCell *cell = [self cellForRowAtIndexPath:selectedIndexPath];
    _tempView = [self jx_snapshotViewWithInputView:cell];
    if (_drawMovalbeCellBlock) {
        //将_tempView通过block让使用者自定义
        _drawMovalbeCellBlock(_tempView);
    }else {
        //配置默认样式
        _tempView.layer.shadowColor = [UIColor grayColor].CGColor;
        _tempView.layer.masksToBounds = NO;
        _tempView.layer.cornerRadius = 0;
        _tempView.layer.shadowOffset = CGSizeMake(-5, 0);
        _tempView.layer.shadowOpacity = 0.4;
        _tempView.layer.shadowRadius = 5;
    }
    _tempView.frame = cell.frame;
    [self addSubview:_tempView];
    //隐藏cell
    cell.hidden = YES;
    [UIView animateWithDuration:kJXMovableCellAnimationTime animations:^{
        _tempView.center = CGPointMake(_tempView.center.x, point.y);
    }];
}

- (void)jx_gestureChanged:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:point];
    if (currentIndexPath && ![_selectedIndexPath isEqual:currentIndexPath]) {
        //交换数据源和cell
        [self jx_updateDataSourceAndCellFromIndexPath:_selectedIndexPath toIndexPath:currentIndexPath];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didMoveCellFromIndexPath:toIndexPath:)]) {
            [self.delegate tableView:self didMoveCellFromIndexPath:_selectedIndexPath toIndexPath:currentIndexPath];
        }
        _selectedIndexPath = currentIndexPath;
    }
    //让截图跟随手势
    _tempView.center = CGPointMake(_tempView.center.x, point.y);
}

- (void)jx_gestureEndedOrCancelled:(UILongPressGestureRecognizer *)gesture
{
    if (_canEdgeScroll) {
        [self jx_stopEdgeScroll];
    }
    //返回交换后的数据源
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:newDataSourceArrayAfterMove:)]) {
        [self.dataSource tableView:self newDataSourceArrayAfterMove:_tempDataSource.copy];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:endMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self endMoveCellAtIndexPath:_selectedIndexPath];
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:_selectedIndexPath];
    [UIView animateWithDuration:kJXMovableCellAnimationTime animations:^{
        _tempView.frame = cell.frame;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [_tempView removeFromSuperview];
        _tempView = nil;
    }];
}

#pragma mark Private action

- (UIView *)jx_snapshotViewWithInputView:(UIView *)inputView
{
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    return snapshot;
}

- (void)jx_updateDataSourceAndCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([self numberOfSections] == 1) {
        //只有一组
        [_tempDataSource exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        //交换cell
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }else {
        //有多组
        id fromData = _tempDataSource[fromIndexPath.section][fromIndexPath.row];
        id toData = _tempDataSource[toIndexPath.section][toIndexPath.row];
        NSMutableArray *fromArray = [_tempDataSource[fromIndexPath.section] mutableCopy];
        NSMutableArray *toArray = [_tempDataSource[toIndexPath.section] mutableCopy];
        [fromArray replaceObjectAtIndex:fromIndexPath.row withObject:toData];
        [toArray replaceObjectAtIndex:toIndexPath.row withObject:fromData];
        [_tempDataSource replaceObjectAtIndex:fromIndexPath.section withObject:fromArray];
        [_tempDataSource replaceObjectAtIndex:toIndexPath.section withObject:toArray];
        //交换cell
        [self beginUpdates];
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
        [self endUpdates];
    }
}

#pragma mark EdgeScroll

- (void)jx_startEdgeScroll
{
    _edgeScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(jx_processEdgeScroll)];
    [_edgeScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)jx_processEdgeScroll
{
    [self jx_gestureChanged:_gesture];
    CGFloat minOffsetY = self.contentOffset.y + _edgeScrollRange;
    CGFloat maxOffsetY = self.contentOffset.y + self.bounds.size.height - _edgeScrollRange;
    CGPoint touchPoint = _tempView.center;
    //处理上下达到极限之后不再滚动tableView，其中处理了滚动到最边缘的时候，当前处于edgeScrollRange内，但是tableView还未显示完，需要显示完tableView才停止滚动
    if (touchPoint.y < _edgeScrollRange) {
        if (self.contentOffset.y <= 0) {
            return;
        }else {
            if (self.contentOffset.y - 1 < 0) {
                return;
            }
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 1) animated:NO];
            _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y - 1);
        }
    }
    if (touchPoint.y > self.contentSize.height - _edgeScrollRange) {
        if (self.contentOffset.y >= self.contentSize.height - self.bounds.size.height) {
            return;
        }else {
            if (self.contentOffset.y + 1 > self.contentSize.height - self.bounds.size.height) {
                return;
            }
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 1) animated:NO];
            _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y + 1);
        }
    }
    //处理滚动
    CGFloat maxMoveDistance = 20;
    if (touchPoint.y < minOffsetY) {
        //cell在往上移动
        CGFloat moveDistance = (minOffsetY - touchPoint.y)/_edgeScrollRange*maxMoveDistance;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - moveDistance) animated:NO];
        _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y - moveDistance);
    }else if (touchPoint.y > maxOffsetY) {
        //cell在往下移动
        CGFloat moveDistance = (touchPoint.y - maxOffsetY)/_edgeScrollRange*maxMoveDistance;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + moveDistance) animated:NO];
        _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y + moveDistance);
    }
}

- (void)jx_stopEdgeScroll
{
    if (_edgeScrollTimer) {
        [_edgeScrollTimer invalidate];
        _edgeScrollTimer = nil;
    }
}

@end
