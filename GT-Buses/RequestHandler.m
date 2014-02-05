//
//  RequestHandler.m
//  HousePoints
//
//  Created by Alex Perez on 1/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "RequestHandler.h"
#define API_URL @"http://m.cip.gatech.edu/widget/buses/content/api"
#define BUS_LOCATIONS_URL @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=vehicleLocations&r="
//#define BUS_LOCATIONS_URL @"http://localhost:5000/bus"
#define BUS_PREDICTIONS_URL @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=predictionsForMultiStops&r="
#define ROUTE_CONFIG_URL @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=routeConfig"

@implementation RequestHandler
@synthesize delegate;
@synthesize task;

- (id)initWithDelegate:(id)requestDelegate task:(NSString *)newTask {
    self = [super init];
    if (self) {
        self.delegate = requestDelegate;
        self.task = newTask;
    }
    return self;
}

+ (NSString *)userAgent {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [info objectForKey:@"CFBundleDisplayName"];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    return [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", bundleName, version, model, systemName, systemVersion, localeIdentifier];
}

- (void)routeConfig {
    [self getRequestWithURL:ROUTE_CONFIG_URL];
}

- (void)positionForBus:(NSString *)tag {
    [self getRequestWithURL:[NSString stringWithFormat:@"%@%@",BUS_LOCATIONS_URL,tag]];
//    [self getRequestWithURL:[NSString stringWithFormat:@"%@",BUS_LOCATIONS_URL]];
}

- (void)predictionsForBus:(NSString *)tag {
    [self getRequestWithURL:[NSString stringWithFormat:@"%@%@",BUS_PREDICTIONS_URL,tag]];
}

- (void)getRequestWithURL:(NSString *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setValue:[RequestHandler userAgent] forHTTPHeaderField:@"User-Agent"];
    [self requestWithRequest:request];
}

- (void)postRequestWithPath:(NSString *)path postData:(NSData *)postData {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",API_URL,path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setValue:[RequestHandler userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postData];
    [self requestWithRequest:request];
}

- (void)requestWithRequest:(NSURLRequest *)request {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if ([data length] > 0 && error == nil) {
                 if ([((NSHTTPURLResponse *)response) statusCode] == 400)
                     [self mainThreadCode:400 message:@"Request could not be understood by server."];
                 else if ([((NSHTTPURLResponse *)response) statusCode] == 404)
                     [self mainThreadCode:404 message:@"Resource could not be found."];
                 else if ([((NSHTTPURLResponse *)response) statusCode] == 500)
                     [self mainThreadCode:500 message:@"Internal Server Error."];
                 else if ([((NSHTTPURLResponse *)response) statusCode] == 503)
                     [self mainThreadCode:503 message:@"Request has timed out."];
                 else
                     [self mainThreadData:data];
             }
             else if (error != nil && error.code == NSURLErrorTimedOut)
                 [self mainThreadCode:503 message:@"Request has timed out."];
             else if (error != nil)
                 [self mainThreadCode:ABS((int)[error code]) message:[error description]];
             else
                 [self mainThreadCode:9002 message:@"Request failed for unknown reason."];
         }];
    }
    else {
        [self checkDelegateHandleError:3001 message:@"Error connecting to server. Please make sure you are connected to the Internet."];
    }
}

- (void)mainThreadData:(NSData *)data {
    if ([NSThread isMainThread])
        [self receivedData:data];
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self receivedData:data];
        });
    }
}

- (void)mainThreadCode:(int)code message:(NSString *)message {
    if ([NSThread isMainThread])
        [self checkDelegateHandleError:code message:message];
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self checkDelegateHandleError:code message:message];
        });
    }
}

- (void)receivedData:(NSData *)data {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [delegate handleResponse:self data:data];
}

- (void)checkDelegateHandleError:(int)code message:(NSString *)message {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([self.delegate respondsToSelector:@selector(handleError:code:message:)])
        [delegate handleError:self code:code message:message];
    else
        [self handleErrorCode:code message:message];
}

- (void)handleErrorCode:(int)code message:(NSString *)message {
    if (code == 400)
        [self alertWithTitle:@"Bad Request" message:[NSString stringWithFormat:@"Error Processing Request: %@", message] code:code];
    else if (code == 404)
        [self alertWithTitle:@"Resource Error" message:[NSString stringWithFormat:@"Error Loading Resource: %@", message] code:code];
    else if (code == 500)
        [self alertWithTitle:@"Server Error" message:[NSString stringWithFormat:@"Error Processing Request: %@",message] code:code];
    else if (code == 503)
        [self alertWithTitle:@"Timeout Error" message:[NSString stringWithFormat:@"Error Loading Resource: %@",message] code:code];
    else if (code == 3001)
        [self alertWithTitle:@"Connection Error" message:@"Error connecting to server. Please make sure you are connected to the Internet." code:3001];
    else
        [self alertWithTitle:@"Unknown Error" message:@"An unknown error occurred." code:9001];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message code:(int)code {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@ (-%i)",message, code] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

@end
