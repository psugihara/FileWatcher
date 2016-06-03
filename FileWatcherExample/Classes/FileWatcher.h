//
//  FileWatcher.h
//  GitSync
//
//  Abstract: FileWatcher watches for changes on a set of files and calls fileDidChangeAtPath.
//
//  Created by Peter Sugihara on 1/4/11.
//  Copyright 2011 Peter Sugihara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileWatcherDelegate;
@interface FileWatcher : NSObject <NSCoding> {
@private
    NSMutableDictionary *fileModificationDates; // Keys are bookmarks being watched.
    NSRunLoop *runLoop;
    NSFileManager *fm;
}

- (void)watchFileAtURL:(NSURL *)path; 
- (void)stopWatchingFileAtURL:(NSURL *)path;

@property (nonatomic, weak) id <FileWatcherDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *fileModificationDates;

@end


@protocol FileWatcherDelegate <NSObject>
- (void)fileDidChangeAtURL:(NSURL *)notification;
@end