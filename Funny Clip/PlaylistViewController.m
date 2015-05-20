//
//  PlaylistViewController.m
//  Funny Clip
//
//  Created by NhanNLT on 4/15/15.
//  Copyright (c) 2015 NhanNLT. All rights reserved.

#import "PlaylistViewController.h"
#import "JSONHTTPClient.h"
#import "NSURLParameters.h"
#import "VideoModel.h"
#import <UIImageView+AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "VideoData.h"
#import "UploadController.h"
#import "VideoListViewController.h"

#import "JSONModel.h"
#include "PlayListModel.h"
#import "tblCellMenu.h"
#import "VCAbout.h"
// Thumbnail image size.

@implementation PlaylistViewController
@synthesize youtubeService;

// BaseURLString
static NSString * BaseURLStringDropBox_1 =@"https://www.dropbox.com/s/msp70rmarezsjyw/VideoJson.txt?dl=1";
//static NSString * const BaseURLStringDropBox_2 =@"https://www.dropbox.com/s/msp70rmarezsjyw/VideoJson.txt?dl=1";
static NSString *  BaseURLStringGoogle =@"https://drive.google.com/uc?export=download&id=0B45IYpZpvVu-NGFqQXhEZmhVbVE";
static NSString *  BaseURLStringGit =@"https://cdn.rawgit.com/trongnhan68/Kid-Video/master/VideoJson.txt";

- (void) initValueLocalizable {

    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"vi"]) {
      BaseURLStringDropBox_1 =@"https://www.dropbox.com/s/msp70rmarezsjyw/VideoJson.txt?dl=1";
       
      BaseURLStringGoogle =@"https://drive.google.com/uc?export=download&id=0B45IYpZpvVu-NGFqQXhEZmhVbVE";
      BaseURLStringGit =@"https://cdn.rawgit.com/trongnhan68/Kid-Video/master/VideoJson.txt";
    
    } 
}

#pragma mark - Init Data
- (void) initDataMenu {
    mMenuItems = [NSArray arrayWithObjects:@"Loop",@"Remove Ads",@"Sign In",@"About", nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receivedNotification:)
//                                                 name:@"playRepeat"
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receivedNotification:)
//                                                 name:@"playBackground"
//                                               object:nil];
    
}
- (void) initItemStatus {
    //set IS_OPEN_IN_TAB =1: MUSIC TAB
    IS_OPEN_IN_TAB = IS_MUSIC;
    // Init
    theSecondBefore=0;
    CurrentVideoIdPlaying = @"L0MK7qz13bU";
   
    [self.playButton setSelected:YES];
    [self.ViewListCollection setAlpha:0];
    [self.searchBarView setHidden:YES];
    
    // self.listViewColectionView.bounces =NO ;
    [self.navigationController setNavigationBarHidden:YES];
    [self.playButton setBackgroundImage:[UIImage imageNamed:BTN_NAME_PLAY] forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage imageNamed:BTN_NAME_PAUSE] forState:UIControlStateSelected];
    
     [self.btnAmNhac setBackgroundImage:[UIImage imageNamed:BTN_NAME_MUSIC] forState:UIControlStateNormal];
     [self.btnHoatHinh setBackgroundImage:[UIImage imageNamed:BTN_NAME_CARTOON] forState:UIControlStateNormal];
     [self.btnKeChuyen setBackgroundImage:[UIImage imageNamed:BTN_NAME_STORY] forState:UIControlStateNormal];
   // [self];
    
    //setup title video playing
    self.titleVideoPlaying.textAlignment= NSTextAlignmentLeft;
    self.titleVideoPlaying.marqueeType = MLContinuous;
    self.titleVideoPlaying.scrollDuration = 20.0f;
    self.titleVideoPlaying.fadeLength = 20.0f;
    self.titleVideoPlaying.trailingBuffer = self.titleVideoPlaying.frame.size.width;
    self.titleVideoPlaying.animationDelay=0.f;
    
    //[self.viewButonSeeking setAlpha:0];
    self.currentTextInSearchBar = @"";
    
    // table
    [self.mListVideo setSectionFooterHeight:1];
    [self.tbvMenu setBounces:NO];
    // [self.tbvMenu vi];
}

- (id)init
{
    self = [super init];
    if (self) {
        _getVideos = [[YouTubeGetVideos alloc] init];
        _getVideos.delegate = self;
        VIDEOS_AMNHAC = [[NSMutableArray alloc] init];
        VIDEOS_KECHUYEN = [[NSMutableArray alloc] init];
        VIDEOS_HOATHINH = [[NSMutableArray alloc] init];
        VIDEOS_SEARCH_RESULTS = [[NSMutableArray alloc] init];
        mVCAbout = [[VCAbout alloc]initWithNibName:@"VCAbout" bundle:nil];
    }
    return self;
    
}

