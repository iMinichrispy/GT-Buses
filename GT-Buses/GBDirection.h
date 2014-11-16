//
//  GBDirection.h
//  GT-Buses
//
//  Created by Alex Perez on 11/16/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@class GBDirection;
@interface NSDictionary (GBDirection)

- (GBDirection *)toDirection;

@end

@interface GBDirection : NSObject

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag;
- (NSDictionary *)toDictionary;

@end
