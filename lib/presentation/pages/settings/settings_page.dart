import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/settings_model.dart';
import '../../bloc/settings/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final AppSettings settings = state is SettingsLoaded
                ? state.settings
                : const AppSettings();
            return CustomScrollView(
              slivers: <Widget>[
                _buildAppBar(),
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        _buildSection('Appearance', <Widget>[
                          _buildThemeSetting(context, settings),
                        ]),
                        _buildSection('Price Feed', <Widget>[
                          _buildRefreshSetting(context, settings),
                          _buildDecimalsSetting(context, settings),
                        ]),
                        _buildSection(
                          'Notifications & Alerts',
                          <Widget>[
                            _buildToggle(
                              'Notifications',
                              'Receive price alert notifications',
                              Icons.notifications_rounded,
                              settings.notificationsEnabled,
                              (v) => _update(
                                context,
                                settings.copyWith(
                                  notificationsEnabled: v,
                                ),
                              ),
                            ),
                            _buildToggle(
                              'Sound',
                              'Play sound on alerts',
                              Icons.volume_up_rounded,
                              settings.soundEnabled,
                              (v) => _update(
                                context,
                                settings.copyWith(soundEnabled: v),
                              ),
                            ),
                            _buildToggle(
                              'Vibration',
                              'Vibrate on alerts',
                              Icons.vibration_rounded,
                              settings.vibrationEnabled,
                              (v) => _update(
                                context,
                                settings.copyWith(vibrationEnabled: v),
                              ),
                            ),
                          ],
                        ),
                        _buildSection(
                          'Background & Reliability',
                          <Widget>[
                            _buildToggle(
                              'Background Service',
                              'Keep price monitoring active in background',
                              Icons.settings_backup_restore_rounded,
                              settings.backgroundServiceEnabled,
                              (v) => _update(
                                context,
                                settings.copyWith(
                                  backgroundServiceEnabled: v,
                                ),
                              ),
                            ),
                            _buildPermissionTile(
                              'Battery Optimization',
                              settings.batteryOptimizationIgnored
                                  ? 'Unrestricted ✓'
                                  : 'Tap to disable for reliability',
                              Icons.battery_saver_rounded,
                              settings.batteryOptimizationIgnored,
                              () => _requestBatteryOpt(context, settings),
                            ),
                          ],
                        ),
                        _buildSection('Data Source', <Widget>[
                          _buildInfoTile(
                            'Primary',
                            'GoldAPI.io (real-time)',
                          ),
                          _buildInfoTile(
                            'Secondary',
                            'Yahoo Finance (GC=F futures)',
                          ),
                          _buildInfoTile(
                            'Tertiary',
                            'goldprice.org feed',
                          ),
                        ]),
                        _buildSection('About', <Widget>[
                          _buildInfoTile('App', 'XAUT Gold Tracker'),
                          _buildInfoTile('Version', _appVersion),
                          _buildInfoTile('Symbol', 'XAU/USD Spot Gold'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.darkBg,
      floating: true,
      titleSpacing: 16,
      title: Text(
        'Settings',
        style: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A5A7A),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map(
                  (entry) => Column(
                    children: <Widget>[
                      entry.value,
                      if (entry.key < children.length - 1)
                        const Divider(
                          height: 1,
                          color: AppTheme.darkDivider,
                          indent: 54,
                        ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSetting(
    BuildContext context,
    AppSettings settings,
  ) {
    const Map<ThemeMode, String> labels = <ThemeMode, String>{
      ThemeMode.dark: 'Dark',
      ThemeMode.light: 'Light',
      ThemeMode.system: 'System',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.brightness_6_rounded,
            color: Color(0xFF9898B8),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Theme', style: _labelStyle()),
                Text('App colour scheme', style: _subStyle()),
              ],
            ),
          ),
          DropdownButton<ThemeMode>(
            value: settings.themeMode,
            dropdownColor: AppTheme.darkCardElevated,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 13,
            ),
            underline: const SizedBox.shrink(),
            items: ThemeMode.values
                .map(
                  (m) => DropdownMenuItem<ThemeMode>(
                    value: m,
                    child: Text(labels[m] ?? ''),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                _update(context, settings.copyWith(themeMode: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshSetting(
    BuildContext context,
    AppSettings settings,
  ) {
    const Map<int, String> intervals = <int, String>{
      1000: '1 s (fastest)',
      2000: '2 s',
      3000: '3 s',
      5000: '5 s',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.speed_rounded,
            color: Color(0xFF9898B8),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Refresh Rate', style: _labelStyle()),
                Text('How often price updates', style: _subStyle()),
              ],
            ),
          ),
          DropdownButton<int>(
            value: settings.refreshIntervalMs,
            dropdownColor: AppTheme.darkCardElevated,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
            underline: const SizedBox.shrink(),
            items: intervals.entries
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                _update(context, settings.copyWith(refreshIntervalMs: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildDecimalsSetting(
    BuildContext context,
    AppSettings settings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.numbers_rounded,
            color: Color(0xFF9898B8),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Price Decimals', style: _labelStyle()),
                Text(
                  'Number of decimal places shown',
                  style: _subStyle(),
                ),
              ],
            ),
          ),
          DropdownButton<int>(
            value: settings.priceDecimals,
            dropdownColor: AppTheme.darkCardElevated,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
            underline: const SizedBox.shrink(),
            items: <int>[2, 3]
                .map(
                  (n) => DropdownMenuItem<int>(
                    value: n,
                    child: Text('$n decimals'),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                _update(context, settings.copyWith(priceDecimals: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    String label,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, color: const Color(0xFF9898B8), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: _labelStyle()),
                Text(subtitle, style: _subStyle()),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    String label,
    String subtitle,
    IconData icon,
    bool granted,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: granted ? null : onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(icon, color: const Color(0xFF9898B8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: _labelStyle()),
                  Text(subtitle, style: _subStyle()),
                ],
              ),
            ),
            Icon(
              granted
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: granted
                  ? AppTheme.priceUp
                  : const Color(0xFF5A5A7A),
              size: granted ? 20 : 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: _labelStyle())),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF9898B8),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle _subStyle() => GoogleFonts.dmSans(
        fontSize: 11,
        color: const Color(0xFF5A5A7A),
      );

  void _update(BuildContext context, AppSettings settings) {
    context.read<SettingsBloc>().add(UpdateSettings(settings));
  }

  Future<void> _requestBatteryOpt(
    BuildContext context,
    AppSettings settings,
  ) async {
    final PermissionStatus status =
        await Permission.ignoreBatteryOptimizations.request();
    if (!mounted) return;
    if (status.isGranted) {
      _update(
        context,
        settings.copyWith(batteryOptimizationIgnored: true),
      );
    }
  }
}
