//
//  FileWatcherExampleAppDelegate.m
//  FileWatcherExample
//
//  Created by Peter Sugihara on 2/8/11.
//  Copyright 2011 Bard College. All rights reserved.
//

#import "FileWatcherExampleAppDelegate.h"

@implementation FileWatcherExampleAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	watcher = [[FileWatcher alloc] init];
    watcher.delegate = self;
    
    // A test watch:
    // [self watchFileAtURL:[NSURL URLWithString:@"path/to/file"]];
}

- (void)fileDidChangeAtURL:(NSURL *)url {
    NSLog(@"i saw that, %@!", url);
}

- (void)watchFileAtURL:(NSURL *)url {
    [watcher watchFileAtURL:url];
}

- (void)stopWatchingFileAtURL:(NSURL *)url {
    [watcher stopWatchingFileAtURL:url];
}


@end
