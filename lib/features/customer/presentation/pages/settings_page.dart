import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/shared/widgets/theme_toggle_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            const ThemeToggleWidget(),
            
            SizedBox(height: 32.h),
            
            // Notifications Section
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildSettingsSection(
              context,
              [
                _buildSettingsItem(
                  context,
                  'Push Notifications',
                  'Receive notifications about orders and updates',
                  Icons.notifications_outlined,
                  true,
                  (value) {
                    // TODO: Handle notification toggle
                  },
                ),
                _buildSettingsItem(
                  context,
                  'Email Notifications',
                  'Receive updates via email',
                  Icons.email_outlined,
                  true,
                  (value) {
                    // TODO: Handle email toggle
                  },
                ),
                _buildSettingsItem(
                  context,
                  'SMS Notifications',
                  'Receive updates via SMS',
                  Icons.sms_outlined,
                  false,
                  (value) {
                    // TODO: Handle SMS toggle
                  },
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // Privacy Section
            Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildSettingsSection(
              context,
              [
                _buildSettingsItem(
                  context,
                  'Location Services',
                  'Allow app to access your location',
                  Icons.location_on_outlined,
                  true,
                  (value) {
                    // TODO: Handle location toggle
                  },
                ),
                _buildSettingsItem(
                  context,
                  'Data Usage',
                  'Manage your data usage preferences',
                  Icons.data_usage_outlined,
                  null,
                  (value) {
                    // TODO: Navigate to data usage settings
                  },
                ),
                _buildSettingsItem(
                  context,
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.privacy_tip_outlined,
                  null,
                  (value) {
                    // TODO: Navigate to privacy policy
                  },
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // About Section
            Text(
              'About',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildSettingsSection(
              context,
              [
                _buildSettingsItem(
                  context,
                  'App Version',
                  '1.0.0',
                  Icons.info_outlined,
                  null,
                  (value) {
                    // TODO: Show version info
                  },
                ),
                _buildSettingsItem(
                  context,
                  'Terms of Service',
                  'View terms and conditions',
                  Icons.description_outlined,
                  null,
                  (value) {
                    // TODO: Navigate to terms
                  },
                ),
                _buildSettingsItem(
                  context,
                  'Contact Support',
                  'Get help from our support team',
                  Icons.support_agent_outlined,
                  null,
                  (value) {
                    // TODO: Navigate to support
                  },
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    List<Widget> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool? isSwitch,
    Function(bool?)? onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: isSwitch != null
          ? Switch(
              value: isSwitch,
              onChanged: onChanged,
              activeThumbColor: Theme.of(context).colorScheme.primary,
            )
          : Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
      onTap: isSwitch == null ? () => onChanged?.call(null) : null,
    );
  }
}
