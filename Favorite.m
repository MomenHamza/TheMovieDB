//
//  Favorite.m
//  TheMovieDB
//
//  Created by Momen on 9/13/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import "Favorite.h"
#import "Operations.h"
#import "CollectionViewController.h"
#import "Details.h"
@interface Favorite ()
{
    NSString *movieID;
    NSMutableArray*movieIDArray;
    Details*details;

}
@property     MovieInfo *movieInfoObj;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property  NSMutableArray *movies;
@end

@implementation Favorite{
     NSString *count;
    int cellNumber;
    Operations *operations;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _movieInfoObj=[MovieInfo alloc];
    details=[Details alloc];
    NSLog(@"\n\nFavorite view did load");
    NSLog(@"\ndid load count is %D", cellNumber);
    _movies=[[NSMutableArray alloc] init];
      [self.navigationController.navigationBar setHidden:YES];
        operations=[Operations alloc];
   // _movies=[NSMutableArray arrayWithObjects: nil];
    }
 //---------------------- Num of Cells-----------------------------------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *dirPaths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    _databasePath = [[NSString alloc]initWithString: [docsDir stringByAppendingPathComponent: @"favoritMovies.db"]];
    cellNumber=[operations GetCountOfTable:@"FAVORIT_MOVIES" FromDB:@"favoritMovies.db" withBath:_databasePath];
    NSLog(@"\n num of cells count is %d", cellNumber);
    _movies=[NSMutableArray arrayWithObjects: nil];

    return cellNumber;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    [self.navigationController.navigationBar setHidden:YES];
    
    
}
//---------------------- return Cell-----------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell2"];
    
    UIImageView *imageView =[cell viewWithTag:1];
    UILabel *title=[cell viewWithTag:2];
    UILabel   *year =[cell viewWithTag:3];
    UILabel *rate =[cell viewWithTag:4];
    
    //------------Retreave data from SQLite-----------------------
    NSArray *dirPaths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    _databasePath = [[NSString alloc]initWithString: [docsDir stringByAppendingPathComponent: @"favoritMovies.db"]];
   const char *  dbpath = [_databasePath UTF8String];
    
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK){
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM FAVORIT_MOVIES WHERE id=\"%ld\"",(long)indexPath.row+1];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_moviesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW){
                NSLog(@"stmt\n%@", [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]);
                NSLog(@"stmt\n%@", [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)]);
                NSString *movieTitleField = [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                NSString *yearField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *rateField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString *posterPathField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                movieID = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
               
                [_movies addObject:movieID];
                
                NSString *path=[NSString stringWithFormat:@"http://image.tmdb.org/t/p/w185/%@",posterPathField];
                [imageView sd_setImageWithURL:[NSURL URLWithString:path]placeholderImage:[UIImage imageNamed:@"imagePlaceholder.jpg"]];
                
                title.text=movieTitleField;
                year.text=yearField;
                rate.text=rateField;
               // _duration.text=
                
            } else {
                NSLog(@"Match not found returncell%s",sqlite3_errmsg(_moviesDB));
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_moviesDB);
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    details=[self.storyboard instantiateViewControllerWithIdentifier:@"details"];

   // https://api.themoviedb.org/3/movie/135870?api_key=a583e2b2ab9d4c9a86bb786a34770362&language=en-US

    NSURL *URL=[NSURL URLWithString:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=a583e2b2ab9d4c9a86bb786a34770362&language=en-US",[_movies objectAtIndex:indexPath.row]]];
    NSMutableDictionary * response=[NSMutableDictionary alloc];
    response=[operations GetJsonResponseFrom:URL];
    printf("\ninit and sending details info\n");
    NSLog(@"\ngoing to %@ details \n",[response objectForKey:@"title"]);
    
    printf("\ninit and sending details info\n");
    [_movieInfoObj setTitle:[response objectForKey:@"title"]];
    [_movieInfoObj setReleaseDate :[response objectForKey:@"release_date"]];
    [_movieInfoObj setMovieId:[response objectForKey:@"id"]];
    [_movieInfoObj setVoteAvg :[response objectForKey:@"vote_average"]];
    [_movieInfoObj setPosterPath:[response objectForKey:@"poster_path"]];
    [_movieInfoObj setOverview :[response objectForKey:@"overview"]];
    [_movieInfoObj setOrignalLang:[response objectForKey:@"original_language"]];
    [_movieInfoObj setVoteCount:(int)[response objectForKey:@"vote_count"]];
    [_movieInfoObj setMovieId:[response objectForKey:@"id"]];
   // [_movieInfoObj set]
    
    [details setMovieInfo:_movieInfoObj];
    [self.navigationController pushViewController:details animated:YES];

}
//------------------------------------- Remove frome favorit -----------------------------

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *dirPaths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = dirPaths[0];
        _databasePath = [[NSString alloc]initWithString: [docsDir stringByAppendingPathComponent: @"favoritMovies.db"]];
        const char *  dbpath = [_databasePath UTF8String];
        sqlite3_stmt    *statement;
        if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK){
            NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM FAVORIT_MOVIES WHERE id=\"%ld\"",(long)indexPath.row+1];
            const char *query_stmt = [querySQL UTF8String];
            NSLog(@"DELETE statement: %s",query_stmt);
            if (sqlite3_prepare_v2(_moviesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
                printf("\n\nPrepare\n");
                if (sqlite3_step(statement) == SQLITE_DONE){
                    
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    cellNumber-=1;
                    printf("\nRow Deleted\n");
                    
                    //  UPDATE "+TABLE_NUMS+" set _ID = (_ID - 1) WHERE _ID > "+this.rowID);
                    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE FAVORIT_MOVIES SET id = (id-1) WHERE id > %ld",(long)indexPath.row+1];
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
    }
}

@end
