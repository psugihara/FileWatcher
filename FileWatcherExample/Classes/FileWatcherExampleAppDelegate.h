//
//  FileWatcherExampleAppDelegate.h
//  FileWatcherExample
//
//  Created by Peter Sugihara on 2/8/11.
//  Copyright 2011 Bard College. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileWatcher.h"

@interface FileWatcherExampleAppDelegate : NSObject <NSApplicationDelegate, FileWatcherDelegate> {
    FileWatcher *watcher;
}

- (void)fileDidChangeAtURL:(NSURL *)url;
- (void)watchFileAtURL:(NSURL *)url;
- (void)stopWatchingFileAtURL:(NSURL *)url;

@end
