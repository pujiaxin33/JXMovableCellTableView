//
//  JXTableViewCell.m
//  JXMovableCellTableView
//
//  Created by VM on 2020/7/22.
//  Copyright © 2020 jiaxin. All rights reserved.
//

#import "JXTableViewCell.h"

@implementation JXTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
