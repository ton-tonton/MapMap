//
//  DirectionService.m
//  MapMap
//
//  Created by Tawatchai Sunarat on 2/13/15.
//  Copyright (c) 2015 pddk. All rights reserved.
//

#import "DirectionService.h"

@interface DirectionService ()

@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) id delegate;

@property (nonatomic) BOOL sensor;
@property (nonatomic) BOOL alternatives;
@property (nonatomic) NSURL *directionsURL;
@property (nonatomic) NSArray *waypoints;

@end

@implementation DirectionService

static NSString *const kDirectionsURL = @"https://maps.googleapis.com/maps/api/directions/json?";

-(void)setDirectionQuery:(NSDictionary *)object withSelector:(SEL)selector withDelegate:(id)delegate
{
    _selector =  selector;
    _delegate = delegate;
    
    _waypoints = [object objectForKey:@"waypoints"];
    NSUInteger waypointCount = [_waypoints count];
    NSUInteger destinationPosition = waypointCount - 1;
    
    NSString *origin = [_waypoints objectAtIndex:0];
    NSString *destination = [_waypoints objectAtIndex:destinationPosition];
    NSString *sensor = [object objectForKey:@"sensor"];
    
    //set paramiters: origin, destination, sensor
    NSMutableString *URL = [NSMutableString stringWithFormat:@"%@origin=%@&destination=%@&sensor=%@", kDirectionsURL, origin, destination, sensor];
    
    if (waypointCount > 2) {
        [URL appendString:@"&waypoints=optimize:true"];
        
        for (int i = 1; i < waypointCount - 2; i++) {
            [URL appendString:@"|"];
            [URL appendString:[_waypoints objectAtIndex:i]];
        }
    }
    
    URL = [NSMutableString stringWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    NSLog(@"url encode:%@", URL);
    
    _directionsURL = [NSURL URLWithString:URL];
    
    [self retrieveDirections];
}

-(void)retrieveDirections
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSData *data = [NSData dataWithContentsOfURL:_directionsURL];
        [self fetchedData:data];
    });
}

-(void)fetchedData:(NSData *)data
{
    NSError *err;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    
    [_delegate performSelector:_selector withObject:json];
}

@end
