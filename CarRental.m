//
//  CarRental.m
//  objective-c_final
//
//  Created by Colby Boucher on 4/18/24.
//

#import <Foundation/Foundation.h>
#import "CarRental.h"

@implementation CarRental {
    NSCalendar *_calendar;
    NSDateFormatter *_dateFormat;
    NSString *_filePath;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _calendar = [NSCalendar currentCalendar];
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setDateFormat:@"MM-dd-yyyy"];
        _filePath = @"rental_info.txt";
    }
    return self;
}

- (void)menu {
    NSLog(@"Car Rental System Menu");
    NSLog(@"1. Rent a car");
    NSLog(@"2. Return a car");
    NSLog(@"3. Display all information");
    NSLog(@"4. Clear file");
    NSLog(@"5. Exit");
    
    NSLog(@"Enter your choice:");
    NSInteger choice;
    scanf("%ld", &choice);
    
    switch (choice) {
        case 1:
            [self rentCar];
            break;
        case 2:
            [self returnCar];
            break;
        case 3:
            [self displayAllInfo];
            break;
        case 4:
            [self clearFileConfirmation];
            break;
        case 5:
            exit(0);
        default:
            NSLog(@"Invalid choice. Please enter a number between 1 and 5.");
            break;
    }
}

- (void)rentCar {
    NSLog(@"Enter your first name:");
    NSString *firstName = [self getInput];
    
    NSLog(@"Enter your last name:");
    NSString *lastName = [self getInput];
    
    NSLog(@"Enter your age:");
    NSInteger age = [self getIntegerInput];
    
    NSLog(@"Do you have a valid driver's license? (yes/no)");
    NSString *hasLicense = [self getInput];
    
    if (age < 21 || ![hasLicense isEqualToString:@"yes"]) {
        NSLog(@"Rental declined. You must be 21 or older with a valid driver's license.");
        return;
    }
    
    NSLog(@"Are you paying online now? (yes/no)");
    NSString *payOnline = [self getInput];
    
    NSString *creditCard = [payOnline isEqualToString:@"yes"] ? [self getInput] : @"N/A";
    
    NSLog(@"Enter the make of the car:");
    NSString *carMake = [self getInput];
    
    NSLog(@"Enter the model of the car:");
    NSString *carModel = [self getInput];
    
    NSDate *rentDate;
    NSDate *returnDate;
    
    BOOL rentDateValid = NO;
    while (!rentDateValid) {
        NSLog(@"Enter the rent date (MM-dd-yyyy):");
        rentDate = [self getDateInput];
        if (!rentDate) {
            NSLog(@"Invalid rent date format. Please use MM-dd-yyyy.");
            continue;
        }
        
        if (![self isCarAvailableForRent:carMake model:carModel startDate:rentDate endDate:rentDate]) {
            NSLog(@"Vehicle is already booked for the specified rent date. Please choose a different rent date.");
            continue;
        }
        
        rentDateValid = YES;
    }
    
    NSLog(@"Enter the return date (MM-dd-yyyy):");
    returnDate = [self getDateInput];
    if (!returnDate) {
        NSLog(@"Invalid return date format. Please use MM-dd-yyyy.");
        return;
    }
    
    if ([returnDate compare:rentDate] != NSOrderedDescending) {
        NSLog(@"Invalid return date. Return date must be after the rent date.");
        return;
    }
    
    NSInteger rentalPrice = [self calculateRentalPriceWithStartDate:rentDate endDate:returnDate];
    
    NSLog(@"Rental price: $%ld", (long)rentalPrice);
    
    NSString *rentalInfo = [NSString stringWithFormat:@"Name: %@ %@, Age: %ld, License: %@, Credit Card: %@, Car: %@ %@, Rent Date: %@, Return Date: %@, Price: $%ld\n", firstName, lastName, (long)age, hasLicense, creditCard, carMake, carModel, [_dateFormat stringFromDate:rentDate], [_dateFormat stringFromDate:returnDate], (long)rentalPrice];
    
    [self saveToFile:rentalInfo];
}

