import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Durumlar başlığı
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.customTheme.photoIconBgColor,
                child: Icon(
                  Icons.add,
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
                      'Durumum',
                      style: TextStyle(
                        color: context.customTheme.authAppbarTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Durum eklemek için dokun',
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
        // Son güncellemeler
        Expanded(
          child: ListView(
            children: [

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required String name,
    required String time,
    required bool isOnline,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: context.customTheme.photoIconBgColor,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: context.customTheme.photoIconColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (isOnline)
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
        time,
        style: TextStyle(
          color: context.customTheme.greyColor,
          fontSize: 14,
        ),
      ),
      onTap: () {
        // Durum görüntüleme sayfasına geçiş
      },
    );
  }
}
