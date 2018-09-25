//
//  Favorite.h
//  TheMovieDB
//
//  Created by Momen on 9/13/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "MovieInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking.h>
@interface Favorite : UIViewController<UITableViewDelegate,UITableViewDataSource,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UILabel *runtime;
@property (weak, nonatomic) IBOutlet UILabel *year;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property   MovieInfo *movieInfo;
@property (strong , nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *moviesDB;
@end
