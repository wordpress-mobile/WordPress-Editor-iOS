typedef NS_ENUM(NSInteger, WPLegacyEditorFormatAction) {
    WPLegacyEditorFormatActionMedia,
    WPLegacyEditorFormatActionBold,
    WPLegacyEditorFormatActionItalic,
    WPLegacyEditorFormatActionUnderline,
    WPLegacyEditorFormatActionDelete,
    WPLegacyEditorFormatActionLink,
    WPLegacyEditorFormatActionQuote,
    WPLegacyEditorFormatActionMore,
};

extern NSString * WPLegacyEditorFormatActionToTag(WPLegacyEditorFormatAction formatAction);
extern NSString * WPLegacyEditorFormatActionToName(WPLegacyEditorFormatAction formatAction);
