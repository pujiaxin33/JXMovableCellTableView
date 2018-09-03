# Overview

The custom tableView which can start moving the cell with a long press gesture.
The JXMovableCellTableView which added a `UILongPressGestureRecognizer`. when gesture started take a snapshot for cell which pressed.Then you can customize movable cell and start move animation.


[中文介绍](https://www.jianshu.com/p/ce382f9bc794)

# Check it out!

- **Edge scroll**

![EdgeScroll](https://github.com/pujiaxin33/JXMovableCellTableView/blob/master/JXMovableCellTableView/Gifs/EdgeScroll.gif)

- **Neon light**

![Neonlight](https://github.com/pujiaxin33/JXMovableCellTableView/blob/master/JXMovableCellTableView/Gifs/NeonLight.gif)

- **Breath**

![Breath](https://github.com/pujiaxin33/JXMovableCellTableView/blob/master/JXMovableCellTableView/Gifs/Breath.gif)


# Features
- Just need a long press gesture can start moving cell. Don't need call system api `[tableView setEditing:YES animated:YES];`.
- Highly customizing the cell style being moved.
- Highly customizing start move cell animation.
- Support to move to the edge of the screen to scroll the tableview.

# Usage
 
- **`canEdgeScroll`**

  Whether to allow dragging to the edge of the screen, turn on edge scrolling.default YES.

- **`edgeScrollRange`**

  The edge scrolls the trigger range, and the closer to the edge, the faster the speed. The default is 150.
  
- **`JXMovableCellTableViewDelegate`**
  
```
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
```

- **`JXMovableCellTableViewDataSource`**

```
/**
 *  Get the data source array of the tableView, each time you start the call to get the latest data source.
 *  The array in the data source must be a mutable array, otherwise it cannot be exchanged
 *  The format of the data source:@[@[sectionOneArray].mutableCopy, @[sectionTwoArray].mutableCopy, ....].mutableCopy
 *  Even if there is only one section, the outermost layer needs to be wrapped in an array, such as:@[@[sectionOneArray].mutableCopy].mutableCopy
 */
- (NSMutableArray *)dataSourceArrayInTableView:(JXMovableCellTableView *)tableView;
```

# Installation

## Manual

Download git reposity, decompress zip, drag JXMovableCellTableView.h&.m into your project.

## CocoaPods

```ruby
target '<Your Target Name>' do
    pod 'JXMovableCellTableView'
end
```
You should run `pod repo udpate` before `pod install`

