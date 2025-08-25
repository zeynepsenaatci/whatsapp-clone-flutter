import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Profil bölümü
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.customTheme.photoIconBgColor,
                child: Text(
                  'T',
                  style: TextStyle(
                    color: context.customTheme.photoIconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanıcı',
                      style: TextStyle(
                        color: context.customTheme.authAppbarTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Merhaba! WhatsApp kullanıyorum.',
                      style: TextStyle(
                        color: context.customTheme.greyColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.qr_code,
                color: context.customTheme.greyColor,
                size: 24,
              ),
            ],
          ),
        ),
        Divider(color: context.customTheme.greyColor!.withOpacity(0.2)),
        // Ayarlar listesi
        _buildSettingsItem(
          icon: Icons.key,
          title: 'Hesap',
          subtitle: 'Güvenlik, telefon numarası',
        ),
        _buildSettingsItem(
          icon: Icons.lock,
          title: 'Gizlilik',
          subtitle: 'Durumlar, profil fotoğrafı',
        ),
        _buildSettingsItem(
          icon: Icons.chat_bubble,
          title: 'Sohbetler',
          subtitle: 'Tema, arka plan, geçmiş',
        ),
        _buildSettingsItem(
          icon: Icons.notifications,
          title: 'Bildirimler',
          subtitle: 'Mesaj, grup ve arama sesleri',
        ),
        _buildSettingsItem(
          icon: Icons.data_usage,
          title: 'Veri ve depolama',
          subtitle: 'Ağ kullanımı, otomatik indirme',
        ),
        Divider(color: context.customTheme.greyColor!.withOpacity(0.2)),
        _buildSettingsItem(
          icon: Icons.help,
          title: 'Yardım',
          subtitle: 'Yardım merkezi, bize ulaşın',
        ),
        _buildSettingsItem(
          icon: Icons.info,
          title: 'Hakkında',
          subtitle: 'Sürüm 1.0.0',
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: context.customTheme.photoIconBgColor,
        child: Icon(
          icon,
          color: context.customTheme.photoIconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.customTheme.authAppbarTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.customTheme.greyColor,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: context.customTheme.greyColor,
        size: 16,
      ),
      onTap: () {
        // Ayarlar detay sayfasına geçiş
      },
    );
  }
}