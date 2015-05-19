#import <Foundation/Foundation.h>

#ifdef LOG_LEVEL_DEF
    #undef LOG_LEVEL_DEF
#endif
#define LOG_LEVEL_DEF kEditorLogLevel

extern const DDLogLevel kEditorLogLevel;
