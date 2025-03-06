import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "com.tasbihly.counter",
                                    displayName: "Tasbih Counter",
                                    supportedFamilies: [.circularSmall, .modularSmall, .utilitarianSmall])
        ]
        handler(descriptors)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population 
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let counter = UserDefaults.standard.integer(forKey: "counter")
        let target = UserDefaults.standard.integer(forKey: "target")
        
        let template: CLKComplicationTemplate
        switch complication.family {
        case .circularSmall:
            let template1 = CLKComplicationTemplateCircularSmallStackText()
            template1.line1TextProvider = CLKTextProvider(format: "\(counter)")
            template1.line2TextProvider = CLKTextProvider(format: "\(counter % target)")
            template = template1
            
        case .modularSmall:
            let template2 = CLKComplicationTemplateModularSmallStackText()
            template2.line1TextProvider = CLKTextProvider(format: "\(counter)")
            template2.line2TextProvider = CLKTextProvider(format: "\(counter % target)")
            template = template2
            
        case .utilitarianSmall:
            let template3 = CLKComplicationTemplateUtilitarianSmallFlat()
            template3.textProvider = CLKTextProvider(format: "\(counter)/\(target)")
            template = template3
            
        default:
            handler(nil)
            return
        }
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
    
    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template: CLKComplicationTemplate
        switch complication.family {
        case .circularSmall:
            let template1 = CLKComplicationTemplateCircularSmallStackText()
            template1.line1TextProvider = CLKTextProvider(format: "33")
            template1.line2TextProvider = CLKTextProvider(format: "12")
            template = template1
            
        case .modularSmall:
            let template2 = CLKComplicationTemplateModularSmallStackText()
            template2.line1TextProvider = CLKTextProvider(format: "33")
            template2.line2TextProvider = CLKTextProvider(format: "12")
            template = template2
            
        case .utilitarianSmall:
            let template3 = CLKComplicationTemplateUtilitarianSmallFlat()
            template3.textProvider = CLKTextProvider(format: "33/99")
            template = template3
            
        default:
            handler(nil)
            return
        }
        
        handler(template)
    }
} 