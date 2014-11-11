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
        self.task = task;
        self.delegate = delegate;
    }
    return self;
}

- (void)getRequestWithURL:(NSString *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setValue:[RequestHandler userAgent] forHTTPHeaderField:@"User-Agent"];
    if ([NSURLConnection canHandleRequest:request]) {
        [self requestWithRequest:request];
    } else {
        [self mainThreadCode:504 message:@"Can't Handle Request"];
    }
}

- (void)postRequestWithURL:(NSString *)url postData:(NSData *)postData {
    NSString *urlString = [NSString stringWithFormat:@"%@", url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
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
            if (code == 400)
                [self mainThreadCode:code message:@"Request could not be understood by server."];
            else if (code == 404)
                [self mainThreadCode:code message:@"Resource could not be found."];
            else if (code == 500)
                [self mainThreadCode:code message:@"Internal Server Error."];
            else if (code == 503)
                [self mainThreadCode:code message:@"Request has timed out."];
            else if (code == 1003)
                [self mainThreadCode:code message:@"A server with the specified hostname could not be found."];
            else if (code == 1009)
                [self mainThreadCode:code message:@"Connection appears to be offline."];
            else
                [self mainThreadData:data];
        }
        else if (error != nil && error.code == NSURLErrorTimedOut)
            [self mainThreadCode:503 message:@"Request has timed out."];
        else if (error != nil)
            [self mainThreadCode:ABS([error code]) message:[error localizedDescription]];
        else
            [self mainThreadCode:9002 message:@"Request failed for unknown reason."];
    }];
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

- (void)mainThreadCode:(NSInteger)code message:(NSString *)message {
    if ([NSThread isMainThread])
        [self checkDelegateHandleError:code message:message];
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self checkDelegateHandleError:code message:message];
        });
    }
}

- (void)receivedData:(NSData *)data {
    [self setActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(handleResponse:data:)]) {
        [self.delegate handleResponse:self data:data];
    }
}

- (void)checkDelegateHandleError:(NSInteger)code message:(NSString *)message {
    [self setActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(handleError:code:message:)]) {
        [self.delegate handleError:self code:code message:message];
    }
    else {
        [self handleErrorCode:code message:message];
    }
}

- (void)handleErrorCode:(NSInteger)code message:(NSString *)message {
    if (code == 400)
        [self alertWithTitle:@"Bad Request" message:[NSString stringWithFormat:@"Error Processing Request: %@", message] code:code];
    else if (code == 404)
        [self alertWithTitle:@"Resource Error" message:[NSString stringWithFormat:@"Error Loading Resource: %@", message] code:code];
    else if (code == 500)
        [self alertWithTitle:@"Server Error" message:[NSString stringWithFormat:@"Error Processing Request: %@", message] code:code];
    else if (code == 503)
        [self alertWithTitle:@"Timeout Error" message:[NSString stringWithFormat:@"Error Loading Resource: %@", message] code:code];
    else if (code == 1003)
        [self alertWithTitle:@"Resource Error" message:[NSString stringWithFormat:@"Error Loading Resource: %@",message] code:code];
    else if (code == 1008 || code == 1009)
        [self alertWithTitle:@"Connection Error" message:[NSString stringWithFormat:@"Error Connecting: %@", message] code:code];
    else
        [self alertWithTitle:@"Error" message:message code:code];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message code:(NSInteger)code {
#if !EXTENSION
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@ (-%li)", message, (long)code] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
#endif
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
