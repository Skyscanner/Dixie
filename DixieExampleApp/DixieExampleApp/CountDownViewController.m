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

#import "CountDownViewController.h"

@interface CountDownViewController ()
{

    Dixie *myDixie;
    DixieProfileEntry *previousEntry;
    
}

@end

@implementation CountDownViewController

- (void) viewDidLoad {
    
    // Set Halley's Comet next perihelion predicted (28 July 2061)
    nextHalleyVisit = [NSDate dateWithTimeIntervalSince1970:2889777600];
    
    // Start timer
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    // Initialise Dixie
    myDixie = [Dixie new];

}

- (void) viewDidDisappear:(BOOL)animated {
    
    // Revert Dixie when change a Tab - next time it will start with the original state
    myDixie.Revert();
}

- (void) updateTime {
    
    
    // Check if it's future date or not
    NSComparisonResult result = [[NSDate date] compare:nextHalleyVisit];

    // Prepare date variables
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    int units = NSCalendarUnitYear | NSCalendarUnitDay;
    NSDateComponents* components = [calendar components:units fromDate:[NSDate date] toDate:nextHalleyVisit options:0];

    switch (result) {
        case NSOrderedAscending:
            // Update countdown timer
            [self.countdownLabel setText:[NSString stringWithFormat:@"%ld%c - %ld%c", (long)[components year], 'y', (long)[components day], 'd']];
            break;
        
        case NSOrderedDescending:
            self.countdownLabel.text=@"Already started/ended.";
            break;
            
        case NSOrderedSame:
            self.countdownLabel.text=@"It's just starting now!";
            break;
        
        default:
            NSLog(@"Error Comparing Dates");
            break;
    }
    
    // Update actual date timer
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    self.actualDate.text = [dateFormatter stringFromDate:now];
    
}

- (IBAction)tapUpdateTimeButton:(id)sender {
    
    // Generate a date between -10000 and +10000 days
    int randDays = arc4random() % 10000;
    if ((arc4random() % 2) == 1) {
        randDays = randDays * -1;
    }
    NSDate* testDate = [NSDate dateWithTimeIntervalSinceNow:86000*randDays];
    
    // Creating a Constant provider
    DixieBaseChaosProvider* provider = [DixieConstantChaosProvider constant:testDate];

    // Creating an Entry to change [NSDate date]
    DixieProfileEntry* entry = [DixieProfileEntry entry:[NSDate class] selector:@selector(date) chaosProvider:provider];
    
    // Revert the previously set entry
    if (previousEntry != nil) {
        myDixie.RevertIt(previousEntry);
    }
    
    // Set and apply the Entry
    myDixie.Profile(entry).Apply();
    
    // Save the previous entry - to be able to revert it
    previousEntry = entry;
}

- (IBAction)revertDixie:(id)sender {
    
    // Revert the previosuly set Entry
    myDixie.RevertIt(previousEntry);
}

@end
