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
    // [watcher watchFileAtURL:[NSURL URLWithString:@"file://localhost/Users/someuser/Desktop/Untitled.rtf"]];
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
