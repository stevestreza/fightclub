//
//  HellanzbServer.m
//  NZBTap
//
//  Created by Steve Streza on 9/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FCHellanzbServer.h"


@implementation FCHellanzbServer

@synthesize name=mName, 
	downloadQueue=mDownloadQueue, 
	processingQueue=mProcessingQueue, 
	currentDownload=mCurrentDownload, 
	percentComplete=mPercentComplete, 
	downloadSpeed=mDownloadSpeed,
	downloadsPaused=mDownloadsPaused;

-(id)initWithDictionary:(NSDictionary *)dict{
	if(self = [super initWithDictionary:dict]){
		[self setName:[dict valueForKey:@"name"]];
	}
	return self;
}

-(void)awake{
	[super awake];
	mDownloads = [[NSMutableDictionary dictionary] retain];
}

-(void)startStatusTimer{
	if(!statusTimer){
		NSLog(@"Starting status");
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getStatus) userInfo:nil repeats:YES];		
	}
}

-(void)stopStatusTimer{
	if(statusTimer){
		[statusTimer invalidate];
		[statusTimer release];
		statusTimer = nil;
	}
}

-(BOOL)statusTimerIsRunning{
	return (statusTimer != nil);
}

-(void)getStatus{
	NSLog(@"Fetching status");
	[self callMethod:@"status" withObjects:nil];
}

-(FCHellanzbDownload *)downloadWithInfo:(NSDictionary *)info{
	if(info == nil) return nil;
	
	/*
	 download = Sproutnzb.Download.create({
	 id: rpc.id,
	 newzbinID: rpc.msgid,
	 name: rpc.nzbName,
	 size: rpc.total_mb
	 });
	*/
	NSString *theID     = [info objectForKey:@"id"];
	
	FCHellanzbDownload *download = [mDownloads objectForKey:theID];
	if(!download){
		NSString *newzbinID = [info objectForKey:@"msgid"];
		NSString *name      = [info objectForKey:@"nzbName"];
		NSString *size      = [info objectForKey:@"total_mb"];

		download = [[FCHellanzbDownload alloc] initWithID:theID server:self];
//		download.name = name;
//		download.newzbinID = newzbinID;
//		download.size = [size intValue];
		[download setName:name];
		[download setNewzbinID:newzbinID];
		if([size isKindOfClass:[NSNumber class]]){
			long long realSize = [size longLongValue];
			[download setSize:realSize];
		}else if([size isKindOfClass:[NSString class]]){
			[download setSizeFromString:size];
		}
		
		[mDownloads setValue:download forKey:theID];
		[download autorelease];
	}
	return download;
}

-(NSArray *)downloadsWithInfoArray:(NSArray *)infoArray{
	NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:[infoArray count]];
	NSUInteger index=0;
	for(index; index < infoArray.count; index++){
		FCHellanzbDownload *download = [self downloadWithInfo:[infoArray objectAtIndex:index]];
		if(download){
			[retVal addObject:download];
		}
	}
	return [[retVal copy] autorelease];
}

-(void)handleStatus:(XMLRPCResponse *)response withRequest:(XMLRPCRequest *)request error:(NSError *)error{
	NSDictionary *stats = [response object];
	
	if([stats isKindOfClass:[NSError class]]) {
		NSLog(@"Eror in handleStatus: %@",stats);
		return;
	}
	
	NSDictionary *currentDLInfo = [[stats objectForKey:@"currently_downloading"] objectAtIndex:0];
	
	[self willChangeValueForKey:@"currentDownload"];
	mCurrentDownload = [self downloadWithInfo:currentDLInfo];
	
	if(mCurrentDownload){
		self.percentComplete = [[stats objectForKey:@"percent_complete"] intValue];
		self.downloadSpeed   = [[stats objectForKey:@"rate"] intValue];
		self.downloadsPaused = [[stats objectForKey:@"is_paused"] boolValue];
		
//		NSLog(@"%i%% complete at %i KBps - %@",self.percentComplete, self.downloadSpeed, (self.downloadsPaused ? @"paused" : @"not paused"));
	}
	[self didChangeValueForKey:@"currentDownload"];
	
	[self _setDownloadQueue:[self downloadsWithInfoArray:[stats objectForKey:@"queued"]]];		
	[self _setProcessingQueue:[self downloadsWithInfoArray:[stats objectForKey:@"currently_processing"]]];		
}

-(void)_setDownloadQueue:(NSArray *)newQueue{
	if(![newQueue isEqualToArray:mDownloadQueue]){
		[self willChangeValueForKey:@"downloadQueue"];
		[newQueue retain];
		[mDownloadQueue release];
		
		mDownloadQueue = newQueue;
		[self didChangeValueForKey:@"downloadQueue"];
	}
}

-(void)_setProcessingQueue:(NSArray *)newQueue{
	if(![newQueue isEqualToArray:mProcessingQueue]){
		[self willChangeValueForKey:@"processingQueue"];
		[newQueue retain];
		[mProcessingQueue release];
		
		mProcessingQueue = newQueue;
		[self didChangeValueForKey:@"processingQueue"];
	}
}

-(NSString *)name{
	if(!mName){
		return @"Unnamed Server";
	}
	return mName;
}

-(NSDictionary *)dictionary{
	NSMutableDictionary *dict = [[super dictionary] mutableCopy];
	[dict setObject:[self name] forKey:@"name"];
	dict = [[dict autorelease] copy];
	return [dict autorelease];
}

@end
