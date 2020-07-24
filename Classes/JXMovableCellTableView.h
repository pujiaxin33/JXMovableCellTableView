//
//  JXMovableCellTableView.h
//  JXMovableCellTableView
//
//  Created by jiaxin on 16/2/15.
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXMovableCellTableView;

@protocol JXMovableCellTableViewDataSource <UITableViewDataSource>

@required
/**
 *  Get the data source array of the tableView, each time you start the call to get the latest data source.
 *  The array in the data source must be a mutable array, otherwise it cannot be exchanged
 *  The format of the data source:@[@[sectionOneArray].mutableCopy, @[sectionTwoArray].mutableCopy, ....].mutableCopy
 *  Even if there is only one section, the outermost layer needs to be wrapped in an array, such as:@[@[sectionOneArray].mutableCopy].mutableCopy
 *  数据源约束: 多组数组嵌套且为可变数组
 */
- (NSMutableArray <NSMutableArray *> *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView;

@optional
///返回自定义截图的部分
- (UIView *)snapshotViewWithCell:(UITableViewCell *)cell;

@end

@protocol JXMovableCellTableViewDelegate <UITableViewDelegate>
@optional
/**
 *  The cell that will start moving the indexPath location
 *  长按拖拽cell将要开始移动
 */
- (void)tableView:(JXMovableCellTableView *)tableView willMoveCellAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  Move cell `fromIndexPath` to `toIndexPath` completed
 *  移动cell换了位置下标
 */
- (void)tableView:(JXMovableCellTableView *)tableView didMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
/**
 *  Move cell ended
 *  移动cell结束
 */
- (void)tableView:(JXMovableCellTableView *)tableView endMoveCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  The user tries to move a cell that is not allowed to move. You can make some prompts to inform the user.
 *  尝试长按拖拽不能移动的cell 这个代理方法可以加个toast或者其他处理 与设置`canHintWhenCannotMove`不冲突
 */
- (void)tableView:(JXMovableCellTableView *)tableView tryMoveUnmovableCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Customize the screenshot style of the movable cell
 *  自定义移动的cell截图的样式 加阴影啥的
 */
- (void)tableView:(JXMovableCellTableView *)tableView customizeMovalbeCell:(UIImageView *)movableCellsnapshot;

/**
 *  Custom start moving cell animation
 *  自定义cell拖拽移动的动画
 */
- (void)tableView:(JXMovableCellTableView *)tableView customizeStartMovingAnimation:(UIImageView *)movableCellsnapshot fingerPoint:(CGPoint)fingerPoint;

@end

@interface JXMovableCellTableView : UITableView

@property (nonatomic, weak) id<JXMovableCellTableViewDataSource> dataSource;
@property (nonatomic, weak) id<JXMovableCellTableViewDelegate> delegate;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;
/**
 *  Whether to allow dragging to the edge of the screen, turn on edge scrolling, default YES
 *  是否允许拖动到屏幕边缘，启用边缘滚动，默认为YES
 */
@property (nonatomic, assign) BOOL canEdgeScroll;

/**
 *  Edge scroll trigger range, default 150, the faster the edge is closer to the edge
 *  边缘滚动触发范围，默认为150，越靠近边缘滚得越快
 */
@property (nonatomic, assign) CGFloat edgeScrollTriggerRange;

/**
 *  When the CADisplayLink callback, self.contentOffsetY can scroll max speed, default 20. the faster the edge closer
 *  当CADisplayLink回调时，self.contentOffsetY可以滚动的最大速度，默认为20 帧/s。
 */
@property (nonatomic, assign) CGFloat maxScrollSpeedPerFrame;


/// 当cell不允许被移动的时候，长按时是否提示。默认为YES。
@property (nonatomic, assign) BOOL canHintWhenCannotMove;

@end
