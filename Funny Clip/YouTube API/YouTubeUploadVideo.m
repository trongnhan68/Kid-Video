//
//  YouTubeUploadVideo.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/29/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "YouTubeUploadVideo.h"
#import "VideoData.h"
#import "UploadController.h"
#import "BaseUtils.h"

// Thumbnail image size.
static const CGFloat kCropDimension = 44;

@implementation YouTubeUploadVideo


- (void)uploadYouTubeVideoWithService:(GTLServiceYouTube *)service
                             fileData:(NSData*)fileData
                                title:(NSString *)title
                          description:(NSString *)description {
    
    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet alloc];
    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus alloc];
    status.privacyStatus = @"public";
    snippet.title = title;
    snippet.descriptionProperty = description;
    snippet.tags = [NSArray arrayWithObjects:DEFAULT_KEYWORD,[UploadController generateKeywordFromPlaylistId:PLAYLIST_SONG], nil];
    video.snippet = snippet;
    video.status = status;
    
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:fileData MIMEType:@"video/*"];
    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video part:@"snippet,status" uploadParameters:uploadParameters];
    
    UIAlertView *waitIndicator = [BaseUtils showWaitIndicator:@"Uploading to YouTube"];
    
    [service executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLYouTubeVideo *insertedVideo, NSError *error) {
                    [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                    if (error == nil)
                    {
                        NSLog(@"File ID: %@", insertedVideo.identifier);
                        [BaseUtils showAlert:@"YouTube" message:@"Video uploaded!"];
                        [self.delegate uploadYouTubeVideo:self didFinishWithResults:insertedVideo];
                        return;
                    }
                    else
                    {
                        NSLog(@"An error occurred: %@", error);
                        [BaseUtils showAlert:@"YouTube" message:@"Sorry, an error occurred!"];
                        [self.delegate uploadYouTubeVideo:self didFinishWithResults:nil];
                        return;
                    }
                }];
}

@end
