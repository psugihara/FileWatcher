//
//  FileWatcher.m
//  GitSync
//
//  Created by Peter Sugihara on 1/4/11.
//  Copyright 2011 Peter Sugihara. All rights reserved.
//

#import "FileWatcher.h"

NSString *const FileWatcherFileDidChangeNotification = @"FileWatcherFileDidChangeNotification";

@interface FileWatcher()
- (void)startWatching;
- (void)checkForUpdates;
- (NSDate *)modificationDateForURL:(NSURL *)url;
- (NSURL *)urlFromBookmark:(NSData *)bookmark;
- (NSData *)bookmarkFromURL:(NSURL *)url;
@property (strong, nonatomic) NSRunLoop *runLoop;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableDictionary *fileModificationDates;
@end


@implementation FileWatcher
@synthesize delegate = _delegate;
@synthesize fileModificationDates = _fileModificationDates;
@synthesize runLoop = _runLoop;
@synthesize fileManager = _fileManager;

+ (id)sharedWatcher {
    static id sharedWatcher = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedWatcher = [[self alloc] init];
    });
    return sharedWatcher;
}

- (id)init {
    if ((self = [super init])) {
        self.fileManager = [[NSFileManager alloc] init];
        self.fileModificationDates = [[NSMutableDictionary alloc] init];
        [self startWatching];
    }
    
    return self;
}

- (void)watchFileAtURL:(NSURL *)url {
    NSData *bookmark = [self bookmarkFromURL:url];
    NSDate *modDate = [self modificationDateForURL:url];
    
    [self.fileModificationDates setObject:modDate forKey:bookmark];
}

- (void)stopWatchingFileAtURL:(NSURL *)url {
    [self.fileModificationDates removeObjectForKey:url];
}

- (NSDate *)modificationDateForURL:(NSURL *)URL {
    NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:[URL path] error:NULL];
    NSDate *modDate = [fileAttributes fileModificationDate];
    return modDate;
}

- (void)startWatching {
    NSTimeInterval latency = 0.5;
	NSTimer *timer = [NSTimer timerWithTimeInterval:latency
                                             target:self 
                                           selector:@selector(checkForUpdates) 
                                           userInfo:nil 
                                            repeats:YES];
	self.runLoop = [NSRunLoop currentRunLoop];
	[self.runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)checkForUpdates {
    for(NSData *bookmark in [self.fileModificationDates allKeys]) {
        @autoreleasepool {
            NSURL *watchedURL = [self urlFromBookmark:bookmark];
            NSDate *modDate = [self modificationDateForURL:watchedURL];
            // Fires YES the first time it's called after the program turns on.
            // Not sure why, don't really care right now. [Sorry !];
            if ([modDate compare:[self.fileModificationDates objectForKey:bookmark]] == NSOrderedDescending) {
                [self.fileModificationDates setObject:modDate forKey:bookmark]; // update modDate
                if([self.delegate respondsToSelector:@selector(fileDidChangeAtURL:)]){
                    [self.delegate fileDidChangeAtURL:watchedURL]; // callback
                }
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:FileWatcherFileDidChangeNotification
                 object:self userInfo:[NSDictionary dictionaryWithObject:watchedURL forKey:@"URL"]];
            }
            
            [self.fileModificationDates removeObjectForKey:bookmark];
            // Rewatch the file at the current URL in case the file is overwritten.
            if (watchedURL) {
                [self watchFileAtURL:watchedURL];
            }
        }
    }
}

- (NSData *)bookmarkFromURL:(NSURL *)url {
    NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationPreferFileIDResolution
                     includingResourceValuesForKeys:NULL
                                      relativeToURL:NULL
                                              error:NULL];
    return bookmark;
}

- (NSURL *)urlFromBookmark:(NSData *)bookmark {
    NSError *error = nil;
    NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark
                                           options:NSURLBookmarkResolutionWithoutUI
                                     relativeToURL:NULL
                               bookmarkDataIsStale:NULL
                                             error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
    }
    return url;
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [self init])) {
        NSDictionary *decoded = [decoder decodeObjectForKey:@"fileModificationDates"];
        [self.fileModificationDates setDictionary:decoded];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fileModificationDates forKey:@"fileModificationDates"];
}

@end
