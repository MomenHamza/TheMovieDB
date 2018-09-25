//
//  MovieInfo.h
//  TheMovieDB
//
//  Created by Momen on 9/5/18.
//  Copyright © 2018 Momen. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MovieInfo : NSObject
@property id movieId;
@property int voteCount,runtime;
@property NSNumber *voteAvg;
@property float popularity;
@property NSString * posterPath,*orignalLang,*title,*overview,*releaseDate;
@end
