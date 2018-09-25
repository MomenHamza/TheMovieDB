//
//  Details.m
//  TheMovieDB
//
//  Created by Momen on 9/4/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import "Details.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <sqlite3.h>
#import <AFNetworking.h>
#import "Operations.h"
@interface Details (){
    NSMutableDictionary *dictOfDataResponse;
    NSMutableArray *reviews;
    int64_t numOfCells;
    Boolean isFav;
    NSString *docsDir;
    NSArray *dirPaths;
    Operations *dbOperations;
    int dbID;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLable;
@property (weak, nonatomic) IBOutlet UILabel *rateLable;
@property (weak, nonatomic) IBOutlet UITextView *overViewLable;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UIWebView *trailerWebView;
@property NSMutableArray *trailers;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIButton *favoritButton;

@end

@implementation Details

- (void)viewDidLoad {
    [super viewDidLoad];

    isFav=NO;
    NSLog(@"\n Details view did load");
    numOfCells=0;
    [_myScrollView setScrollEnabled:YES];
    [_myScrollView setContentSize:CGSizeMake(self.view.frame.size.width,1200)];

    //SQL
    dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    _databasePath = [[NSString alloc]initWithString: [docsDir stringByAppendingPathComponent:
                                      @"favoritMovies.db"]];
    

    
      const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK){
        NSLog(@"\n\n DB opened from:%s \n",dbpath);
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM FAVORIT_MOVIES WHERE title=\"%@\"",_movieInfo.title];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_moviesDB,query_stmt, -1, &statement, NULL) == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW){
                NSString *dbId = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                dbID=[dbId intValue];
                NSString *dbMovieTitle = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                
                NSLog(@"\n\nmoviw with id:%@ ,title: %@ exist\n\n",dbId,dbMovieTitle);
                [_favoritButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
                isFav=YES;
            } else {
                NSLog(@"Match found");
            }
            sqlite3_finalize(statement);
        }else{
            NSLog(@"\nnot prepared\n");
        }
        sqlite3_close(_moviesDB);
    }else{
        NSLog(@"\nsql open not ok check...");
    }
    //-----Hide NavBar----------------------
    [self.navigationController.navigationBar setHidden:YES];
    //-------------- Set Lables-----------
    [_titleLable setText:[_movieInfo title]];
    [_rateLable setText:[[_movieInfo voteAvg] stringValue]];
    [_overViewLable setText:[_movieInfo overview]];
    [_releaseDateLable setText:[[_movieInfo releaseDate] substringToIndex:4]];
    //---------Set Imaage----------------------
    NSString *fullPosterUrl =[NSString stringWithFormat:@"%@%@%@",@"http://image.tmdb.org/t/p/",@"w185",[_movieInfo posterPath]];
    [_posterImage sd_setImageWithURL:[NSURL URLWithString:fullPosterUrl]
                    placeholderImage:[UIImage imageNamed:@"imagePlaceholder.jpg"]];
    [self.posterImage reloadInputViews];
    //-------Connection to get Youtube Trailer keys--------------------------
    NSLog(@"\n Connection====> \n");
    NSString *urlString=[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/videos?api_key=a583e2b2ab9d4c9a86bb786a34770362",_movieInfo.movieId];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            dictOfDataResponse= responseObject;
            _trailers=[dictOfDataResponse objectForKey:@"results"];
            NSLog(@"\nNum of trailers %lu\n",(unsigned long)[_trailers count]);
            NSLog(@"\nResult %@\n",responseObject);
           // NSLog(@"\ntrailers[0] key  %@\n",[[_trailers objectAtIndex:0] objectForKey:@"key"]);
            numOfCells=[_trailers count];
              [self.myTable reloadData];
        }
    }];
    NSLog(@"\ntask will start");
    [dataTask resume];
    NSLog(@"\ntask did start");
  
      }


//---------------Cell Number------------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"\nnumberOfRowsInSection :%lld",numOfCells);
    if (numOfCells==0) {
        return 1;
    }else{
         return  numOfCells;
    }
}

