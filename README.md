# Overview

The custom tableView which can start moving the cell with a long press gesture.
The JXMovableCellTableView which added a `UILongPressGestureRecognizer`. when gesture started take a snapshot for cell which pressed.Then you can customize movable cell and start move animation.


[中文介绍](https://www.jianshu.com/p/ce382f9bc794)

# Check it out!
![EdgeScroll](https://note.youdao.com/yws/public/resource/bc2fe3d5a0d353e92e636d344ecbe43f/xmlnote/WEBRESOURCE76a83ee2b4738eea3c4409fb2b5b5b5f/2541)

# Features
- Just need a long press gesture can start moving cell. Don't need call system api `[tableView setEditing:YES animated:YES];`.
- Highly customizing the cell style being moved.
- Highly customizing start move cell animation.
- Support to move to the edge of the screen to scroll the tableview.

# Usage

- **`void(^drawMovalbeCellBlock)(UIView *movableCell)`**

  Customize by configuring the moveCell.
 
- **`canEdgeScroll`**

  Whether to allow dragging to the edge of the screen, turn on edge scrolling.default YES.

- **`edgeScrollRange`**

  The edge scrolls the trigger range, and the closer to the edge, the faster the speed. The default is 150.

# Installation
  - Download git reposity, decompress zip.
  - Drag JXMovableCellTableView files into your project.
