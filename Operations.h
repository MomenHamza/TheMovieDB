//
//  DBOperations.h
//  TheMovieDB
//
//  Created by Momen on 9/18/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>    
#import <AFURLSessionManager.h>
#import <AFHTTPSessionManager.h>
@interface Operations : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    NSMutableDictionary *dictOfDataResponse;
}
@property  NSMutableArray *movies;
@property  (nonatomic) sqlite3 *moviesDB;
- (int) GetCountOfTable:(NSString*)tableName FromDB:(NSString*)dbName withBath:(NSString*)dbPathString;
-(NSMutableDictionary*) GetJsonResponseFrom:(NSURL*)URL;
@end

