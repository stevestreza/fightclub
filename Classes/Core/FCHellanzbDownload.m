//
//  HellanzbDownload.m
//  NZBTap
//
//  Created by Steve Streza on 9/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FCHellanzbDownload.h"

@implementation FCHellanzbDownload

@synthesize name=mName, newzbinID=mNewzbinID, size=mSize;

-(id)initWithID:(NSString *)newID server:(FCHellanzbClient *)server{
	if(self = [super init]){
		mServer = [server retain];
		mID = [newID copy];
	}
	return self;
}

-(void)dealloc{
	[mServer release];
	[mID release];
	
	[super dealloc];
}

-(void)setSizeFromString:(NSString *)sizeStr{
	NSScanner *scanner = [[[NSScanner alloc] initWithString:sizeStr] autorelease];
	long long value = 0;
	if([scanner scanLongLong:&value] && value){
		self.size = value * 1024 * 1024;
	}
}

-(long long)size{
	return mSize;
}

-(void)setSize:(long long)newSize{
	mSize = newSize;
}

@end
