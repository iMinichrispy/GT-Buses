//
//  RequestHandler.m
//  HousePoints
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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:_cachePolicy];
    [request setValue:[RequestHandler userAgent] forHTTPHeaderField:@"User-Agent"];
    if ([NSURLConnection canHandleRequest:request]) {
        [self requestWithRequest:request];
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        [self mainThreadError:error];
    }
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
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSInteger code = [((NSHTTPURLResponse *)response) statusCode];
            if (code == 200)
                [self mainThreadData:data];
            else {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:nil];
                [self mainThreadError:error];
            }
        }
        else if (error != nil) {
            [self mainThreadError:error];
        }
        else {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
            [self mainThreadError:error];
        }
    }];
}

- (void)handleError:(NSError *)error {
#if !EXTENSION
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
#endif
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

- (void)mainThreadError:(NSError *)error {
    if ([NSThread isMainThread])
        [self checkDelegateHandleError:error];
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self checkDelegateHandleError:error];
        });
    }
}

- (void)receivedData:(NSData *)data {
    [self setActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(handleResponse:data:)]) {
        [self.delegate handleResponse:self data:data];
    }
}

- (void)checkDelegateHandleError:(NSError *)error {
    [self setActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(handleError:error:)]) {
        [self.delegate handleError:self error:error];
    }
    else {
        [self handleError:error];
    }
}

+ (NSString *)userAgent {
    static NSString *userAgentString;
    if (!userAgentString) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleName = info[(NSString *)kCFBundleNameKey];
        NSString *version = info[@"CFBundleShortVersionString"];
        NSString *model = [[UIDevice currentDevice] model];
        NSString *systemName = [[UIDevice currentDevice] systemName];
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
        userAgentString = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", bundleName, version, model, systemName, systemVersion, localeIdentifier];
    }
    return userAgentString;
}

@end
