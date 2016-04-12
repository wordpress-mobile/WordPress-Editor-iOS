#import "WPLegacyEditorFormatAction.h"

NSString * WPLegacyEditorFormatActionToTag(WPLegacyEditorFormatAction formatAction) {
    switch (formatAction) {
        case WPLegacyEditorFormatActionMedia:
            return @"add_media";
        case WPLegacyEditorFormatActionBold:
            return @"strong";
            break;
        case WPLegacyEditorFormatActionItalic:
            return @"em";
            break;
        case WPLegacyEditorFormatActionUnderline:
            return @"u";
            break;
        case WPLegacyEditorFormatActionDelete:
            return @"del";
            break;
        case WPLegacyEditorFormatActionLink:
            return @"link";
            break;
        case WPLegacyEditorFormatActionQuote:
            return @"blockquote";
            break;
        case WPLegacyEditorFormatActionMore:
            return @"more";
            break;
    }
    return nil;
}

NSString * WPLegacyEditorFormatActionToName(WPLegacyEditorFormatAction formatAction) {
    switch (formatAction) {
        case WPLegacyEditorFormatActionMedia:
            return NSLocalizedString(@"add media", @"Add media in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        case WPLegacyEditorFormatActionBold:
            return NSLocalizedString(@"bold", @"Bold text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
            break;
        case WPLegacyEditorFormatActionItalic:
            return NSLocalizedString(@"italic", @"Italic text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
            break;
        case WPLegacyEditorFormatActionUnderline:
            return NSLocalizedString(@"underline", @"Underline text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
            break;
        case WPLegacyEditorFormatActionDelete:
            return NSLocalizedString(@"del", @"<del> (deleted text) HTML formatting in the Post Editor. This string will be used in the Undo message if the last change was adding a <del> HTML element.");
            break;
        case WPLegacyEditorFormatActionLink:
            return NSLocalizedString(@"link", @"Link helper button in the Post Editor. This string will be used in the Undo message if the last change was adding a link.");
            break;
        case WPLegacyEditorFormatActionQuote:
            return NSLocalizedString(@"quote", @"Blockquote HTML formatting in the Post Editor. This string will be used in the Undo message if the last change was adding a blockquote.");
            break;
        case WPLegacyEditorFormatActionMore:
            return NSLocalizedString(@"more", @"Adding a More excerpt cut-off in the Post Editor. This string will be used in the Undo message if the last change was adding this formatting.");;
            break;
    }
    return nil;
}
