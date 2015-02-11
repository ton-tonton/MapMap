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

@interface MapViewController () <GMSMapViewDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) GMSCameraPosition *camera;
@property (nonatomic) GMSMapView *mapView_;
@property (nonatomic) GMSMarker *mark1;
@property (nonatomic) GMSMarker *mark2;

@end

@implementation MapViewController

#pragma mark - initial

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;

    [_locationManager startUpdatingLocation];
    
    CLLocation *location = _locationManager.location;
    _camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                          longitude:location.coordinate.longitude
                                               zoom:17];
    
    self.mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
    self.mapView_.myLocationEnabled = YES;
    self.mapView_.delegate = self;
    
    self.view = self.mapView_;
    
    NSLog(@"User's location: %@", [self deviceLocation]);
}

- (NSString *)deviceLocation
{
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude];
    return theLocation;
}

#pragma mark - GMSMapViewDelegate

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"you tap at %f, %f", coordinate.latitude, coordinate.longitude);
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    
    if (!self.mark1) {
        self.mark1 = [GMSMarker markerWithPosition:position];
        self.mark1.title = @"Mark 1";
        self.mark1.appearAnimation = kGMSMarkerAnimationPop;
        self.mark1.draggable = YES;
        
        self.mark1.map = self.mapView_;
        
    } else if (!self.mark2) {
        
        self.mark2 = [GMSMarker markerWithPosition:position];
        self.mark2.title = @"Mark 2";
        self.mark2.appearAnimation = kGMSMarkerAnimationPop;
        self.mark2.draggable = YES;

        self.mark2.map = self.mapView_;
    }
}

-(void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    CLLocationCoordinate2D coo = marker.position;
    NSLog(@"%@: new position lat:%f, lon:%f", marker.title, coo.latitude, coo.longitude);
}

@end
