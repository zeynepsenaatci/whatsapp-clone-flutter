import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Topluluk başlığı
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.customTheme.photoIconBgColor,
                child: Icon(
                  Icons.groups,
                  color: context.customTheme.photoIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topluluklar',
                      style: TextStyle(
                        color: context.customTheme.authAppbarTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Topluluk oluşturmak için dokun',
                      style: TextStyle(
                        color: context.customTheme.greyColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: context.customTheme.greyColor!.withOpacity(0.2)),
        // Topluluk listesi
        Expanded(
          child: ListView(
            children: [

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityItem({
    required String name,
    required String members,
    required bool isActive,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: context.customTheme.photoIconBgColor,
            child: Icon(
              Icons.groups,
              color: context.customTheme.photoIconColor,
              size: 20,
            ),
          ),
          if (isActive)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          color: context.customTheme.authAppbarTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        members,
        style: TextStyle(
          color: context.customTheme.greyColor,
          fontSize: 14,
        ),
      ),
      onTap: () {
        // Topluluk detay sayfasına geçiş
      },
    );
  }
}