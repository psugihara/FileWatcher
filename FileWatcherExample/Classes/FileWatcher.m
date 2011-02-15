//
//  FileWatcher.m
//  GitSync
//
//  Created by Peter Sugihara on 1/4/11.
//  Copyright 2011 Peter Sugihara. All rights reserved.
//

#import "FileWatcher.h"

@interface FileWatcher()
- (void)startWatching;
- (void)checkForUpdates;
- (NSDate *)modificationDateForURL:(NSURL *)url;
- (NSURL *)urlFromBookmark:(NSData *)bookmark;
- (NSData *)bookmarkFromURL:(NSURL *)url;

@end


@implementation FileWatcher
@synthesize delegate;
@synthesize fileModificationDates;

- (id)init {
    if ((self = [super init])) {
        fm = [[NSFileManager alloc] init];
        fileModificationDates = [[NSMutableDictionary alloc] init];
        [self startWatching];
    }
    
    return self;
}

- (void)watchFileAtURL:(NSURL *)url {
    NSData *bookmark = [self bookmarkFromURL:url];
    NSDate *modDate = [self modificationDateForURL:url];
    
    [fileModificationDates setObject:modDate forKey:bookmark];
}

- (void)stopWatchingFileAtURL:(NSURL *)url {
    [fileModificationDates removeObjectForKey:url];
}

- (NSDate *)modificationDateForURL:(NSURL *)URL {
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:[URL path] error:NULL];
    NSDate *modDate = [fileAttributes fileModificationDate];
    return modDate;
}

- (void)startWatching {
    int latency = 3;
	NSTimer *timer = [NSTimer timerWithTimeInterval:latency
                                             target:self 
                                           selector:@selector(checkForUpdates) 
                                           userInfo:nil 
                                            repeats:YES];
	runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)checkForUpdates {
    for (NSData *bookmark in [fileModificationDates allKeys]) {
        NSURL *watchedURL = [self urlFromBookmark:bookmark];
        NSDate *modDate = [self modificationDateForURL:watchedURL];
        // Fires YES the first time it's called after the program turns on.
        // Not sure why, don't really care right now. [Sorry !];
        if ([modDate compare:[fileModificationDates objectForKey:bookmark
                              ]] == NSOrderedDescending) {
            [fileModificationDates setObject:modDate forKey:bookmark]; // update modDate
            [delegate fileDidChangeAtURL:watchedURL]; // callback
        }
    }
}

- (NSData *)bookmarkFromURL:(NSURL *)url {
    NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark
                     includingResourceValuesForKeys:NULL
                                      relativeToURL:NULL
                                              error:NULL];
    return bookmark;
}

- (NSURL *)urlFromBookmark:(NSData *)bookmark {
    NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark
                                           options:NSURLBookmarkResolutionWithoutUI
                                     relativeToURL:NULL
                               bookmarkDataIsStale:NO
                                             error:NULL];
    return url;
}

- (void)dealloc {
    // Clean-up code here.
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [self init])) {
        NSDictionary *decoded = [decoder decodeObjectForKey:@"fileModificationDates"];
        [fileModificationDates setDictionary:decoded];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:fileModificationDates forKey:@"fileModificationDates"];
}

@end
