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
@property (nonatomic, strong) NSMutableArray <NSMutableArray *> *tempDataSource;
@property (nonatomic, strong) CADisplayLink *edgeScrollLink;
@property (nonatomic, assign) CGFloat currentScrollSpeedPerFrame;
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
        self.rowHeight = 0;
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
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
    _edgeScrollTriggerRange = 150.f;
    _maxScrollSpeedPerFrame = 20;
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
            self.snapshot.center = CGPointMake(_snapshot.center.x, point.y);
        }];
    }
}

- (void)jx_gestureChanged:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    point = CGPointMake(_snapshot.center.x, [self limitSnapshotCenterY:point.y]);
    //Let the screenshot follow the gesture
    _snapshot.center = point;

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
        self.snapshot.transform = CGAffineTransformIdentity;
        self.snapshot.frame = cell.frame;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
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


        if (@available(iOS 11.0, *)) {
            if (_currentScrollSpeedPerFrame > 10) {
                [self reloadRowsAtIndexPaths:@[fromIndexPath, toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }else {
                [self beginUpdates];
                [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
                [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                [self endUpdates];
            }
        }else {
            [self beginUpdates];
            [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
            [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
            [self endUpdates];
        }
    }
}

- (CGFloat)limitSnapshotCenterY:(CGFloat)targetY
{
    CGFloat minValue = _snapshot.bounds.size.height/2.0 + self.contentOffset.y;
    CGFloat maxValue = self.contentOffset.y + self.bounds.size.height - _snapshot.bounds.size.height/2.0;
    return MIN(maxValue, MAX(minValue, targetY));
}

- (CGFloat)limitContentOffsetY:(CGFloat)targetOffsetY {
    CGFloat minContentOffsetY;
    if (@available(iOS 11.0, *)) {
        minContentOffsetY = -self.adjustedContentInset.top;
    } else {
        minContentOffsetY = -self.contentInset.top;
    }

    CGFloat maxContentOffsetY = minContentOffsetY;
    CGFloat contentSizeHeight = self.contentSize.height;
    if (@available(iOS 11.0, *)) {
        contentSizeHeight += self.adjustedContentInset.top + self.adjustedContentInset.bottom;
    } else {
        contentSizeHeight += self.contentInset.top + self.contentInset.bottom;
    }
    if (contentSizeHeight > self.bounds.size.height) {
        maxContentOffsetY += contentSizeHeight - self.bounds.size.height;
    }
    return MIN(maxContentOffsetY, MAX(minContentOffsetY, targetOffsetY));
}

#pragma mark EdgeScroll

- (void)jx_startEdgeScroll
{
    _edgeScrollLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(jx_processEdgeScroll)];
    [_edgeScrollLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)jx_processEdgeScroll
{
    CGFloat minOffsetY = self.contentOffset.y + _edgeScrollTriggerRange;
    CGFloat maxOffsetY = self.contentOffset.y + self.bounds.size.height - _edgeScrollTriggerRange;
    CGPoint touchPoint = _snapshot.center;

    if (touchPoint.y < minOffsetY) {
        //Cell is moving up
        CGFloat moveDistance = (minOffsetY - touchPoint.y)/_edgeScrollTriggerRange*_maxScrollSpeedPerFrame;
        _currentScrollSpeedPerFrame = moveDistance;
        self.contentOffset = CGPointMake(self.contentOffset.x, [self limitContentOffsetY:self.contentOffset.y - moveDistance]);
    }else if (touchPoint.y > maxOffsetY) {
        //Cell is moving down
        CGFloat moveDistance = (touchPoint.y - maxOffsetY)/_edgeScrollTriggerRange*_maxScrollSpeedPerFrame;
        _currentScrollSpeedPerFrame = moveDistance;
        self.contentOffset = CGPointMake(self.contentOffset.x, [self limitContentOffsetY:self.contentOffset.y + moveDistance]);
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];

    [self jx_gestureChanged:_longPressGesture];
}

- (void)jx_stopEdgeScroll
{
    _currentScrollSpeedPerFrame = 0;
    if (_edgeScrollLink) {
        [_edgeScrollLink invalidate];
        _edgeScrollLink = nil;
    }
}

@end
