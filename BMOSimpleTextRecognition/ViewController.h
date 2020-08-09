//
//  ViewController.h
//  BMOSimpleTextRecognition
//
//  Created by Breno Medeiros on 28/07/20.
//  Copyright © 2020 ProgramasBMO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <VisionKit/VisionKit.h>

@interface ViewController : UIViewController<VNDocumentCameraViewControllerDelegate> {
    IBOutlet UITextView *textView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction)scanReceipts:(id)sender;



@end

