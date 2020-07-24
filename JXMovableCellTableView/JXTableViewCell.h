//
//  JXTableViewCell.h
//  JXMovableCellTableView
//
//  Created by VM on 2020/7/22.
//  Copyright © 2020 jiaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@end

NS_ASSUME_NONNULL_END
