//
//  HellanzbServer.h
//  NZBTap
//
//  Created by Steve Streza on 9/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCServer.h"

@class FCHellanzbDownload;

@interface FCHellanzbServer : XMLRPCServer {
	NSString *mName;
	NSMutableDictionary *mDownloads;
	
	NSArray *mDownloadQueue;
	NSArray *mProcessingQueue;
	FCHellanzbDownload *mCurrentDownload;
	
	NSUInteger mPercentComplete;
	NSUInteger mDownloadSpeed;
	BOOL mDownloadsPaused;
	
	NSTimer *statusTimer;
}

@property (copy) NSString *name;
@property (readonly) NSArray *downloadQueue;
@property (readonly) NSArray *processingQueue;
@property (readonly) FCHellanzbDownload *currentDownload;
@property NSUInteger percentComplete;
@property NSUInteger downloadSpeed;
@property BOOL downloadsPaused;

-(NSString *)name;
-(void)setName:(NSString *)newName;
-(BOOL)statusTimerIsRunning;
@end
