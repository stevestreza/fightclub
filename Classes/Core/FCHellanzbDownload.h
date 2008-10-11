//
//  HellanzbDownload.h
//  NZBTap
//
//  Created by Steve Streza on 9/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FCHellanzbServer;

@interface FCHellanzbDownload : NSObject {
	FCHellanzbServer *mServer;
	NSString *mID;

	NSString *mNewzbinID;
	NSString *mName;
	long long mSize;
}
@property (copy) NSString *newzbinID;
@property (copy) NSString *name;
@property long long size;

-(void)setName:(NSString *)newName;
-(void)setNewzbinID:(NSString *)newNewzbinID;
-(void)setSize:(long long)newSize;

-(long long)size;

@end