#pragma mark - ViewDid
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isFirstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"];
    if (!isFirstTime) {
    // do someting when first time run app;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playRepeat"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playBackground"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTime"];
    
    }
    
    [self initValueLocalizable];
    
    self.youtubeService = [[GTLServiceYouTube alloc] init];
    self.youtubeService.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
    if (![self isAuthorized]) {
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        
        [[self navigationController] pushViewController:[self createAuthController] animated:YES];
       } else {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        isTheFirstTime= YES;
        // [self.listViewColectionView setHidden:YES];
        [self init];
        [self initItemStatus];
        [self initDataMenu];
        mFavoriteVideos = [NSMutableArray array];
        
        
        
        //NSString* videoID = @"L0MK7qz13bU";
        // [self.playButton setImage:[UIImage imageNamed:@"stop_on.png"] forState:UIControlStateSelected];
        // For a full list of player parameters, see the documentation for the HTML5 player
        // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
        playerVars = @{
                       @"controls" : @1,
                       @"playsinline" : @1,
                       @"autohide" : @1,
                       @"showinfo" : @1,
                       @"modestbranding" : @1
                       };
        self.playerView.delegate = self;
        
        // [self.playerView loadWithVideoId:videoID playerVars:playerVars];
       timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDurationTime) userInfo:nil repeats:YES];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedPlaybackStartedNotification:)
                                                     name:@"Playback started"
                                                   object:nil];
        
           [[NSNotificationCenter defaultCenter] addObserver:self
                                                    selector:@selector(deleteVideoFromFavorite:)
                                                        name:@"deleteVideoFromFavorite"
                                                      object:nil];
        //[self loadDataJson];
        if ([self loadAllFavoriteVideosFromDB]) {
            [self.mListVideo reloadData];
        }
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDisAppearOrShow)];
        _tap.enabled = NO;
        [self.view addGestureRecognizer:_tap];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
            
            // __block BOOL status;
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    // -- Reachable -- //
                    NSLog(@"Reachable ok");
                    [self checkNetworkStatus];
                    if (CurrentVideoIdPlaying) {
                        [self.playerView loadWithVideoId:CurrentVideoIdPlaying playerVars:playerVars];
                        [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
                    }
                    
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    // -- Not reachable -- //
                    NSLog(@"Not Reachable");
                    [BaseUtils showAlert:POPUP_TITLE_NETWORK message:POPUP_INFO_NETWORK_ERROR];
                    
                    break;
            }
            
        }];

    
    }
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startOAuthFlow:(id)sender {
    GTMOAuth2ViewControllerTouch *viewController;
    
    viewController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:kGTLAuthScopeYouTube
                      clientID:kClientID
                      clientSecret:kClientSecret
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController animated:YES];
}
#pragma mark - YouTubeGetUploadsDelegate methods
- (void)getYouTubeFavoriteVideos:(YouTubeGetVideos *)getVideos didFinishWithResults:(NSArray *)results {
    if (results) {
    
        for (VideoData *vidData in results) {
            [self saveToDBWhenClick:vidData];
        }
    }
}
- (void)getYouTubeVideos:(YouTubeGetVideos *)getVideos didFinishWithResults:(NSArray *)results : (NSString*) nextPageTokenThis : (NSString *) prvPageTokenThis : (int ) typeOfResultThis {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    if (![AFNetworkReachabilityManager sharedManager].reachable) {
    
               [BaseUtils showAlert:POPUP_TITLE_NETWORK message:POPUP_INFO_LOAD_DATA_ERROR];

    }
    isLoadFinish=YES;
    if (!results) {
        [MBProgressHUD hideHUDForView:self.listViewColectionView animated:YES];
        
        return;
    }
    switch (IS_OPEN_IN_TAB) {
        case IS_MUSIC:
            if (typeOfResultThis == TYPE_OF_RESULT_NORMAL)
                VIDEOS_AMNHAC = [results mutableCopy];
            else [VIDEOS_AMNHAC addObjectsFromArray:results];
            break;
        case IS_STORY:
            if (typeOfResultThis == TYPE_OF_RESULT_NORMAL)
                VIDEOS_KECHUYEN = [results mutableCopy];
            else [VIDEOS_KECHUYEN addObjectsFromArray:results];
            break;
        case IS_CARTOON:
            if (typeOfResultThis == TYPE_OF_RESULT_NORMAL)
              VIDEOS_HOATHINH = [results mutableCopy];
            else [VIDEOS_HOATHINH addObjectsFromArray:results];
            break;
        default:
            if (typeOfResultThis == TYPE_OF_RESULT_NORMAL)
            VIDEOS_SEARCH_RESULTS = [results mutableCopy];
            else
                [VIDEOS_SEARCH_RESULTS addObjectsFromArray:results];
            break;
    }
    //[self.ViewListCollection setHidden:NO];
    [self resetStatusLoadPage];
    if (nextPageTokenThis) nextPageToken = nextPageTokenThis;
    if (prvPageTokenThis) prvPageTokenThis = prvPageTokenThis;
    isLoadFinish=YES;
    [self.listViewColectionView reloadData];
    if (isTheFirstTime) isTheFirstTime = NO;
    else
    [self ShowViewScroll];
    [MBProgressHUD hideHUDForView:self.listViewColectionView animated:YES];
   }


- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    NSLog(@"playerViewDidBecomeReady");
    [MBProgressHUD hideHUDForView:self.playerView animated:NO];
    
    
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error {
      NSLog(@"receivedError");
}
- (void ) checkNetworkStatus {
        if (!isLoadedJson) {
            [self loadDataJson: BaseURLStringDropBox_1];
            
        }
}

- (void) checkDurationTime {
   
 //   NSLog(@"TIMER: CheckDurationTime %@",self.playerView.duration);
    if ((self.playerView.currentTime > 0) && (self.playerView.duration) ){
          NSLog(@"TIMER: CheckDurationTime %i",self.playerView.duration);
    if ((self.playerView.currentTime > self.playerView.duration - 1)){
             if ([[NSUserDefaults standardUserDefaults] boolForKey:@"playRepeat"]) {
                [self.playerView setLoop:YES];
               [self.playerView seekToSeconds:0 allowSeekAhead:YES];
                }
             else {
                 [self.playerView seekToSeconds:0 allowSeekAhead:YES];
                 [self.playerView pauseVideo];

                [self ShowViewScroll];
            }
    }
    }
   }
- (void)  keyboardDisAppearOrShow {
    [self.searchBarView resignFirstResponder];
    _tap.enabled = NO;
}
- (void) loadDataJson: (NSString * ) baseURLString {
   
    if (isLoadedJson) return;
    
//    NSString *tmpStr = @"https://www.googleapis.com/youtube/v3/playlists?part=snippet&id=PLzB9NRNjGRgxH9c97gFLdUgE0Cpg8qXEr&key=AIzaSyA2THPKeUZagzEMi4pg65VqwZRoKWPQ2N0";
    NSURL *url = [NSURL URLWithString:baseURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    mPlayLists = [NSMutableArray array];
    
    //[mPlayLists init];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    // operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSMutableArray *tmpArray= dict[@"MyPlayLists"];
        for (int i=0;i<tmpArray.count;i++)
        {
            NSObject *tmpObject;
            tmpObject= [BaseUtils objectAtIndex:tmpArray:i];
            // NSLodropg([tmpObject valueForKey:@"playListId"]);
            if (tmpObject) {
            PlayListModel *mPlayListModel = [PlayListModel PlayListWithDictionary:
                                             @{ @"playListId":[tmpObject valueForKey:@"playListId"],
                                                @"playListName":[tmpObject valueForKey:@"playListName"],
                                                
                                                
                                                }];
          [mPlayLists  addObject:mPlayListModel];
            }
        }
        //[MBProgressHUD hideHUDForView:self.playerView animated:YES];
        isLoadedJson = YES;
        NSString *playListIdTmp=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :0]).playListId;
        NSString *playListIdFavorite=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :3]).playListId;
        [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListIdTmp: nextPageToken : prevPageToken : IS_GET_NORMAL_PAGE];
       
        // get favorite  if is the first time;
        if (mFavoriteVideos)
            if (mFavoriteVideos.count == 0)
                [self.getVideos getYouTubeFavoriteVideosWithService:self.youtubeService :playListIdFavorite];
        // [self.SimpleTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

       [BaseUtils showAlert:POPUP_TITLE_NETWORK message:POPUP_INFO_LOAD_DATA_ERROR];
        [MBProgressHUD hideHUDForView:self.playerView animated:YES];
        isLoadedJson = NO;

        if ([baseURLString isEqualToString:BaseURLStringDropBox_1 ])
              [self loadDataJson : BaseURLStringGoogle];
        else if ([baseURLString isEqualToString:BaseURLStringGoogle ])
                [self loadDataJson : BaseURLStringGit];
    }];
    
    // 5
    //[MBProgressHUD showHUDAddedTo:self.playerView animated:NO];
    [operation start];
    
}

