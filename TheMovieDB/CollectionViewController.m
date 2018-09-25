//
//  CollectionViewController.m
//  TheMovieDB
//
//  Created by Momen on 9/4/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"cell";

//-------------------------DidLoad_________________________________________________
- (void)viewDidLoad {
    [super viewDidLoad];
    printf("\nCollecton view did load\n");
    operations=[Operations alloc];
    dictOfDataResponse=[NSMutableDictionary alloc];       // Full json response
    _movieInfoObj=[MovieInfo alloc];                       //to send details to DetilsVC
    
    self.navigationItem.title=@"Populer Movies";
    
    //----------- requesting movies from API ------------------

    URL = [NSURL URLWithString:@"http://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=a583e2b2ab9d4c9a86bb786a34770362"];
 
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            dictOfDataResponse= responseObject;
            _movies=[dictOfDataResponse objectForKey:@"results"] ;
            [self.collectionView reloadData];
        }
    }];
    [dataTask resume];

    //-----------DropDown ------------------
    float dropDownW =self.navigationController.navigationBar.frame.size.width;
    MKDropdownMenu *dropdownMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(dropDownW-200, 0, 200, 44)];
    dropdownMenu.dataSource = self;
    dropdownMenu.delegate = self;
    [self.navigationController.navigationBar addSubview:dropdownMenu];

    dropdownMenu.tintColor=[UIColor whiteColor];

    //--------------------------Creating SQLite DB-------------------------
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    _databasePath = [[NSString alloc]initWithString: [docsDir stringByAppendingPathComponent: @"favoritMovies.db"]];
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_moviesDB) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt =
        "CREATE TABLE IF NOT EXISTS FAVORIT_MOVIES (ID INTEGER PRIMARY KEY , TITLE TEXT, YEAR TEXT, RATING TEXT , IMAGE_PATH TEXT,movie_id,IPR INTEGER)";
        NSLog(@"\n\n DB Createdat:%s \n",dbpath );
        if (sqlite3_exec(_moviesDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            
        {
            NSLog(@"\n erroe%s",sqlite3_errmsg(_moviesDB));
        }
        sqlite3_close(_moviesDB);
    } else {
        NSLog(@"\nFailed to open/create database%s",sqlite3_errmsg(_moviesDB));
    }
    
}

//----------------------- Did Highlight Item-----------------------------

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    printf("\ninit and sending details info\n");
    [_movieInfoObj setTitle:[[_movies objectAtIndex:indexPath.row] objectForKey:@"title"]];
    [_movieInfoObj setReleaseDate :[[_movies objectAtIndex:indexPath.row] objectForKey:@"release_date"]];
    [_movieInfoObj setMovieId:[[_movies objectAtIndex:indexPath.row] objectForKey:@"id"]];
    [_movieInfoObj setVoteAvg :[[_movies objectAtIndex:indexPath.row] objectForKey:@"vote_average"]];
    [_movieInfoObj setPosterPath:[[_movies objectAtIndex:indexPath.row] objectForKey:@"poster_path"]];
    [_movieInfoObj setOverview :[[_movies objectAtIndex:indexPath.row] objectForKey:@"overview"]];
    [_movieInfoObj setOrignalLang:[[_movies objectAtIndex:indexPath.row] objectForKey:@"original_language"]];
    [_movieInfoObj setVoteCount:(int)[[_movies objectAtIndex:indexPath.row] objectForKey:@"vote_count"]];
    [_movieInfoObj setMovieId:[[_movies objectAtIndex:indexPath.row] objectForKey:@"id"]];
    
    
    details=[self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    NSLog(@"\ngoing to %@ details \n", _movieInfoObj.title);
    [details setMovieInfo:_movieInfoObj];
    [details setIndexpathRow:indexPath.row];
    [self.navigationController pushViewController:details animated:YES];
    
};


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
    }

//---------------------- Num of Sections-----------------------------------------------

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//---------------------- Num of Cells-----------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _movies.count;
}

//---------------------- Cell confegration-----------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView =[cell viewWithTag:1];
    fullPosterUrl =[NSString stringWithFormat:@"http://image.tmdb.org/t/p/w185/%@",[[_movies objectAtIndex:indexPath.row] objectForKey:@"poster_path"]];
    [imageView sd_setImageWithURL:[NSURL URLWithString:fullPosterUrl] placeholderImage:[UIImage imageNamed:@"imagePlaceholder.jpg"]];

    return cell;
}

//--------------------------Cell width and hight---------------------------
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(CGRectGetWidth(collectionView.frame)/2, CGRectGetHeight(collectionView.frame)/2);
}

//--------------------------DropdownMenu---------------------------

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu{
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component{
    return 2;
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForComponent:(NSInteger)component{
    return @"";
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *choise=[[NSString alloc] init];
    
    switch (row) {
        case 0:
            choise= @"Populer Movies";
            break;
            
        case 1:
            choise= @"Hight rated Movies";
            break;
        }
    return choise;
}

-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSURL* popularityURL = [NSURL URLWithString:@"http://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=a583e2b2ab9d4c9a86bb786a34770362"];
  
    NSURL *voteURL = [NSURL URLWithString:@"http://api.themoviedb.org/3/discover/movie?certification_country=US&certification=NR&sort_by=vote_average.desc&api_key=a583e2b2ab9d4c9a86bb786a34770362"];
  
    
    switch (row) {
        case 0:
            self.navigationItem.title=@"Populer Movies";
             URL=popularityURL;
   
            break;
            
        case 1:
            self.navigationItem.title=@"Hight rated Movies";
              URL=voteURL;
            
            break;
        }
   
   
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            dictOfDataResponse= responseObject;
            _movies=[dictOfDataResponse objectForKey:@"results"] ;
            [self.collectionView reloadData];
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
    printf("\n view updated with \n");
    [self.collectionView reloadData];
}
@end
