//
// Dixie
// Copyright 2015 Skyscanner Limited
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.

#import "MapViewController.h"

@implementation MapViewController {
    CLLocationManager *locationManager;
    
    Dixie *myDixie;
    DixieProfileEntry *previousEntry;
    
    NSArray *mockLocations;
    CLLocation *actualMockLocation;
    MKPointAnnotation *actualAnnocation;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Setup location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDistanceFilter:100];
    [locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = NO;
    
    // Set annotation
    actualAnnocation = [[MKPointAnnotation alloc] init];
    actualAnnocation.coordinate = locationManager.location.coordinate;
    [self.mapView addAnnotation:actualAnnocation];
    [self.mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
    
    // Initialise Dixie
    myDixie = [Dixie new];
    
    // Create mock locations
    CLLocation *Shanghai = [[CLLocation alloc] initWithLatitude:31.2 longitude:121.5];
    CLLocation *Moscow = [[CLLocation alloc] initWithLatitude:55.75 longitude:37.616667];
    CLLocation *Tokyo = [[CLLocation alloc] initWithLatitude:35.683333 longitude:139.683333];
    CLLocation *MexicoCity = [[CLLocation alloc] initWithLatitude:19.433333 longitude:-99.133333];
    CLLocation *NewYorkCity = [[CLLocation alloc] initWithLatitude:40.7127 longitude:-74.0059];
    CLLocation *London = [[CLLocation alloc] initWithLatitude:51.507222 longitude:-0.1275];
    CLLocation *RioDeJeneiro = [[CLLocation alloc] initWithLatitude:-22.908333 longitude:-43.196389];
    CLLocation *LosAngeles = [[CLLocation alloc] initWithLatitude:34.05 longitude:-118.25];
    mockLocations = [NSArray arrayWithObjects:Shanghai, Moscow, Tokyo, MexicoCity, NewYorkCity, London, RioDeJeneiro, LosAngeles, nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    
    // Revert Dixie when change a Tab - next time it will start with the original state
    myDixie.RevertIt(previousEntry);

    // Update map
    [self.mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
    actualAnnocation.coordinate = locationManager.location.coordinate;
    [locationManager stopUpdatingLocation];
}


- (IBAction)dixieChangeLocation:(id)sender {
    
    // Set mock location and annocation
    actualMockLocation = [mockLocations objectAtIndex:(arc4random() % 8)];
    [self.mapView setCenterCoordinate:actualMockLocation.coordinate animated:YES];
    actualAnnocation.coordinate = actualMockLocation.coordinate;
    
    // Create a block provider
    DixieBaseChaosProvider *provider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider,
                                                                        id victim,
                                                                        DixieCallEnvironment *environment) {
        // chaos: return with the actualMockLocation
        NSMutableArray* myArguments = [environment.arguments mutableCopy];
        NSArray *argument = [NSArray arrayWithObjects:actualMockLocation, nil];
        myArguments[1] = argument;
        environment.arguments = myArguments;

        // forward the chaos
        [chaosProvider forwardChaosOf:victim environment:environment to:[DixieNonChaosProvider new]];
        
    }];
    
    // Change locationManager's didUpdateToLocation:fromLocation: method
    DixieProfileEntry *entry = [DixieProfileEntry entry:[self class] selector:@selector(locationManager:didUpdateLocations:) chaosProvider:provider];
    
    // Revert the previously set entry
    if (previousEntry != nil) {
        myDixie.RevertIt(previousEntry);
    }
    
    // Set and apply the Entry
    myDixie.Profile(entry).Apply();
    
    // Save the previous entry - to be able to revert it
    previousEntry = entry;
    
    // Apply the chaos
    myDixie.Profile(entry).Apply();
    
    // Call locationManager to make sure that the didUpdateLocations is called
    [locationManager startUpdatingLocation];
}

- (IBAction)dixieRevertChanges:(id)sender {
    
    // Revert the previousy entry
    myDixie.RevertIt(previousEntry);

    // Reset Map
    [self.mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
    actualAnnocation.coordinate = locationManager.location.coordinate;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations: %@", locations);
    CLLocation *currentLocation = [locations objectAtIndex:0];
 
    if (currentLocation != nil) {

        // update the lon/lat labels
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        // update the annotation
        actualAnnocation.coordinate = currentLocation.coordinate;
        [self.mapView setCenterCoordinate:currentLocation.coordinate animated:YES];
    }
}

@end
