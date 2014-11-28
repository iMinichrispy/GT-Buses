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
#import "GBConfig.h"

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
        BOOL showsArrivalTime = [[GBConfig sharedInstance] showsArrivalTime];
        
        NSMutableString *predictionsString;
        if (showsArrivalTime) {
            predictionsString = [NSMutableString stringWithString:NSLocalizedString(@"PREDICTIONS_AT", @"At x, y, ...")];
        } else {
            predictionsString = [NSMutableString stringWithString:NSLocalizedString(@"PREDICTIONS_IN", @"In x, y, ...")];
        }
        
        NSDictionary *lastPredication = [predictions lastObject];
        for (NSDictionary *prediction in predictions) {
            if (showsArrivalTime) {
                NSInteger seconds = [prediction[@"seconds"] intValue];
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
                
                NSDateFormatter *formatter = [self predictionDateFormatter];
                NSString *formattedPrecition = [[formatter stringFromDate:date] lowercaseString];
                
                [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", formattedPrecition];
                
            } else {
                [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
            }
        }
        return predictionsString;
    }
    
    return NSLocalizedString(@"NO_PREDICTIONS", @"No predictions for stop");
}

+ (NSDateFormatter *)predictionDateFormatter {
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"h:mma"];
    }
    return formatter;
}

@end
