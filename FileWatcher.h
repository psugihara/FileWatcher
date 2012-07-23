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

extern NSString *const FileWatcherFileDidChangeNotification;

@protocol FileWatcherDelegate;
@interface FileWatcher : NSObject <NSCoding>

+ (id)sharedWatcher;
- (void)watchFileAtURL:(NSURL *)path;
- (void)stopWatchingFileAtURL:(NSURL *)path;

@property (weak, nonatomic) id <FileWatcherDelegate> delegate;

@end


@protocol FileWatcherDelegate <NSObject>
- (void)fileDidChangeAtURL:(NSURL *)url;
@end