#pragma mark - UISEARCHBAR Datasource
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //searchBar.text = self.currentTextInSearchBar;
    _tap.enabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    IS_OPEN_IN_TAB = IS_SEARCH;
    
    if (![searchBar.text isEqualToString:@""]) {
        //   self.currentTextInSearchBar = searchBar.text;
        [self resetStatusLoadPage];
        [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:NO];
        [self.getVideos searchYouTubeVideosWithService:self.youtubeService:searchBar.text : nextPageToken : prevPageToken : 0];
    }
}
- (void) resetStatusLoadPage {
    nextPageToken = nil;
    prevPageToken = nil;
}
#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    [view registerNib:[UINib nibWithNibName:@"VideoItemCollectCell" bundle:nil] forCellWithReuseIdentifier:@"collectCell"];
    NSInteger numberOf=0;
    switch (IS_OPEN_IN_TAB) {
        case IS_MUSIC:
            numberOf= [VIDEOS_AMNHAC count];
            break;
        case IS_STORY:
            numberOf= [VIDEOS_KECHUYEN count];
            break;
        case IS_CARTOON:
            numberOf= [VIDEOS_HOATHINH count];
            break;
        default:
            numberOf= [VIDEOS_SEARCH_RESULTS count];
            break;
    }
    return numberOf;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.listViewColectionView.frame.size.width/3-1, (self.listViewColectionView.frame.size.width/3)*85/100);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoItemCollectCell *cellScroll = [cv dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
    if (!cellScroll)
    {
        [cv registerNib:[UINib nibWithNibName:@"VideoItemCollectCell" bundle:nil] forCellWithReuseIdentifier:@"collectCell"];
        cellScroll= [cv dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
    }
    VideoData *vData;
    switch (IS_OPEN_IN_TAB) {
        case IS_MUSIC:
            vData = [ BaseUtils objectAtIndex: VIDEOS_AMNHAC :indexPath.row];
            break;
        case IS_STORY:
            vData = [ BaseUtils objectAtIndex: VIDEOS_KECHUYEN :indexPath.row];
            break;
        case IS_CARTOON:
            vData = [ BaseUtils objectAtIndex: VIDEOS_HOATHINH :indexPath.row];
            break;
        default:
            vData = [ BaseUtils objectAtIndex: VIDEOS_SEARCH_RESULTS :indexPath.row];
            break;
    }
    if (!vData) return
        cellScroll;
    cellScroll.titleLbl.trailingBuffer = cellScroll.frame.size.width;
    cellScroll.titleLbl.text = [vData getTitle];
    cellScroll.descriptionLb.text = [BaseUtils humanReadableFromYouTubeTime:vData.getDuration];
    if ([cellScroll.descriptionLb.text isEqualToString:@"(Unknown)"])
        [cellScroll.descriptionLb setHidden:YES];
    else [cellScroll.descriptionLb setHidden:NO];
    NSURL *url = [NSURL URLWithString:vData.getThumbUri];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"bg_loading.png"];
    
    // __weak UITableViewCell *weakCell = cell;
    
    [cellScroll.thumnailImg setImageWithURLRequest:request
                                  placeholderImage:placeholderImage
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                
                                               vData.fullImage = image;

                                               
                                               [cellScroll.thumnailImg setImage:vData.fullImage];
                                               //cellScroll.thumnailImg.image = image;
                                               [cellScroll setNeedsLayout];
                                               
                                           } failure:nil];
    
    return cellScroll;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 1.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 1.0;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoData *vidData;
    switch (IS_OPEN_IN_TAB) {
        case IS_MUSIC:
           vidData = [ BaseUtils objectAtIndex: VIDEOS_AMNHAC :indexPath.row];
            
            break;
        case IS_STORY:
    
            vidData = [ BaseUtils objectAtIndex: VIDEOS_KECHUYEN :indexPath.row];
            
            break;
        case IS_CARTOON:
           
            vidData = [ BaseUtils objectAtIndex: VIDEOS_HOATHINH :indexPath.row];
            
            break;
        default:
           
            vidData = [ BaseUtils objectAtIndex: VIDEOS_SEARCH_RESULTS :indexPath.row];
            
            break;
    }
    if (!vidData) return ;
    if ([vidData getYouTubeId]) {
      
    NSString *videoID= [vidData getYouTubeId];
        
    if (videoID) {
        
        CurrentVideoIdPlaying = videoID;
        [self.playerView loadWithVideoId:videoID playerVars:playerVars];
        [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
        [self.titleVideoPlaying setText:vidData.getTitle];
        
        //durationOfCurrentVideoPlaying = vidData.getDuration;
        
        [self buttonPressed:self.playButton];
        // status button when click play
        [self.playButton setSelected:YES ];
     
        [self buttonPressed:self.ViewUpDownbtn];
        [self saveToDBWhenClick:vidData];
        [self.sliderVideo setValue:0];
        tmpValueOfSlider= -1;
    }
}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
   // UIView *md= [scrollView.subviews objectAtIndex:1];
    //if ([scrollView.subviews objectAtIndex:1])
    if (scrollView == self.listViewColectionView) {
   
    if ((int)scrollView.contentOffset.y >= (int )scrollView.contentSize.height - (int)self.listViewColectionView.frame.size.height)
    {
        //[scrollView setScrollEnabled:NO];
        NSString *playListId;
        if ( IS_OPEN_IN_TAB != IS_SEARCH ) {
            playListId=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :IS_OPEN_IN_TAB-1]).playListId;
            
        }
        if (isLoadFinish)
        switch (IS_OPEN_IN_TAB) {
            case IS_SEARCH:
                if (VIDEOS_SEARCH_RESULTS.count < MAX_ITEM_IN_LIST) {
                   [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                [self.getVideos searchYouTubeVideosWithService:self.youtubeService:nil : nextPageToken : nil : IS_SEARCH_NEXT_PAGE];
                 isLoadFinish=NO;
                }
                break;
            
            default:
                switch (IS_OPEN_IN_TAB) {
                    case IS_MUSIC:
                        if (VIDEOS_AMNHAC.count > MAX_ITEM_IN_LIST) break;
                        else  {
                            if (nextPageToken) {
                        [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListId: nextPageToken : prevPageToken : IS_SEARCH_NEXT_PAGE];
                        [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                            }
                        }
                        break;
                    case IS_STORY:
                        if (VIDEOS_KECHUYEN.count > MAX_ITEM_IN_LIST) break;
                        else {
                              if (nextPageToken) {
                            [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListId: nextPageToken : prevPageToken : IS_SEARCH_NEXT_PAGE];
                            [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                              }
                        }
                        break;
                    case IS_CARTOON:
                        if (VIDEOS_HOATHINH.count > MAX_ITEM_IN_LIST) break;
                        else
                        {
                              if (nextPageToken) {
                            [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListId: nextPageToken : prevPageToken : IS_SEARCH_NEXT_PAGE];
                            [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                              }
                        }
                        break;
                    default:
                        break;
                }

                 //[self.getVideos getYouTubeVideosWithService:self.youtubeService:playListId: nextPageToken : prevPageToken : 0];
                 isLoadFinish=NO;
                
                break;
        }
        
        
        //LOAD MORE
        // you can also add a isLoading bool value for better dealing :D
    }
    else {
        NSLog(@"%f",scrollView.contentOffset.y);
        NSLog(@"%f",scrollView.contentSize.height);
        NSLog(@"%f",self.listViewColectionView.frame.size.height);
    }
    }
}

#pragma mark - UITableView Datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView==self.mListVideo) {
        mVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"mVideoCell" bundle:nil] forCellReuseIdentifier:@"videoCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];

        }

        FavoriteVideoDetail *vData = [BaseUtils objectAtIndex: [super mFavoriteVideos] :indexPath.row] ;
        if (!vData) return cell;
        cell.titleLabel.trailingBuffer = cell.titleLabel.frame.size.width;
        cell.titleLabel.text = vData.videoName;
        NSLog([NSString stringWithFormat:@" width of cell table : %f ", cell.frame.size.width]);
        NSLog([NSString stringWithFormat:@" heigh of cell table : %f ", cell.frame.size.height]);
       // NSLog([NSString stringWithFormat:@" %f ", cell.titleLabel.frame.size.width]);
        if (![[BaseUtils humanReadableFromYouTubeTime:vData.videoDuration] isEqualToString:@"(Unknown)"]) {
            [cell.descriptionLabel setHidden:NO];
            cell.descriptionLabel.text =[BaseUtils humanReadableFromYouTubeTime:vData.videoDuration];
        } else {
            [cell.descriptionLabel setHidden:YES];
        }
        cell.videoId = vData.videoId;
         [cell setNeedsLayout];
        NSURL *url = [NSURL URLWithString:vData.thumnailUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImage *placeholderImage = [UIImage imageNamed:@"bg_loading.png"];
        
        [cell.backgroundImage setImageWithURLRequest:request
                                    placeholderImage:placeholderImage
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 
                                                 NSLog(@"image download: %f %f",image.size.width,image.size.height);
                                                 NSLog(@"cell sizde: %f %f",cell.backgroundImage.frame.size.width,cell.backgroundImage.frame.size.height);
                                                 
                                                 UIGraphicsBeginImageContext(CGSizeMake(cell.backgroundImage.frame.size.width,cell.backgroundImage.frame.size.height
                                                                                        ));
                                                 //vData.fullImage = image;
                                                 [ image drawInRect:
                                                  CGRectMake(0, 0, cell.backgroundImage.frame.size.width,cell.backgroundImage.frame.size.height)];
                                                 UIImage *tmpImage = [[UIImage alloc]init];
                                                 tmpImage = UIGraphicsGetImageFromCurrentImageContext();
                                                 UIGraphicsEndImageContext();
                                                 
                                                 [cell.backgroundImage setImage:image];

                                                 
                                             } failure:nil];

        return cell;
    } else {
    
                if (indexPath.row > 0)
                {
                    tblCellMenu * cell = [tableView dequeueReusableCellWithIdentifier:@"tblCellMenuID"];
                    if (!cell)
                    {
                        [tableView registerNib:[UINib nibWithNibName:@"tblCellMenu" bundle:nil] forCellReuseIdentifier:@"tblCellMenuID"];
                        cell = [tableView dequeueReusableCellWithIdentifier:@"tblCellMenuID"];
                        
                    }
                  
                    
                    [cell.titleItemOfMenu setTextColor:[UIColor whiteColor]];
                    cell.titleItemOfMenu.text = [BaseUtils objectAtIndex:[mMenuItems mutableCopy] : indexPath.row];
                    //NSLog( [mMenuItems objectAtIndex:indexPath.row]);
                   
                    return cell;
                } else {
                      tbvCellMenu  * cell = [tableView dequeueReusableCellWithIdentifier:@"tbvCellMenu"];
                    if (!cell)
                    {
                        [tableView registerNib:[UINib nibWithNibName:@"tbvCellMenu" bundle:nil] forCellReuseIdentifier:@"tbvCellMenu"];
                        cell = [tableView dequeueReusableCellWithIdentifier:@"tbvCellMenu"];
                        
                    }
                    
                   cell.view_switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
                    if (indexPath.row == 0) {
                    
                    [cell.view_switch setOn: [[NSUserDefaults standardUserDefaults]boolForKey:@"playRepeat" ]];
                                             }
                  
                    
                    cell.index = indexPath.row;
                    [cell.lblContent setTextColor:[UIColor whiteColor]];
                   // [cell.lblContent setFont:[UIFont fontWithName: size:<#(CGFloat)#>]];
                    cell.lblContent.text = [BaseUtils objectAtIndex:[mMenuItems mutableCopy] : indexPath.row];
                    //
                    return cell;
                
                }
        
    }
    
}
-(CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==self.tbvMenu)
    {
        return self.MenuView.frame.size.height/10;
    } else {
        return 5;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView==self.tbvMenu)
    {
        UILabel *lbl = [[UILabel alloc] init];
        //[lbl setFrame:CGRectMake(0, 0, self.MenuView.frame.size.width, self.MenuView.frame.size.height/10)];
        lbl.textAlignment = UITextAlignmentCenter;
        //lbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        lbl.text = @"MENU";
        lbl.textColor = [UIColor whiteColor];
        lbl.shadowColor = [UIColor grayColor];
        lbl.shadowOffset = CGSizeMake(0,1);
        //  lbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"my_head_bg"]];
        lbl.alpha =1;
        return lbl;
    }
    else {
        UIView *headerView = [[UIView alloc]init];
        [ headerView setFrame:CGRectMake(0, 0, 0, 0)];
        return headerView;
    };
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==self.mListVideo) {
        return [[super mFavoriteVideos] count];
    } else {
        return 4;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.mListVideo) {
        NSLog(@"heightForRowAtIndexPath table video %f", tableView.frame.size.width);
       
        return tableView.frame.size.width*80/100;
       // return 100;
    } else {
               return self.view.frame.size.height/10;
            }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView == self.mListVideo) {
       // [tableView deselectRowAtIndexPath:indexPath animated:NO];
        FavoriteVideoDetail *vidData = (FavoriteVideoDetail *)[ BaseUtils objectAtIndex:[super mFavoriteVideos]:indexPath.row];
        if (!vidData) return ;
        NSString *videoID= vidData.videoId;
        if ((videoID)&&(vidData)) {
            CurrentVideoIdPlaying = videoID;
            [self.playerView loadWithVideoId:videoID playerVars:playerVars];
            [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
            [self.titleVideoPlaying setText:vidData.videoName];
        
            [self.playButton setSelected:YES ];
          
          
             tmpValueOfSlider= -1;
            [self hideViewScroll];
           
            
        }
    } else {
        switch (indexPath.row) {
                
            
            case 1:
                break;
            case 2:
                
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
                [self.navigationController setNavigationBarHidden:NO];
                [[self navigationController] pushViewController:[self createAuthController] animated:YES];
                
                break;
            case 3:
                [[self navigationController] pushViewController:mVCAbout animated:YES];
                break;

            default:
                break;
        }
        
    }
    
}
#pragma mark  funtion
- (void) saveToDBWhenClick : (VideoData*) vData {
    NSDictionary *mDic= @{@"videoId": vData.getYouTubeId,
                          @"videoName": vData.getTitle,
                          @"videoDesription": @"",
                          @"videoDuration": vData.getDuration,
                          @"thumnailUrl":vData.getThumbUri,
                          @"position":@(0),
                          @"deleted":@"FALSE",
                          };
    
    FavoriteVideoDetail *mFavoriteItem = [[FavoriteVideoDetail alloc]initWithDictionary:mDic];
    if ([self saveToFavorite:mFavoriteItem]) {
        if ([self loadAllFavoriteVideosFromDB]) {
            [self.mListVideo reloadData];
        }
    }
    
}
- (void) hideSeekingView {
    [self.viewButonSeeking setAlpha:1];
    [UIView animateWithDuration:1.f animations:^{
        //[self.view layoutIfNeeded];
        [self.viewButonSeeking setAlpha:0];
    }];
}
- (IBAction)buttonPlayerViewFace:(id)sender{
//    if (sender == self.playerViewFace)
//    {
//        [self.viewButonSeeking setAlpha:0];
//        [UIView animateWithDuration:1.f animations:^{
//            [self.viewButonSeeking setAlpha:1];
//        }];
//      
//    } else if (sender == self.playButton) {
//        if (self.playButton.isSelected) {
//            [self.playButton setSelected:NO];
//            [self.playerView pauseVideo];
//            
//            
//        } else {
//            [self.playButton setSelected:YES];
//            //  [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
//            [self.playerView playVideo];
//        }
//        [timerSeekingView invalidate];
//        timerSeekingView =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideSeekingView) userInfo:nil repeats:NO];
//        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDurationTime) userInfo:nil repeats:YES];
//    }
}
- (IBAction)setProgress:(UISlider *)sender {
    // self.progressBar.progress = [sender value];
    NSLog(@"%f",[sender value]);
    if ([self.playerView currentTime]>0)
        [self.playerView seekToSeconds:([sender value]*[self.playerView duration]) allowSeekAhead:YES];
    tmpValueOfSlider=[sender value] - 0.0000001;
    [timerSeekingView invalidate];
     timerSeekingView =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideSeekingView) userInfo:nil repeats:NO];
}
- (void) HideMenuView {
    self.trailingOfMenuView.constant =  -(self.MenuView.frame.size.width);
    NSLog(@"%f," ,self.ViewListTable.frame.size.width);
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
        
    }];
}
- (void) ShowMenuView {
    self.trailingOfMenuView.constant = 0;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
        
    }];
}

