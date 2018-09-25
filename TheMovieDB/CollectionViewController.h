//
//  CollectionViewController.h
//  TheMovieDB
//
//  Created by Momen on 9/4/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFURLSessionManager.h>
#import <AFHTTPSessionManager.h>
#import <sqlite3.h>
#import "Details.h"
#import "Favorite.h"
#import "MovieInfo.h"
#import "Operations.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MKDropdownMenu.h>
@interface CollectionViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSURLConnectionDelegate,NSURLConnectionDataDelegate,MKDropdownMenuDelegate,MKDropdownMenuDataSource>{
    Details *details;
    NSMutableDictionary *dictOfDataResponse;
    NSString *fullPosterUrl;
    NSString *movieFilePath;
    NSFileManager *fileManager;
    NSString *docsDir;
    NSArray *dirPaths;
    Favorite *favorit;
    NSURL *URL ;
    Operations* operations;
}
@property (strong , nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *moviesDB;
@property MovieInfo *movieInfoObj;
@property  NSMutableArray *movies;

@end

