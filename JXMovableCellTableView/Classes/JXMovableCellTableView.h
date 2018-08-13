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
 */
- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView;

@end

@protocol JXMovableCellTableViewDelegate <UITableViewDelegate>
@optional
/**
 *  The cell that will start moving the indexPath location
 */
- (void)tableView:(JXMovableCellTableView *)tableView willMoveCellAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  Move cell `fromIndexPath` to `toIndexPath` completed
 */
- (void)tableView:(JXMovableCellTableView *)tableView didMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
/**
 *  Move cell ended
 */
- (void)tableView:(JXMovableCellTableView *)tableView endMoveCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  The user tries to move a cell that is not allowed to move. You can make some prompts to inform the user.
 */
- (void)tableView:(JXMovableCellTableView *)tableView tryMoveUnmovableCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Customize the screenshot style of the movable cell
 */
- (void)tableView:(JXMovableCellTableView *)tableView customizeMovalbeCell:(UIImageView *)movableCellsnapshot;

/**
 *  Custom start moving cell animation
 */
- (void)tableView:(JXMovableCellTableView *)tableView customizeStartMovingAnimation:(UIImageView *)movableCellsnapshot fingerPoint:(CGPoint)fingerPoint;

@end

@interface JXMovableCellTableView : UITableView

@property (nonatomic, weak) id<JXMovableCellTableViewDataSource> dataSource;
@property (nonatomic, weak) id<JXMovableCellTableViewDelegate> delegate;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;
/**
 *  Whether to allow dragging to the edge of the screen, turn on edge scrolling, default YES
 */
@property (nonatomic, assign) BOOL canEdgeScroll;

/**
 *  Edge scroll trigger range, default 150, the faster the edge is closer to the edge
 */
@property (nonatomic, assign) CGFloat edgeScrollTriggerRange;

/**
 *  When the CADisplayLink callback, self.contentOffsetY can scroll max speed, default 20. the faster the edge closer
 */
@property (nonatomic, assign) CGFloat maxScrollSpeedPerFrame;

@end
