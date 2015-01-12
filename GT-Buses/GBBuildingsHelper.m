//
//  GBBuildingsHelper.m
//  GT-Buses
//
//  Created by Alex Perez on 1/7/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

#import "GBBuildingsHelper.h"

#import "GBConstants.h"
#import "GBConfig.h"

@implementation GBBuildingsHelper

+ (NSString *)documentsDirectoryPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSMutableDictionary *)fileNamesDictionary {
    NSMutableDictionary *fileNames = [[[NSUserDefaults standardUserDefaults] objectForKey:GBUserDefaultsBuildingsFileNamesKey] mutableCopy];
    if (!fileNames) {
        fileNames = [NSMutableDictionary new];
    }
    return fileNames;
}

+ (NSArray *)savedBuildingsForAgency:(NSString *)agency ignoreExpired:(BOOL)ignoreExpired {
    NSDictionary *fileNames = [self fileNamesDictionary];
    NSString *fileName = fileNames[agency];
    if ([fileName length]) {
        NSArray *components = [[fileName stringByDeletingPathExtension] componentsSeparatedByString:@"-"];
        NSInteger savedTimestamp = [[components lastObject] intValue];
        NSInteger currentTimestamp = [[NSDate date] timeIntervalSince1970];
        
        // If it's been more than a week since the buildings were retrieved, fetch a new copy
        if (!ignoreExpired || currentTimestamp - savedTimestamp < 604800) {
            NSString *path = [[self documentsDirectoryPath] stringByAppendingPathComponent:fileName];
            NSArray *buildings = [[NSArray alloc] initWithContentsOfFile:path];
            return buildings;
        }
    }
    return nil;
}

+ (void)setBuildings:(NSArray *)buildings forAgency:(NSString *)agency {
    NSMutableDictionary *fileNames = [self fileNamesDictionary];
    NSString *path = [self documentsDirectoryPath];
    
    NSString *currentFileName = fileNames[agency];
    if ([currentFileName length]) {
        [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:currentFileName] error:nil];
    }
    
    // Save as a file with a timestamp, so we know when we should fetch a new one.
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"Buildings-%@-%li.plist", agency, (long)timestamp];
    [buildings writeToFile:[path stringByAppendingPathComponent:fileName] atomically:YES];
    fileNames[agency] = fileName;
    
    [[NSUserDefaults standardUserDefaults] setObject:fileNames forKey:GBUserDefaultsBuildingsFileNamesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