- (void)returnCar {
    NSLog(@"Enter your first name:");
    NSString *firstName = [self getInput];
    
    NSLog(@"Enter your last name:");
    NSString *lastName = [self getInput];
    
    NSString *renterInfo = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString *fileContents = [self readFileContents];
    
    NSRange renterRange = [fileContents rangeOfString:renterInfo options:NSBackwardsSearch];
    
    if (renterRange.location == NSNotFound) {
        NSLog(@"Renter not found in records.");
        return;
    }
    
    NSRange nextRenterRange = [fileContents rangeOfString:@"\n" options:0 range:NSMakeRange(renterRange.location + 1, fileContents.length - (renterRange.location + 1))];
    if (nextRenterRange.location == NSNotFound) {
        nextRenterRange.location = fileContents.length;
    }
    
    NSRange renterRecordRange = NSMakeRange(renterRange.location, nextRenterRange.location - renterRange.location);
    NSString *renterRecord = [fileContents substringWithRange:renterRecordRange];
    
    NSString *returnedRecord = [renterRecord stringByAppendingString:@" [RETURNED]"];
    
    NSString *updatedFileContents = [fileContents stringByReplacingCharactersInRange:renterRecordRange withString:returnedRecord];
    
    [self writeFileContents:updatedFileContents];
    NSLog(@"Vehicle returned successfully.");
    
    NSString *pattern = @"Return Date: (\\d{2}-\\d{2}-\\d{4})";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:renterRecord options:0 range:NSMakeRange(0, renterRecord.length)];
    
    if (match) {
        NSRange returnDateRange = [match rangeAtIndex:1];
        NSString *returnDateString = [renterRecord substringWithRange:returnDateRange];
        NSDate *returnDate = [_dateFormat dateFromString:returnDateString];
        
        NSLog(@"Return date from record: %@", returnDate);
        NSLog(@"Current date and time: %@", [NSDate date]);
        
        if ([returnDate compare:[NSDate date]] == NSOrderedAscending) {
            NSLog(@"Vehicle returned late.");
            NSInteger lateDays = [self calculateLateDaysForReturn:returnDate];
            NSLog(@"Late days: %ld", (long)lateDays);
            NSLog(@"Late return penalty: $%ld", (long)(lateDays * 250));
        } else {
            NSLog(@"Vehicle returned on time.");
        }
    } else {
        NSLog(@"Return date not found in the record.");
    }
}

- (void)displayAllInfo {
    NSString *fileContents = [self readFileContents];
    NSLog(@"%@", fileContents);
}

- (void)clearFileConfirmation {
    NSLog(@"Are you sure you want to clear the file? (yes/no)");
    NSString *confirmation = [self getInput];
    
    if ([confirmation isEqualToString:@"yes"]) {
        [self clearFile];
    } else {
        NSLog(@"Clearing file canceled.");
    }
}

- (void)clearFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager removeItemAtPath:_filePath error:&error]) {
        NSLog(@"File cleared successfully.");
    } else {
        NSLog(@"Error clearing file: %@", error.localizedDescription);
    }
}

- (NSString *)getInput {
    char input[100];
    scanf("%s", input);
    return [NSString stringWithUTF8String:input];
}

- (NSInteger)getIntegerInput {
    NSInteger input;
    scanf("%ld", &input);
    return input;
}

- (NSDate *)getDateInput {
    char input[100];
    scanf("%s", input);
    return [_dateFormat dateFromString:[NSString stringWithUTF8String:input]];
}

- (NSString *)readFileContents {
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    if (!fileContents) {
        NSLog(@"Error reading file: %@", error.localizedDescription);
        return @"";
    }
    return fileContents;
}

- (BOOL)isCarAvailableForRent:(NSString *)make model:(NSString *)model startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *fileContents = [self readFileContents];
    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        if ([line containsString:[NSString stringWithFormat:@"Car: %@ %@", make, model]] && ![line containsString:@"[RETURNED]"]) {
            NSArray *fields = [line componentsSeparatedByString:@", "];
            NSString *rentDateString = @"";
            NSString *returnDateString = @"";
            
            for (NSString *field in fields) {
                if ([field hasPrefix:@"Rent Date:"]) {
                    rentDateString = [field substringFromIndex:[@"Rent Date: " length]];
                } else if ([field hasPrefix:@"Return Date:"]) {
                    returnDateString = [field substringFromIndex:[@"Return Date: " length]];
                }
            }
            
            NSDate *existingRentDate = [_dateFormat dateFromString:rentDateString];
            NSDate *existingReturnDate = [_dateFormat dateFromString:returnDateString];
            
            if (existingRentDate && existingReturnDate) {
                if ([startDate compare:existingReturnDate] == NSOrderedAscending &&
                    [endDate compare:existingRentDate] == NSOrderedDescending) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (NSInteger)calculateRentalPriceWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSInteger days = [_calendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0].day + 1;
    return days * 100;
}

- (NSInteger)calculateLateDaysForReturn:(NSDate *)returnDate {
    return [_calendar components:NSCalendarUnitDay fromDate:returnDate toDate:[NSDate date] options:0].day + 1;
}

- (void)saveToFile:(NSString *)content {
    NSString *fileContents = [self readFileContents];
    NSRange recordRange = [fileContents rangeOfString:content];
    
    if (recordRange.location != NSNotFound) {
        NSString *updatedFileContents = [fileContents stringByReplacingCharactersInRange:[fileContents lineRangeForRange:recordRange] withString:[content stringByAppendingString:@" [RETURNED]"]];
        [self writeFileContents:updatedFileContents];
        NSLog(@"Record updated in the file.");
    } else {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
        if (!fileHandle) {
            [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
        }
        
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
        NSLog(@"New record added to the file.");
    }
}

- (void)writeFileContents:(NSString *)content {
    NSError *error;
    if (![content writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"Error writing to file: %@", error.localizedDescription);
    }
}

@end
