import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hejtter/ui/settings_screen/widgets/widgets.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateModal extends StatelessWidget {
  const DonateModal({
    super.key,
  });

  _supportGithub(BuildContext context, [bool mounted = true]) async {
    try {
      await launchUrl(
        Uri.parse(githubSponsorUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
          ),
        ),
      );
    }
  }

  _supportBuyMeCoffe(BuildContext context, [bool mounted = true]) async {
    try {
      await launchUrl(
        Uri.parse(buyMeCoffeUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 5),
        Container(
          height: 3,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: ContactButton(
                    text: 'Zostań sponsorem na Githubie',
                    icon: FontAwesomeIcons.github,
                    onPressed: () => _supportGithub(context),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ContactButton(
                    text: 'Kup filiżankę kawy na buymeacoffee.com',
                    icon: FontAwesomeIcons.mugHot,
                    onPressed: () => _supportBuyMeCoffe(context),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
