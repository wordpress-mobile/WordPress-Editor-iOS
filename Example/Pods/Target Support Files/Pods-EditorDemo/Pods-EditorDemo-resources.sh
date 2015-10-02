#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY=$(cd "${1%/*}" && pwd)
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "../../Assets/icon-posts-editor-inspector.png"
  install_resource "../../Assets/icon-posts-editor-inspector@2x.png"
  install_resource "../../Assets/icon-posts-editor-inspector@3x.png"
  install_resource "../../Assets/icon-posts-editor-preview.png"
  install_resource "../../Assets/icon-posts-editor-preview@2x.png"
  install_resource "../../Assets/icon-posts-editor-preview@3x.png"
  install_resource "../../Assets/icon_format_bold.png"
  install_resource "../../Assets/icon_format_bold@2x.png"
  install_resource "../../Assets/icon_format_bold@3x.png"
  install_resource "../../Assets/icon_format_html.png"
  install_resource "../../Assets/icon_format_html@2x.png"
  install_resource "../../Assets/icon_format_html@3x.png"
  install_resource "../../Assets/icon_format_italic.png"
  install_resource "../../Assets/icon_format_italic@2x.png"
  install_resource "../../Assets/icon_format_italic@3x.png"
  install_resource "../../Assets/icon_format_keyboard.png"
  install_resource "../../Assets/icon_format_keyboard@2x.png"
  install_resource "../../Assets/icon_format_link.png"
  install_resource "../../Assets/icon_format_link@2x.png"
  install_resource "../../Assets/icon_format_link@3x.png"
  install_resource "../../Assets/icon_format_media.png"
  install_resource "../../Assets/icon_format_media@2x.png"
  install_resource "../../Assets/icon_format_media@3x.png"
  install_resource "../../Assets/icon_format_more.png"
  install_resource "../../Assets/icon_format_more@2x.png"
  install_resource "../../Assets/icon_format_more@3x.png"
  install_resource "../../Assets/icon_format_ol.png"
  install_resource "../../Assets/icon_format_ol@2x.png"
  install_resource "../../Assets/icon_format_ol@3x.png"
  install_resource "../../Assets/icon_format_quote.png"
  install_resource "../../Assets/icon_format_quote@2x.png"
  install_resource "../../Assets/icon_format_quote@3x.png"
  install_resource "../../Assets/icon_format_strikethrough.png"
  install_resource "../../Assets/icon_format_strikethrough@2x.png"
  install_resource "../../Assets/icon_format_strikethrough@3x.png"
  install_resource "../../Assets/icon_format_ul.png"
  install_resource "../../Assets/icon_format_ul@2x.png"
  install_resource "../../Assets/icon_format_ul@3x.png"
  install_resource "../../Assets/icon_format_underline.png"
  install_resource "../../Assets/icon_format_underline@2x.png"
  install_resource "../../Assets/icon_format_unlink.png"
  install_resource "../../Assets/icon_format_unlink@2x.png"
  install_resource "../../Assets/icon_options.png"
  install_resource "../../Assets/icon_options@2x.png"
  install_resource "../../Assets/icon_preview.png"
  install_resource "../../Assets/icon_preview@2x.png"
  install_resource "../../Assets/ZSSbgcolor.png"
  install_resource "../../Assets/ZSSbgcolor@2x.png"
  install_resource "../../Assets/ZSScenterjustify.png"
  install_resource "../../Assets/ZSScenterjustify@2x.png"
  install_resource "../../Assets/ZSSclearstyle.png"
  install_resource "../../Assets/ZSSclearstyle@2x.png"
  install_resource "../../Assets/ZSSforcejustify.png"
  install_resource "../../Assets/ZSSforcejustify@2x.png"
  install_resource "../../Assets/ZSSh1.png"
  install_resource "../../Assets/ZSSh1@2x.png"
  install_resource "../../Assets/ZSSh2.png"
  install_resource "../../Assets/ZSSh2@2x.png"
  install_resource "../../Assets/ZSSh3.png"
  install_resource "../../Assets/ZSSh3@2x.png"
  install_resource "../../Assets/ZSSh4.png"
  install_resource "../../Assets/ZSSh4@2x.png"
  install_resource "../../Assets/ZSSh5.png"
  install_resource "../../Assets/ZSSh5@2x.png"
  install_resource "../../Assets/ZSSh6.png"
  install_resource "../../Assets/ZSSh6@2x.png"
  install_resource "../../Assets/ZSShorizontalrule.png"
  install_resource "../../Assets/ZSShorizontalrule@2x.png"
  install_resource "../../Assets/ZSSindent.png"
  install_resource "../../Assets/ZSSindent@2x.png"
  install_resource "../../Assets/ZSSleftjustify.png"
  install_resource "../../Assets/ZSSleftjustify@2x.png"
  install_resource "../../Assets/ZSSoutdent.png"
  install_resource "../../Assets/ZSSoutdent@2x.png"
  install_resource "../../Assets/ZSSquicklink.png"
  install_resource "../../Assets/ZSSquicklink@2x.png"
  install_resource "../../Assets/ZSSredo.png"
  install_resource "../../Assets/ZSSredo@2x.png"
  install_resource "../../Assets/ZSSrightjustify.png"
  install_resource "../../Assets/ZSSrightjustify@2x.png"
  install_resource "../../Assets/ZSSsubscript.png"
  install_resource "../../Assets/ZSSsubscript@2x.png"
  install_resource "../../Assets/ZSSsuperscript.png"
  install_resource "../../Assets/ZSSsuperscript@2x.png"
  install_resource "../../Assets/ZSStextcolor.png"
  install_resource "../../Assets/ZSStextcolor@2x.png"
  install_resource "../../Assets/ZSSundo.png"
  install_resource "../../Assets/ZSSundo@2x.png"
  install_resource "../../Assets/editor.html"
  install_resource "../../Assets/jquery.js"
  install_resource "../../Assets/jquery.mobile-events.min.js"
  install_resource "../../Assets/js-beautifier.js"
  install_resource "../../Assets/rangy-classapplier.js"
  install_resource "../../Assets/rangy-core.js"
  install_resource "../../Assets/rangy-highlighter.js"
  install_resource "../../Assets/rangy-selectionsaverestore.js"
  install_resource "../../Assets/rangy-serializer.js"
  install_resource "../../Assets/rangy-textrange.js"
  install_resource "../../Assets/shortcode.js"
  install_resource "../../Assets/underscore-min.js"
  install_resource "../../Assets/WPHybridCallbacker.js"
  install_resource "../../Assets/WPHybridLogger.js"
  install_resource "../../Assets/wpload.js"
  install_resource "../../Assets/wpsave.js"
  install_resource "../../Assets/ZSSRichTextEditor.js"
  install_resource "../../Assets/wpposter.svg"
  install_resource "../../Assets/editor.css"
  install_resource "${BUILT_PRODUCTS_DIR}/WordPress-iOS-Shared.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "../../Assets/icon-posts-editor-inspector.png"
  install_resource "../../Assets/icon-posts-editor-inspector@2x.png"
  install_resource "../../Assets/icon-posts-editor-inspector@3x.png"
  install_resource "../../Assets/icon-posts-editor-preview.png"
  install_resource "../../Assets/icon-posts-editor-preview@2x.png"
  install_resource "../../Assets/icon-posts-editor-preview@3x.png"
  install_resource "../../Assets/icon_format_bold.png"
  install_resource "../../Assets/icon_format_bold@2x.png"
  install_resource "../../Assets/icon_format_bold@3x.png"
  install_resource "../../Assets/icon_format_html.png"
  install_resource "../../Assets/icon_format_html@2x.png"
  install_resource "../../Assets/icon_format_html@3x.png"
  install_resource "../../Assets/icon_format_italic.png"
  install_resource "../../Assets/icon_format_italic@2x.png"
  install_resource "../../Assets/icon_format_italic@3x.png"
  install_resource "../../Assets/icon_format_keyboard.png"
  install_resource "../../Assets/icon_format_keyboard@2x.png"
  install_resource "../../Assets/icon_format_link.png"
  install_resource "../../Assets/icon_format_link@2x.png"
  install_resource "../../Assets/icon_format_link@3x.png"
  install_resource "../../Assets/icon_format_media.png"
  install_resource "../../Assets/icon_format_media@2x.png"
  install_resource "../../Assets/icon_format_media@3x.png"
  install_resource "../../Assets/icon_format_more.png"
  install_resource "../../Assets/icon_format_more@2x.png"
  install_resource "../../Assets/icon_format_more@3x.png"
  install_resource "../../Assets/icon_format_ol.png"
  install_resource "../../Assets/icon_format_ol@2x.png"
  install_resource "../../Assets/icon_format_ol@3x.png"
  install_resource "../../Assets/icon_format_quote.png"
  install_resource "../../Assets/icon_format_quote@2x.png"
  install_resource "../../Assets/icon_format_quote@3x.png"
  install_resource "../../Assets/icon_format_strikethrough.png"
  install_resource "../../Assets/icon_format_strikethrough@2x.png"
  install_resource "../../Assets/icon_format_strikethrough@3x.png"
  install_resource "../../Assets/icon_format_ul.png"
  install_resource "../../Assets/icon_format_ul@2x.png"
  install_resource "../../Assets/icon_format_ul@3x.png"
  install_resource "../../Assets/icon_format_underline.png"
  install_resource "../../Assets/icon_format_underline@2x.png"
  install_resource "../../Assets/icon_format_unlink.png"
  install_resource "../../Assets/icon_format_unlink@2x.png"
  install_resource "../../Assets/icon_options.png"
  install_resource "../../Assets/icon_options@2x.png"
  install_resource "../../Assets/icon_preview.png"
  install_resource "../../Assets/icon_preview@2x.png"
  install_resource "../../Assets/ZSSbgcolor.png"
  install_resource "../../Assets/ZSSbgcolor@2x.png"
  install_resource "../../Assets/ZSScenterjustify.png"
  install_resource "../../Assets/ZSScenterjustify@2x.png"
  install_resource "../../Assets/ZSSclearstyle.png"
  install_resource "../../Assets/ZSSclearstyle@2x.png"
  install_resource "../../Assets/ZSSforcejustify.png"
  install_resource "../../Assets/ZSSforcejustify@2x.png"
  install_resource "../../Assets/ZSSh1.png"
  install_resource "../../Assets/ZSSh1@2x.png"
  install_resource "../../Assets/ZSSh2.png"
  install_resource "../../Assets/ZSSh2@2x.png"
  install_resource "../../Assets/ZSSh3.png"
  install_resource "../../Assets/ZSSh3@2x.png"
  install_resource "../../Assets/ZSSh4.png"
  install_resource "../../Assets/ZSSh4@2x.png"
  install_resource "../../Assets/ZSSh5.png"
  install_resource "../../Assets/ZSSh5@2x.png"
  install_resource "../../Assets/ZSSh6.png"
  install_resource "../../Assets/ZSSh6@2x.png"
  install_resource "../../Assets/ZSShorizontalrule.png"
  install_resource "../../Assets/ZSShorizontalrule@2x.png"
  install_resource "../../Assets/ZSSindent.png"
  install_resource "../../Assets/ZSSindent@2x.png"
  install_resource "../../Assets/ZSSleftjustify.png"
  install_resource "../../Assets/ZSSleftjustify@2x.png"
  install_resource "../../Assets/ZSSoutdent.png"
  install_resource "../../Assets/ZSSoutdent@2x.png"
  install_resource "../../Assets/ZSSquicklink.png"
  install_resource "../../Assets/ZSSquicklink@2x.png"
  install_resource "../../Assets/ZSSredo.png"
  install_resource "../../Assets/ZSSredo@2x.png"
  install_resource "../../Assets/ZSSrightjustify.png"
  install_resource "../../Assets/ZSSrightjustify@2x.png"
  install_resource "../../Assets/ZSSsubscript.png"
  install_resource "../../Assets/ZSSsubscript@2x.png"
  install_resource "../../Assets/ZSSsuperscript.png"
  install_resource "../../Assets/ZSSsuperscript@2x.png"
  install_resource "../../Assets/ZSStextcolor.png"
  install_resource "../../Assets/ZSStextcolor@2x.png"
  install_resource "../../Assets/ZSSundo.png"
  install_resource "../../Assets/ZSSundo@2x.png"
  install_resource "../../Assets/editor.html"
  install_resource "../../Assets/jquery.js"
  install_resource "../../Assets/jquery.mobile-events.min.js"
  install_resource "../../Assets/js-beautifier.js"
  install_resource "../../Assets/rangy-classapplier.js"
  install_resource "../../Assets/rangy-core.js"
  install_resource "../../Assets/rangy-highlighter.js"
  install_resource "../../Assets/rangy-selectionsaverestore.js"
  install_resource "../../Assets/rangy-serializer.js"
  install_resource "../../Assets/rangy-textrange.js"
  install_resource "../../Assets/shortcode.js"
  install_resource "../../Assets/underscore-min.js"
  install_resource "../../Assets/WPHybridCallbacker.js"
  install_resource "../../Assets/WPHybridLogger.js"
  install_resource "../../Assets/wpload.js"
  install_resource "../../Assets/wpsave.js"
  install_resource "../../Assets/ZSSRichTextEditor.js"
  install_resource "../../Assets/wpposter.svg"
  install_resource "../../Assets/editor.css"
  install_resource "${BUILT_PRODUCTS_DIR}/WordPress-iOS-Shared.bundle"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
