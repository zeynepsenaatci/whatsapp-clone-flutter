import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _topTabController;
  late TabController _bottomTabController;

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(length: 4, vsync: this);
    _bottomTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _topTabController.dispose();
    _bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Row(
            children: [
              PopupMenuButton<String>(
                color: context.customTheme.tabColor,
                icon: Icon(
                  Icons.more_vert,
                  color: context.customTheme.greyColor,
                  size: 22,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'select_chat':
                      print('Sohbet seç');
                      break;
                    case 'mark_all_read':
                      print('Tümü okundu');
                      break;
                    case 'new_chat':
                      print('Yeni sohbet');
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'select_chat',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: context.customTheme.greyColor,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Sohbet seç',
                          style: TextStyle(
                            color: context.customTheme.greyColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read,
                          color: context.customTheme.greyColor,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Tümü okundu',
                          style: TextStyle(
                            color: context.customTheme.greyColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'new_chat',
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: context.customTheme.greyColor,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Yeni sohbet',
                          style: TextStyle(
                            color: context.customTheme.greyColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Icon(
                Icons.camera_alt_outlined,
                color: context.customTheme.greyColor,
                size: 22,
              ),
              const SizedBox(width: 15),
            ],
          ),
        ],
        title: Text(
          'WhatsApp Klonum',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: context.customTheme.authAppbarTextColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.customTheme.searchBarColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: context.customTheme.greyColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ara',
                    style: TextStyle(
                      color: context.customTheme.greyColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Özel tab butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(
                  'Tümü',
                  0,
                  selectedColor: context.customTheme.greyColor,
                  selectedTextStyle: TextStyle(
                    color: context.customTheme.tabText,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedColor: Colors.transparent,
                  unselectedTextStyle: TextStyle(
                    color: context.customTheme.greyColor,
                  ),
                ),
                _buildTabButton(
                  'Okunmamış',
                  1,
                  selectedColor: context.customTheme.greyColor,
                  selectedTextStyle: TextStyle(
                    color: context.customTheme.tabText,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedColor: Colors.transparent,
                  unselectedTextStyle: TextStyle(
                    color: context.customTheme.greyColor,
                  ),
                ),
                _buildTabButton(
                  'Favoriler',
                  2,
                  selectedColor: context.customTheme.greyColor,
                  selectedTextStyle: TextStyle(
                    color: context.customTheme.tabText,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedColor: Colors.transparent,
                  unselectedTextStyle: TextStyle(
                    color: context.customTheme.greyColor,
                  ),
                ),
                _buildTabButton(
                  'Gruplar',
                  3,
                  selectedColor: context.customTheme.greyColor,
                  selectedTextStyle: TextStyle(
                    color: context.customTheme.tabText,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedColor: Colors.transparent,
                  unselectedTextStyle: TextStyle(
                    color: context.customTheme.greyColor,
                  ),
                ),
              ],
            ),
          ),
          // Tab içeriği
          Expanded(
            child: TabBarView(
              controller: _topTabController,
              children: [
                Center(child: Text('Tümü Tab')),
                Center(child: Text('Okunmamış Tab')),
                Center(child: Text('Favoriler Tab')),
                Center(child: Text('Gruplar Tab')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
          controller: _bottomTabController,
          indicatorColor: Coloors.greenDark,
          indicatorWeight: 3,
          labelColor: Coloors.greenDark,
          unselectedLabelColor: context.customTheme.greyColor,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.update, size: 24), text: 'Durumlar'),
            Tab(icon: Icon(Icons.phone, size: 24), text: 'Aramalar'),
            Tab(icon: Icon(Icons.groups, size: 24), text: 'Topluluk'),
            Tab(icon: Icon(Icons.chat_bubble, size: 24), text: 'Sohbet'),
            Tab(icon: Icon(Icons.settings, size: 24), text: 'Ayarlar'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    String text,
    int tabIndex, {
    TextStyle? selectedTextStyle,
    TextStyle? unselectedTextStyle,
    Color? selectedColor,
    Color? unselectedColor,
  }) {
    final isSelected = _topTabController.index == tabIndex;

    return GestureDetector(
      onTap: () {
        _topTabController.animateTo(tabIndex);
        setState(() {});
      },
      child: SizedBox(
        width: 80, // Genişlik
        height: 42, // Yükseklik
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (selectedColor ?? Coloors.greenDark)
                : (unselectedColor ?? context.customTheme.tabColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: isSelected
                ? (selectedTextStyle ??
                      TextStyle(
                        color: context.customTheme.tabText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ))
                : (unselectedTextStyle ??
                      TextStyle(
                        color: context.customTheme.tabText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
          ),
        ),
      ),
    );
  }
}
