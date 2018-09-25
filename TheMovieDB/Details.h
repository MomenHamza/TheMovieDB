//
//  Details.h
//  TheMovieDB
//
//  Created by Momen on 9/4/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieInfo.h"
#import "MovieInfo.h"
#import <sqlite3.h>
@interface Details : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property   MovieInfo *movieInfo;
@property (strong , nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *moviesDB;
@property long indexpathRow;
@end
