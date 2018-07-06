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
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) CGFloat gestureMinimumPressDuration;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *snapshot;
@property (nonatomic, strong) NSMutableArray *tempDataSource;
@property (nonatomic, strong) CADisplayLink *edgeScrollTimer;
@end

@implementation JXMovableCellTableView

@dynamic dataSource, delegate;

- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
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

#pragma mark Gesture

- (void)jx_addGesture
{
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(jx_processGesture:)];
    _longPressGesture.minimumPressDuration = _gestureMinimumPressDuration;
    [self addGestureRecognizer:_longPressGesture];
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
    UITableViewCell *cell = [self cellForRowAtIndexPath:selectedIndexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        if (![self.dataSource tableView:self canMoveRowAtIndexPath:selectedIndexPath]) {
            //It is not allowed to move the cell, then shake it to prompt the user.
            CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            shakeAnimation.duration = 0.25;
            shakeAnimation.values = @[@(-20), @(20), @(-10), @(10), @(0)];
            [cell.layer addAnimation:shakeAnimation forKey:@"shake"];

            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:tryMoveUnmovableCellAtIndexPath:)]) {
                [self.delegate tableView:self tryMoveUnmovableCellAtIndexPath:selectedIndexPath];
            }
            return;
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self willMoveCellAtIndexPath:selectedIndexPath];
    }
    if (_canEdgeScroll) {
        [self jx_startEdgeScroll];
    }
    //Get a data source every time you move
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceArrayInTableView:)]) {
        _tempDataSource = [self.dataSource dataSourceArrayInTableView:self];
    }
    _selectedIndexPath = selectedIndexPath;

    _snapshot = [self jx_snapshotViewWithInputView:cell];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:customizeMovalbeCell:)]) {
        [self.delegate tableView:self customizeMovalbeCell:_snapshot];
    }else {
        _snapshot.layer.shadowColor = [UIColor grayColor].CGColor;
        _snapshot.layer.masksToBounds = NO;
        _snapshot.layer.cornerRadius = 0;
        _snapshot.layer.shadowOffset = CGSizeMake(-5, 0);
        _snapshot.layer.shadowOpacity = 0.4;
        _snapshot.layer.shadowRadius = 5;
    }
    _snapshot.frame = cell.frame;
    [self addSubview:_snapshot];

    cell.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:customizeStartMovingAnimation:fingerPoint:)]) {
        [self.delegate tableView:self customizeStartMovingAnimation:_snapshot fingerPoint:point];
    }else {
        [UIView animateWithDuration:kJXMovableCellAnimationTime animations:^{
            _snapshot.center = CGPointMake(_snapshot.center.x, point.y);
        }];
    }
}

- (void)jx_gestureChanged:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    //Let the screenshot follow the gesture
    _snapshot.center = CGPointMake(_snapshot.center.x, [self snapshotYToFitTargetY:point.y]);

    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:point];
    if (!currentIndexPath) {
        return;
    }
    UITableViewCell *selectedCell = [self cellForRowAtIndexPath:_selectedIndexPath];
    selectedCell.hidden = YES;

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        if (![self.dataSource tableView:self canMoveRowAtIndexPath:currentIndexPath]) {
            return;
        }
    }

    if (currentIndexPath && ![_selectedIndexPath isEqual:currentIndexPath]) {
        //Exchange data source and cell
        [self jx_updateDataSourceAndCellFromIndexPath:_selectedIndexPath toIndexPath:currentIndexPath];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didMoveCellFromIndexPath:toIndexPath:)]) {
            [self.delegate tableView:self didMoveCellFromIndexPath:_selectedIndexPath toIndexPath:currentIndexPath];
        }
        _selectedIndexPath = currentIndexPath;
    }
}

- (void)jx_gestureEndedOrCancelled:(UILongPressGestureRecognizer *)gesture
{
    if (_canEdgeScroll) {
        [self jx_stopEdgeScroll];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:endMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self endMoveCellAtIndexPath:_selectedIndexPath];
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:_selectedIndexPath];
    [UIView animateWithDuration:kJXMovableCellAnimationTime animations:^{
        _snapshot.transform = CGAffineTransformIdentity;
        _snapshot.frame = cell.frame;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [_snapshot removeFromSuperview];
        _snapshot = nil;
    }];
}

#pragma mark Private action

- (UIImageView *)jx_snapshotViewWithInputView:(UIView *)inputView
{
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *snapshot = [[UIImageView alloc] initWithImage:image];
    return snapshot;
}

- (void)jx_updateDataSourceAndCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([self numberOfSections] == 1) {
        //only one section
        [_tempDataSource[fromIndexPath.section] exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }else {
        //multiple sections
        id fromData = _tempDataSource[fromIndexPath.section][fromIndexPath.row];
        id toData = _tempDataSource[toIndexPath.section][toIndexPath.row];
        NSMutableArray *fromArray = _tempDataSource[fromIndexPath.section];
        NSMutableArray *toArray = _tempDataSource[toIndexPath.section];
        [fromArray replaceObjectAtIndex:fromIndexPath.row withObject:toData];
        [toArray replaceObjectAtIndex:toIndexPath.row withObject:fromData];
        [_tempDataSource replaceObjectAtIndex:toIndexPath.section withObject:toArray];

        [self beginUpdates];
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
        [self endUpdates];
    }
}

- (CGFloat)snapshotYToFitTargetY:(CGFloat)targetY
{
    CGFloat minValue = _snapshot.bounds.size.height/2.0;
    CGFloat maxValue = self.contentSize.height - minValue;
    return MIN(maxValue, MAX(minValue, targetY));
}

#pragma mark EdgeScroll

- (void)jx_startEdgeScroll
{
    _edgeScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(jx_processEdgeScroll)];
    [_edgeScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)jx_processEdgeScroll
{
    [self jx_gestureChanged:_longPressGesture];
    CGFloat minOffsetY = self.contentOffset.y + _edgeScrollRange;
    CGFloat maxOffsetY = self.contentOffset.y + self.bounds.size.height - _edgeScrollRange;
    CGPoint touchPoint = _snapshot.center;
    //After the processing reaches the limit, the tableView is no longer scrolled. When the scroll to the edge is processed, it is currently in the edgeScrollRange, but the tableView has not been displayed yet. You need to display the tableView to stop scrolling.
    if (touchPoint.y < _edgeScrollRange) {
        if (self.contentOffset.y <= 0) {
            return;
        }else {
            if (self.contentOffset.y - 1 < 0) {
                return;
            }
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 1) animated:NO];
            _snapshot.center = CGPointMake(_snapshot.center.x, [self snapshotYToFitTargetY:_snapshot.center.y - 1]);
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
            _snapshot.center = CGPointMake(_snapshot.center.x, [self snapshotYToFitTargetY:_snapshot.center.y + 1]);
        }
    }

    CGFloat maxMoveDistance = 20;
    if (touchPoint.y < minOffsetY) {
        //Cell is moving up
        CGFloat moveDistance = (minOffsetY - touchPoint.y)/_edgeScrollRange*maxMoveDistance;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - moveDistance) animated:NO];
        _snapshot.center = CGPointMake(_snapshot.center.x, [self snapshotYToFitTargetY:_snapshot.center.y - moveDistance]);
    }else if (touchPoint.y > maxOffsetY) {
        //Cell is moving down
        CGFloat moveDistance = (touchPoint.y - maxOffsetY)/_edgeScrollRange*maxMoveDistance;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + moveDistance) animated:NO];
        _snapshot.center = CGPointMake(_snapshot.center.x, [self snapshotYToFitTargetY:_snapshot.center.y + moveDistance]);
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
