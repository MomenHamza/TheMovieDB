//
//  DBOperations.m
//  TheMovieDB
//
//  Created by Momen on 9/18/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import "Operations.h"
@implementation Operations
- (int) GetCountOfTable:(NSString*)tableName FromDB:(NSString*)dbName withBath:(NSString *)dbPathString{
    int count = 0;
    const char * dbpath = [dbPathString UTF8String];
    sqlite3_stmt  *statement;

    if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"Select count(*) from %@",tableName];
        const char *query_stmt = [querySQL UTF8String];
        NSLog(@"\n databade at : %@ is opened",dbPathString);
        if (sqlite3_prepare_v2(_moviesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW){
                count = [[[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue];
                NSLog(@"\n\n Count of table %@ is %D",tableName,count);
            }else {
                NSLog(@"\n\nmatch not found  Count of table %@ is %D",tableName,count);
            }
            sqlite3_finalize(statement);
        }else{
             NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(_moviesDB) );
        }
        sqlite3_close(_moviesDB);
    }else{
        NSLog(@"\n\nSQLITE_OPEN_FAILED\n");
    }
    return count;
}

-(NSMutableDictionary*) GetJsonResponseFrom:(NSURL*)URL{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            dictOfDataResponse= responseObject;
    }
    }];
    [dataTask resume];
    return dictOfDataResponse;
}

@end
