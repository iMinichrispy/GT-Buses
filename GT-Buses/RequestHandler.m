//
//  RequestHandler.m
//  RequestHandler
//
//  Created by Alex Perez on 1/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "RequestHandler.h"

@implementation RequestHandler

- (instancetype)initWithTask:(NSString *)task delegate:(id<RequestHandlerDelegate>)delegate {
    self = [super init];
    if (self) {
        _task = task;
        _delegate = delegate;
        _cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }
    return self;
}

- (void)getRequestWithURL:(NSString *)url {
    NSLog(@"GET [%@]: %@", _task, url);
#warning what happens if url is nil?
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:_cachePolicy];
    [request setValue:[RequestHandler userAgent] forHTTPHeaderField:@"User-Agent"];
    [self requestWithRequest:request];
}

- (void)postRequestWithURL:(NSString *)url postData:(NSData *)postData {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:_cachePolicy];
    [request setValue:[RequestHandler userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postData];
    [self requestWithRequest:request];
}

- (void)setActivityIndicatorVisible:(BOOL)hidden {
#if !EXTENSION
    [UIApplication sharedApplication].networkActivityIndicatorVisible = hidden;
#endif
}

- (void)requestWithRequest:(NSURLRequest *)request {
    [self setActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSInteger code = [((NSHTTPURLResponse *)response) statusCode];
            if (code == 200)
                [self receivedData:data];
            else {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:nil];
                [self handleError:error];
            }
        }
        else if (error != nil) {
            [self handleError:error];
        }
        else {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
            [self handleError:error];
        }
    }];
}

- (void)receivedData:(NSData *)data {
    [self setActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(handleResponse:data:)]) {
        [self.delegate handleResponse:self data:data];
    }
}
- (void)handleError:(NSError *)error {
    [self setActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(handleError:error:)]) {
        [self.delegate handleError:self error:error];
    }
    else {
#if !EXTENSION
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
#endif
    }
}

+ (NSString *)userAgent {
    static NSString *userAgent;
    if (!userAgent) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleName = info[(NSString *)kCFBundleNameKey];
        NSString *version = info[@"CFBundleShortVersionString"];
        UIDevice *device = [UIDevice currentDevice];
        NSString *model = [device model];
        NSString *systemName = [device systemName];
        NSString *systemVersion = [device systemVersion];
        NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
        userAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", bundleName, version, model, systemName, systemVersion, localeIdentifier];
    }
    return userAgent;
}

@end
