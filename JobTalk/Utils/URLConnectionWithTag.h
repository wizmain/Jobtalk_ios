//
//  URLConnectionWithTag.h
//  SmartLMS
//
//  Created by 김 규완 on 11. 10. 11..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLConnectionWithTag : NSURLConnection {
    NSString *tag;
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)tag;

@end
