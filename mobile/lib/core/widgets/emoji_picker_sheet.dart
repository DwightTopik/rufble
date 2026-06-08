import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

const String _emojiFont = 'AppleColorEmoji';

/// Shows the bundled Apple Color Emoji picker (search enabled) as a Cupertino
/// modal sheet and resolves with the chosen emoji, or null if dismissed.
Future<String?> showEmojiPickerSheet(BuildContext context) {
  return showCupertinoModalPopup<String>(
    context: context,
    builder: (context) => const _EmojiPickerSheet(),
  );
}

class _EmojiPickerSheet extends StatelessWidget {
  const _EmojiPickerSheet();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      height: AppDimensions.emojiPickerHeight,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) =>
            Navigator.of(context).pop(emoji.emoji),
        config: Config(
          height: AppDimensions.emojiPickerHeight,
          // Custom bundled font → skip platform glyph filtering.
          checkPlatformCompatibility: false,
          emojiTextStyle: const TextStyle(
            fontFamily: _emojiFont,
            fontSize: 28,
            decoration: TextDecoration.none,
          ),
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28,
            backgroundColor: theme.surface,
            buttonMode: ButtonMode.CUPERTINO,
          ),
          categoryViewConfig: CategoryViewConfig(
            initCategory: Category.SMILEYS,
            backgroundColor: theme.surface,
            indicatorColor: theme.primary,
            iconColorSelected: theme.primary,
            iconColor: theme.text3,
            backspaceColor: theme.primary,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: theme.elevated,
            buttonColor: theme.elevated,
            buttonIconColor: theme.text2,
            showBackspaceButton: false,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: theme.surface,
            buttonIconColor: theme.text2,
            hintText: 'Search emoji',
          ),
          skinToneConfig: const SkinToneConfig(),
        ),
      ),
    );
  }
}
