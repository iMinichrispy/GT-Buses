//
//  GBStop.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStop.h"

#import "GBRoute.h"
#import "GBDirection.h"

@implementation NSDictionary (GBStop)

- (GBStop *)toStop {
    GBRoute *route = [self[@"route"] toRoute];
    GBStop *stop = [[GBStop alloc] initWithRoute:route title:self[@"title"] tag:self[@"tag"]];
    stop.direction = [self[@"direction"] toDirection];
    return stop;
}

- (GBStop *)xmlToStop {
    GBStop *stop = [[GBStop alloc] initWithRoute:nil title:self[@"title"] tag:self[@"tag"]];
    stop.lat = [self[@"lat"] doubleValue];
    stop.lon = [self[@"lon"] doubleValue];
    return stop;
}

@end

@implementation GBStop

- (instancetype)initWithRoute:(GBRoute *)route title:(NSString *)title tag:(NSString *)tag {
    self = [super init];
    if (self) {
        _route = route;
        _title = title;
        _tag = tag;
        _favorite = NO;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{@"title":_title, @"tag":_tag, @"route":[_route toDictionary], @"direction":[_direction toDictionary]};
    return dictionary;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBStop title: %@, tag: %@, route: %@, coordinates: (%f, %f)>", _title, _tag, _route.tag, _lat, _lon];
}

+ (NSString *)predictionsStringForPredictions:(NSArray *)predictions {
    if ([predictions count]) {
        NSMutableString *predictionsString = [NSMutableString stringWithString:@"In "];
        NSDictionary *lastPredication = [predictions lastObject];
        for (NSDictionary *prediction in predictions) {
#if DEBUG
//            int totalSeconds = [prediction[@"seconds"] intValue];
//            double minutes = totalSeconds / 60;
//            double seconds = totalSeconds % 60;
//            NSString *time = [NSString stringWithFormat:@"%.f:%02.f", minutes, seconds];
//            [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", time];
            [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
#else
            [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
#endif
        }
        return predictionsString;
    }
    
    return @"No Predictions";
}

@end
