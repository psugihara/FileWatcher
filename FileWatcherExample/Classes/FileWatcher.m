//
//  FileWatcher.m
//  GitSync
//
//  Created by Peter Sugihara on 1/4/11.
//  Copyright 2011 Peter Sugihara. All rights reserved.
//

#import "FileWatcher.h"


@interface WatchedFile : NSObject
@property (retain) NSURL *watchedURL;
@property (retain) NSDate *modDate;
@end

@implementation WatchedFile
@synthesize watchedURL;
@synthesize modDate;

- (BOOL)isEqual:(id)object
{
    BOOL toReturn = NO;
    if([object isKindOfClass:[WatchedFile class]])
    {
        WatchedFile *other = (WatchedFile *)object;
        if([other.modDate compare:self.modDate] == NSOrderedSame && [other.watchedURL isEqual:self.watchedURL])
        {
            toReturn = YES;
        }
    }
    return toReturn;
}
@end


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
    WatchedFile *wf = [[WatchedFile alloc] init];
    wf.watchedURL = url;
    wf.modDate = modDate;
    
    [fileModificationDates setObject:wf forKey:bookmark];
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
    float latency = .5;
	NSTimer *timer = [NSTimer timerWithTimeInterval:latency
                                             target:self 
                                           selector:@selector(checkForUpdates) 
                                           userInfo:nil 
                                            repeats:YES];
	runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)checkForUpdates {
    
    NSLog(@"checkForUpdates");
    
    for (NSData *bookmark in [fileModificationDates allKeys]) {
        NSURL *watchedURL = [self urlFromBookmark:bookmark];
        NSDate *modDate = [self modificationDateForURL:watchedURL];
        WatchedFile *temp = [[WatchedFile alloc] init];
        temp.watchedURL = watchedURL;
        temp.modDate = modDate;
        
        WatchedFile *existing = fileModificationDates[bookmark];
        
        // Fires YES the first time it's called after the program turns on.
        // Not sure why, don't really care right now. [Sorry !];
        if (![existing isEqual:temp]) {
            [fileModificationDates setObject:temp forKey:bookmark]; // update modDate
            [delegate fileDidChangeAtURL:watchedURL]; // callback
        }
        
        [fileModificationDates removeObjectForKey:bookmark];
        // Rewatch the file at the current URL in case the file is overwritten.
        if (watchedURL)
            [self watchFileAtURL:watchedURL]; 
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
    NSError *error = noErr;
    NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark
                                           options:NSURLBookmarkResolutionWithoutUI
                                     relativeToURL:NULL
                               bookmarkDataIsStale:NULL
                                             error:&error];
    if (error != noErr)
        NSLog(@"%@", [error description]);
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
