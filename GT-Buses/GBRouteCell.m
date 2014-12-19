//
//  GBRouteCell.m
//  GT-Buses
//
//  Created by Alex Perez on 12/13/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRouteCell.h"

#import "GBColors.h"
#import "GBConstants.h"
#import "GBConstraintHelper.h"
#import "GBImage.h"

@implementation GBRouteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _titleLabel.font = [UIFont fontWithName:GBFontDefault size:17];
            [self addSubview:_titleLabel];
            
            _circleImageView = [[UIImageView alloc] init];
            _circleImageView.translatesAutoresizingMaskIntoConstraints = NO;
            _circleImageView.contentMode = UIViewContentModeCenter;
            [self addSubview:_circleImageView];
            
            NSMutableArray *constraints = [NSMutableArray new];
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_circleImageView horizontal:NO]];
            [constraints addObject:[GBConstraintHelper centerY:_titleLabel withView:self]];
            [constraints addObject:[GBConstraintHelper heightConstraint:_circleImageView height:kRouteImageViewSize]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_circleImageView(size)][_titleLabel]-40-|" options:0 metrics:@{@"size":@(kRouteImageViewSize)} views:NSDictionaryOfVariableBindings(_titleLabel, _circleImageView)]];
            [self addConstraints:constraints];
        } else {
            _titleLabel = self.textLabel;
        }
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [[UIColor appTintColor] colorWithAlphaComponent:.5];
        self.selectedBackgroundView = selectedView;
    }
    return self;
}

@end
