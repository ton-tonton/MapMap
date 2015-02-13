//
//  MapViewController.m
//  MapMap
//
//  Created by Tawatchai Sunarat on 2/10/15.
//  Copyright (c) 2015 pddk. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "DirectionService.h"

@interface MapViewController () <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) GMSCameraPosition *camera;
@property (nonatomic) GMSMapView *mapView_;

@property (nonatomic) NSMutableArray *waypoints;
@property (nonatomic) NSMutableArray *waypointStrings;

@end

@implementation MapViewController

#pragma mark - initial

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _waypoints = [[NSMutableArray alloc] init];
        _waypointStrings = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [_locationManager startUpdatingLocation];
    NSLog(@"start update location");
    
    CLLocation *location = _locationManager.location;
    
    NSLog(@"ViewDidLoad %@", [self deviceLocation:location]);
    
    _camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                          longitude:location.coordinate.longitude
                                               zoom:17];
    
    self.mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
    self.mapView_.delegate = self;
    self.mapView_.myLocationEnabled = YES;
    
    self.view = self.mapView_;
}

#pragma mark - GMSMapViewDelegate

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"you tap at %f, %f", coordinate.latitude, coordinate.longitude);
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    NSString *positionString = [NSString stringWithFormat:@"%f,%f", position.latitude, position.longitude];
    [_waypointStrings addObject:positionString];
    
    static int count = 0;
    
    if (count < 2) {
        
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = [NSString stringWithFormat:@"Mark %d", ++count];
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.draggable = YES;
        
        marker.map = self.mapView_;
        [_waypoints addObject:marker];
        
        NSLog(@"%d", count);
        
        if ([_waypoints count] > 1) {
            NSLog(@"add direction...");
        
            NSString *sensor = @"false";
            NSArray *parameters = @[sensor, _waypointStrings];
            NSArray *keys = @[@"sensor", @"waypoints"];
            NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters forKeys:keys];
        
            NSLog(@"%@", query);
        
            DirectionService *ds = [[DirectionService alloc] init];
            SEL selector = @selector(addDirections:);
            [ds setDirectionQuery:query withSelector:selector withDelegate:self];
        }
    }
}

-(void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{  
    CLLocationCoordinate2D coo = marker.position;
    NSLog(@"%@: new position lat:%f, lon:%f", marker.title, coo.latitude, coo.longitude);
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"authorized");
        NSLog(@"authorization %@", [self deviceLocation:_locationManager.location]);
        
    } else {
        NSLog(@"other");
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    
    CLLocationCoordinate2D current = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    GMSCameraUpdate *updateCam = [GMSCameraUpdate setTarget:current];
    [_mapView_ animateWithCameraUpdate:updateCam];
    NSLog(@"update location %@", [self deviceLocation:location]);
}

- (NSString *)deviceLocation:(CLLocation *)location
{
    NSString *theLocation = [NSString stringWithFormat:@"lat: %f lon: %f", location.coordinate.latitude, location.coordinate.longitude];
    return theLocation;
}

#pragma mark - direction service

-(void)addDirections:(NSDictionary *)json
{
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = _mapView_;
}

@end
