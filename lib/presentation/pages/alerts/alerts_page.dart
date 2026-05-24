import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/alert_model.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../bloc/price/price_bloc.dart';
import '../../widgets/alert/alert_card.dart';
import 'create_alert_sheet.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: BlocConsumer<AlertBloc, AlertState>(
          listener: (context, state) {
            if (state is AlertLoaded && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.darkCardElevated,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, state),
                if (_showSearch) _buildSearchBar(context),
                if (state is AlertLoaded) _buildFilterRow(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildHeader(BuildContext context, AlertState state) {
    final count = state is AlertLoaded ? state.activeCount : 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Alerts',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (count > 0)
                Text(
                  '$count active monitoring',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.priceUp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
              color: const Color(0xFF9898B8),
            ),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchController.clear();
                context.read<AlertBloc>().add(const SearchAlerts(''));
              }
            },
          ),
          if (state is AlertLoaded && state.totalCount > 0)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9898B8)),
              color: AppTheme.darkCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) => _handleMenuAction(context, val),
              itemBuilder: (_) => [
                _menuItem('activate_all', Icons.check_circle_outline_rounded, 'Activate All'),
                _menuItem('deactivate_all', Icons.unpublished_rounded, 'Deactivate All'),
                _menuItem('clear_triggered', Icons.history_toggle_off_rounded, 'Clear Triggered'),
                _menuItem('delete_all', Icons.delete_sweep_rounded, 'Delete All', color: AppTheme.priceDown),
              ],
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {Color? color}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? const Color(0xFF9898B8)),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.dmSans(color: color ?? Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    final bloc = context.read<AlertBloc>();
    switch (action) {
      case 'activate_all':
        bloc.add(ActivateAllAlerts());
        break;
      case 'deactivate_all':
        bloc.add(DeactivateAllAlerts());
        break;
      case 'clear_triggered':
        bloc.add(DeleteTriggeredAlerts());
        break;
      case 'delete_all':
        _confirmDeleteAll(context);
        break;
    }
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete All Alerts?',
            style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('This will permanently delete all alerts.',
            style: GoogleFonts.dmSans(color: const Color(0xFF9898B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: const Color(0xFF9898B8))),
          ),
          TextButton(
            onPressed: () {
              context.read<AlertBloc>().add(DeleteAllAlerts());
              Navigator.pop(context);
            },
            child: Text('Delete All', style: GoogleFonts.dmSans(color: AppTheme.priceDown)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.dmSans(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search alerts...',
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9898B8), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF9898B8), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AlertBloc>().add(const SearchAlerts(''));
                  },
                )
              : null,
        ),
        onChanged: (q) => context.read<AlertBloc>().add(SearchAlerts(q)),
      ).animate().slideY(begin: -0.3, duration: 200.ms),
    );
  }

  Widget _buildFilterRow(BuildContext context, AlertLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: AlertFilter.values.map((filter) {
          final isSelected = state.filter == filter;
          final label = _filterLabel(filter, state);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label),
              onSelected: (_) =>
                  context.read<AlertBloc>().add(FilterAlerts(filter)),
              backgroundColor: AppTheme.darkCard,
              selectedColor: AppTheme.goldPrimary.withOpacity(0.15),
              checkmarkColor: AppTheme.goldPrimary,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.goldPrimary.withOpacity(0.5)
                    : AppTheme.darkBorder,
              ),
              labelStyle: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.goldPrimary : const Color(0xFF9898B8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _filterLabel(AlertFilter filter, AlertLoaded state) {
    switch (filter) {
      case AlertFilter.all:
        return 'All (${state.totalCount})';
      case AlertFilter.active:
        return 'Active (${state.activeCount})';
      case AlertFilter.inactive:
        return 'Inactive';
      case AlertFilter.triggered:
        return 'Triggered (${state.triggeredCount})';
    }
  }

  Widget _buildBody(BuildContext context, AlertState state) {
    if (state is AlertLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.goldPrimary),
      );
    }
    if (state is AlertLoaded) {
      if (state.alerts.isEmpty) return _buildEmpty(context, state.filter);
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: state.alerts.length,
        itemBuilder: (_, i) {
          return AlertCard(
            alert: state.alerts[i],
            onToggle: () => context
                .read<AlertBloc>()
                .add(ToggleAlert(state.alerts[i].id)),
            onDelete: () => context
                .read<AlertBloc>()
                .add(DeleteAlert(state.alerts[i].id)),
            onEdit: () => _editAlert(context, state.alerts[i]),
          ).animate(delay: (i * 40).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmpty(BuildContext context, AlertFilter filter) {
    String title;
    switch (filter) {
      case AlertFilter.all:
        title = 'No Alerts Yet';
        break;
      case AlertFilter.active:
        title = 'No Active Alerts';
        break;
      case AlertFilter.inactive:
        title = 'No Inactive Alerts';
        break;
      case AlertFilter.triggered:
        title = 'No Triggered Alerts';
        break;
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter == AlertFilter.triggered
                ? Icons.history_rounded
                : Icons.notifications_none_rounded,
            size: 56,
            color: const Color(0xFF3A3A5A),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A5A7A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filter == AlertFilter.all
                ? 'Tap + to create your first price alert'
                : 'No alerts in this category',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF3A3A5A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateAlert(context),
      backgroundColor: AppTheme.goldPrimary,
      foregroundColor: const Color(0xFF1A1000),
      icon: const Icon(Icons.add_alert_rounded),
      label: Text(
        'New Alert',
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    );
  }

  void _showCreateAlert(BuildContext context) {
    final priceState = context.read<PriceBloc>().state;
    final suggestedPrice =
        priceState is PriceLoaded ? priceState.price.mid : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AlertBloc>(),
        child: CreateAlertSheet(suggestedPrice: suggestedPrice),
      ),
    );
  }

  void _editAlert(BuildContext context, AlertModel alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AlertBloc>(),
        child: CreateAlertSheet(existingAlert: alert),
      ),
    );
  }
}