- (IBAction)buttonPressed:(id)sender {
    
    if (sender == self.ViewUpDownbtn) {
        //[self appendStatusText:@"Loading previous video in playlist\n"];
        if (!self.ViewUpDownbtn.isSelected) {
            [self.ViewUpDownbtn setSelected:YES];
             [self ShowViewScroll];
            if ((isLoadedJson)&& (mPlayLists))
                if (VIDEOS_AMNHAC.count == 0) {
                    NSString *playListIdTmp=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :0]).playListId;
                    [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListIdTmp: nextPageToken : prevPageToken : IS_GET_NORMAL_PAGE];
                }
            
            
        } else {
            [self.ViewUpDownbtn setSelected:NO];
           [self hideViewScroll];
            
        }
        
    }
    else  if (sender == self.btnSearch) {
        if ([self.searchBarView isHidden]) {
            [self.searchBarView setHidden:NO];
            [self.viewButtonTheLoai setHidden:YES];
            
            _tap.enabled = YES;
        } else {
           // if ([self.currentTextInSearchBar isEqualToString:@""]) {
                //[self searchBarSearchButtonClicked:self.searchBarView];
                [self keyboardDisAppearOrShow];
                [self.searchBarView setHidden:YES];
                [self.viewButtonTheLoai setHidden:NO];
                //_tap.enabled = NO;
          //  }
            
        }
    } else  if (sender == self.btnMenu) {
        if (self.btnMenu.isSelected) {
            [self.btnMenu setSelected:NO];
            [self HideMenuView];
            
            
        } else {
            [self.btnMenu setSelected:YES];
            //[self.tbvMenu reloadData];
            [self ShowMenuView];
            
        }
        
    }
    else
        if ([mPlayLists count]>0) {
            if (sender==self.btnAmNhac) {
                IS_OPEN_IN_TAB = IS_MUSIC;
                [self resetStatusLoadPage];
                if ([VIDEOS_AMNHAC count] < 1) {
                    NSString *playListIdTmp=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :0]).playListId;
                   [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                    [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListIdTmp: nextPageToken : prevPageToken : IS_GET_NORMAL_PAGE];
                } else {
                    [self.listViewColectionView  reloadData];
                }
                [self setSizeBtnTheLoaiWhenClick:sender];
            } else if (sender==self.btnKeChuyen) {
                IS_OPEN_IN_TAB = IS_STORY;
                [self resetStatusLoadPage];
                if ([VIDEOS_KECHUYEN count]< 1) {
                    NSString *playListIdTmp=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :1]).playListId;
                    [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                    [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListIdTmp: nextPageToken : prevPageToken : IS_GET_NORMAL_PAGE];
                }else {
                    [self.listViewColectionView  reloadData];
                }
                [self setSizeBtnTheLoaiWhenClick:sender];
            } else if (sender==self.btnHoatHinh) {
                IS_OPEN_IN_TAB = IS_CARTOON;
                [self resetStatusLoadPage];
                if ([VIDEOS_HOATHINH count]< 1) {
                   NSString *playListIdTmp=( (PlayListModel*)[BaseUtils objectAtIndex:mPlayLists :2]).playListId;
                    [MBProgressHUD showHUDAddedTo:self.listViewColectionView animated:YES];
                    [self.getVideos getYouTubeVideosWithService:self.youtubeService:playListIdTmp: nextPageToken : prevPageToken : IS_GET_NORMAL_PAGE];
                }else {
                    [self.listViewColectionView  reloadData];
                }
                [self setSizeBtnTheLoaiWhenClick:sender];
            }
        } // chheck mPlayList
    
    
}
- (void) setSizeBtnTheLoaiWhenClick : (id)sender {
   
    float widthNomarl= 50;
    float widthSeleted= 60;
    float bottomNomarl= 10;
    float bottomSeleted= 0;
    float leading = 5;
    float trailing = 5;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        widthNomarl= 75;
        widthSeleted= 85;
//        bottomNomarl = 
//        bottomSeleted
        leading = 10;
        trailing = 10;
    }
    if (sender==self.btnAmNhac) {
        self.widthAmNhac.constant=widthSeleted;
        self.bottomAmNhac.constant=bottomSeleted;
        self.withOfKeChuyen.constant=widthNomarl;
        self.bottonKeChuyen.constant=bottomNomarl;
        self.widthHoatHinh.constant=widthNomarl;
        self.bottomHoatHInh.constant=bottomNomarl;
        self.leadingAmNhac.constant=bottomSeleted;
        self.trailingHoatHinh.constant=trailing;
    } else if (sender==self.btnKeChuyen) {
        self.widthAmNhac.constant=widthNomarl;
        self.bottomAmNhac.constant=bottomNomarl;
        self.withOfKeChuyen.constant=widthSeleted;
        self.bottonKeChuyen.constant=bottomSeleted;
        self.widthHoatHinh.constant=widthNomarl;
        self.bottomHoatHInh.constant=bottomNomarl;
    } else {
        self.widthAmNhac.constant=widthNomarl;
        self.bottomAmNhac.constant=bottomNomarl;
        self.withOfKeChuyen.constant=widthNomarl;
        self.bottonKeChuyen.constant=bottomNomarl;
        self.widthHoatHinh.constant=widthSeleted;
        self.bottomHoatHInh.constant=bottomSeleted;
        self.trailingHoatHinh.constant=bottomSeleted;
        self.leadingAmNhac.constant=leading;
    }
   
    [self.viewButtonTheLoai setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.f animations:^{
        [self.view layoutIfNeeded];
        
    }];
}
- (void) hideViewScroll {
    self.bottomSpaceListVideo.constant = self.view.frame.size.height;
    
    self.heighButtonTheLoai.constant = 0;
    [self.ViewListCollection setAlpha:1];
    //self.bottomSpaceListVideo.constant -= self.view.frame.size.height;
    [self.ViewListCollection setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.f animations:^{
        [self.ViewListCollection layoutIfNeeded];
        [self.ViewListCollection setAlpha:0];
    }];
    
}
- (void) ShowViewScroll {
    // self.topSpaceListVideo.constant = 50;
    self.bottomSpaceListVideo.constant = self.btnMenu.frame.size.height+5;
    self.heighButtonTheLoai.constant = 60;
    [self.ViewListCollection setAlpha:0];
    [self.ViewListCollection setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.f animations:^{
        [self.ViewListCollection setAlpha:1];
        [self.ViewListCollection layoutIfNeeded];
        
    }];
}
// Helper to check if user is authorized
#pragma mark - Anthorization
- (BOOL)isAuthorized {
    return [((GTMOAuth2Authentication *)self.youtubeService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to YouTube.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the YouTube service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [BaseUtils showAlert:@"Authentication Error" message:error.localizedDescription];
        self.youtubeService.authorizer = nil;
        [self viewDidLoad];
    } else {
        self.youtubeService.authorizer = authResult;
        //[self isAuthorized];
        [self viewDidLoad];
        
        
    }
}
- (void)deleteVideoFromFavorite:(NSNotification *) notification {
      if([notification.name isEqual:@"deleteVideoFromFavorite"] && notification.object != self) {
      
          NSString * videoId = ((mVideoCell *)notification.object).videoId;
          
          BOOL success = [[DBManager getSharedInstance] removeVideo:videoId];
          if (success ) {
          
              if ([self loadAllFavoriteVideosFromDB]) {
                  [self.mListVideo reloadData];
              }
          }
      }
    
}

- (void)receivedNotification:(NSNotification *) notification {
//    if([notification.name isEqual:@"playRepeat"] ) {
//      
//        
//        [[NSUserDefaults standardUserDefaults] setBool:(BOOL)notification.object forKey:@"playRepeat" ];
//        
//    } else
//        if ([notification.name isEqual:@"playBackground"] ) {
//            [[NSUserDefaults standardUserDefaults] setBool:(BOOL)notification.object forKey:@"playBackground" ];
//
//        }
//        
//        
}
- (void)receivedPlaybackStartedNotification:(NSNotification *) notification {
    //  if([notification.name isEqual:@"Playback started"] && notification.object != self) {
    //      [self.playerViewFace setHidden:NO];
    //      [self.playButton setSelected:YES];
    //      [self.playerView playVideo];
    //[self.playerView setHidden:NO];
    
}


@end