//------------Back button action-------

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//--------------------Return  Cell-----------------------

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
      UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"Tcell"];
      _trailerWebView=[cell viewWithTag:1];
  
    if (numOfCells==0) {
    cell.textLabel.text=@"Sorry,No trailers avilable!";
    }else{
        cell.textLabel.text=@"";
            NSLog(@"\n\nRetutning Cell\n\n");
    CGFloat width = self.trailerWebView.frame.size.width;
    CGFloat height = self.trailerWebView.frame.size.height;
    NSString *youTubeVideoCode = [[_trailers objectAtIndex:indexPath.row] objectForKey:@"key"];
    NSLog(@"\nKey is : %@\n", [[_trailers objectAtIndex:indexPath.row] objectForKey:@"key"]);

    
    NSString *html = [NSString stringWithFormat:@"<iframe width=\"%f\" height=\"%f\" src=\"http://www.youtube.com/embed/%@\" frameborder=\"0\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe>", width, height, youTubeVideoCode];

    NSLog(@"Link of trailer : \n%@", html);
    self.trailerWebView.scrollView.bounces = NO;
    [self.trailerWebView loadHTMLString:html baseURL:nil];
    NSLog(@"\n\n\ndone\n\n\n");
    }
    return cell;
}
  
//------------------ Add to favoret-------------------
- (IBAction)favoritButton:(UIButton *)sender {
    if(isFav){
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        isFav=NO;
        const char *  dbpath = [_databasePath UTF8String];
        sqlite3_stmt    *statement;
        if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK){
            NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM FAVORIT_MOVIES WHERE title=\"%@\"",_movieInfo.title];
            const char *query_stmt = [querySQL UTF8String];
            NSLog(@"DELETE statement: %s",query_stmt);
            if (sqlite3_prepare_v2(_moviesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
                printf("\n\nPrepare\n");
                if (sqlite3_step(statement) == SQLITE_DONE){
                    printf("\nMovie Deleted\n");
                    //  UPDATE "+TABLE_NUMS+" set _ID = (_ID - 1) WHERE _ID > "+this.rowID);
                    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE FAVORIT_MOVIES SET id = (id-1) WHERE id > %d",dbID];
                    const char *update_stmt = [updateSQL UTF8String];
                    if (sqlite3_prepare_v2(_moviesDB, update_stmt, -1, &statement, NULL) == SQLITE_OK){
                        if (sqlite3_step(statement) == SQLITE_DONE){
                            printf("\nupdate done\n");
                        }else{
                            NSLog(@"\n\nUpdate failed\n %s",sqlite3_errmsg(_moviesDB));
                        }
                    }
                } else {
                    
                    NSLog(@"Match not founddelet%s",sqlite3_errmsg(_moviesDB));
                }
                sqlite3_finalize(statement);
            }
            sqlite3_close(_moviesDB);
        }else{
            printf("\nelse\n");
        }
    }else{
        int count =[dbOperations GetCountOfTable:@"FAVORIT_MOVIES" FromDB:@"favoritMovies.db" withBath:_databasePath];
        
        sqlite3_stmt *statement;
        const char *dbpath = [_databasePath UTF8String];
        if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK)
        {        dbOperations=[[Operations alloc] init];
         
            
            NSLog(@"\n\nsqlite3_open_OK\n\n");
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO FAVORIT_MOVIES (id,title , year, rating,image_path,movie_id,IPR) VALUES (\"%D\",\"%@\", \"%@\", \"%@\", \"%@\",  \"%@\", \"%ld\")",count+1, _titleLable.text , _releaseDateLable.text , _rateLable.text, _movieInfo.posterPath,_movieInfo.movieId,_indexpathRow];
            NSLog(@"\nIPR:%ld",_indexpathRow);
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_moviesDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE){
                printf("\nMovie added\n");
                [sender setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
                NSLog(@"%@", _databasePath);
            }else {
                printf("\nFailed to add movie\n %s",sqlite3_errmsg(_moviesDB));
            }
            sqlite3_finalize(statement);
            sqlite3_close(_moviesDB);
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //-----------------    SQL  ---------------------------------
    NSLog(@"\n\n Details will appear");
  
    }

@end
