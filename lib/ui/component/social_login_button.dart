// ignore_for_file: prefer-match-file-name
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContinueWithGoogleButton extends StatelessWidget {
  const ContinueWithGoogleButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _ContinueWithThirdPartyProviderButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icon/google.svg',
        width: 24,
        height: 24,
      ),
      text: 'Googleで続ける',
      textColor: Colors.black,
      backgroundColor: Colors.white,
    );
  }
}

class ContinueWithTwitterButton extends StatelessWidget {
  const ContinueWithTwitterButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;

    return _ContinueWithThirdPartyProviderButton(
      onPressed: onPressed,
      icon: const Icon(
        FontAwesomeIcons.twitter,
        color: foregroundColor,
      ),
      text: 'Twitterで続ける',
      textColor: foregroundColor,
      backgroundColor: const Color(0xFF1DA1F2),
    );
  }
}

class ContinueWithFacebookButton extends StatelessWidget {
  const ContinueWithFacebookButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;

    return _ContinueWithThirdPartyProviderButton(
      onPressed: onPressed,
      icon: const Icon(
        FontAwesomeIcons.facebook,
        color: foregroundColor,
      ),
      text: 'Facebookで続ける',
      textColor: Colors.white,
      backgroundColor: const Color(0xFF1877f2),
    );
  }
}

class ContinueWithAppleButton extends StatelessWidget {
  const ContinueWithAppleButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;

    return _ContinueWithThirdPartyProviderButton(
      onPressed: onPressed,
      icon: const Icon(
        FontAwesomeIcons.apple,
        color: foregroundColor,
      ),
      text: 'Appleで続ける',
      textColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }
}

class _ContinueWithThirdPartyProviderButton extends StatelessWidget {
  const _ContinueWithThirdPartyProviderButton({
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget icon;
  final String text;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontSize: 16,
              // Specify a default text theme to apply the system font to
              // "Continue with Apple" button according to
              // Apple's design guidelines.
              fontFamily: '',
            ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: icon,
          ),
          Expanded(
            flex: 5,
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
